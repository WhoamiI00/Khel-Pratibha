# views.py
from rest_framework import viewsets, status
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.permissions import AllowAny
from django.views.decorators.csrf import csrf_exempt
from django.core.files.storage import default_storage
from django.db.models import Q, Avg, Count, Max, Min
from django.utils import timezone
from django.http import JsonResponse
from django.shortcuts import render
from datetime import datetime, timedelta
import uuid
import json
import sys

from .models import *
from .serializers import *
from .middleware import supabase_auth_required, get_current_user_profile

class AthleteProfileViewSet(viewsets.ModelViewSet):
    queryset = AthleteProfile.objects.all()
    serializer_class = AthleteProfileSerializer
    
    def get_queryset(self):
        # Check if user is authenticated (handled by middleware)
        if not getattr(self.request, 'is_authenticated', False):
            return AthleteProfile.objects.none()
        
        # Athletes can only see their own profile, SAI officials see all
        user_role = getattr(self.request, 'user_role', 'authenticated')
        if user_role == 'sai_official':
            return AthleteProfile.objects.all()
        return AthleteProfile.objects.filter(auth_user_id=self.request.user_id)
    
    @action(detail=True, methods=['get'])
    def talent_summary(self, request, pk=None):
        """Get comprehensive talent summary for an athlete"""
        athlete = self.get_object()
        serializer = TalentSummarySerializer(athlete)
        return Response(serializer.data)
    
    @action(detail=False, methods=['post'])
    def register_athlete(self, request):
        """Register new athlete with SAI platform"""
        if not getattr(self.request, 'is_authenticated', False):
            return Response({'error': 'Authentication required'}, status=status.HTTP_401_UNAUTHORIZED)
            
        serializer = AthleteProfileSerializer(data=request.data)
        if serializer.is_valid():
            athlete = serializer.save(
                auth_user_id=request.user_id,
                email=request.user_email
            )
            
            # Create initial assessment session
            session = AssessmentSession.objects.create(
                athlete=athlete,
                session_name=f"Initial Assessment - {athlete.full_name}",
                status='created'
            )
            
            # Award welcome badge
            self.award_welcome_badge(athlete)
            
            return Response({
                'athlete_id': athlete.id,
                'session_id': session.id,
                'message': 'Athlete registered successfully!',
                'next_steps': 'Complete your fitness assessment tests'
            }, status=status.HTTP_201_CREATED)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def award_welcome_badge(self, athlete):
        """Award welcome badge to new athletes"""
        try:
            welcome_badge = Badge.objects.get(name='Welcome to SAI')
            AthleteBadge.objects.create(athlete=athlete, badge=welcome_badge)
        except Badge.DoesNotExist:
            pass

import pprint
class FitnessTestViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = FitnessTest.objects.filter(is_active=True)
    serializer_class = FitnessTestSerializer
    
    @action(detail=True, methods=['get'])
    def benchmarks(self, request, pk=None):
        """Get age-specific benchmarks for a test"""
        test = self.get_object()
        age = request.query_params.get('age')
        gender = request.query_params.get('gender', 'male')
        
        benchmark = AgeBenchmark.objects.filter(
            fitness_test=test,
            age_min__lte=age,
            age_max__gte=age,
            gender=gender
        ).first()
        
        pprint(AgeBenchmarkSerializer(benchmark).data)
        print(AgeBenchmarkSerializer(benchmark).data)
        if benchmark:
            return Response(AgeBenchmarkSerializer(benchmark).data)
        
        return Response({'error': 'No benchmark found for this age/gender combination'}, 
                       status=status.HTTP_404_NOT_FOUND)


class AssessmentSessionViewSet(viewsets.ModelViewSet):
    queryset = AssessmentSession.objects.all()
    serializer_class = AssessmentSessionSerializer

    def get_queryset(self):
        print("DEBUG: get_queryset called")
        print(f"DEBUG: User authenticated? {getattr(self.request, 'is_authenticated', False)}")
        print(f"DEBUG: User role: {getattr(self.request, 'user_role', 'authenticated')}")
        print(f"DEBUG: User ID: {getattr(self.request, 'user_id', None)}")

        if not getattr(self.request, 'is_authenticated', False):
            print("DEBUG: Returning empty queryset (unauthenticated)")
            return AssessmentSession.objects.none()

        user_role = getattr(self.request, 'user_role', 'authenticated')
        if user_role != 'sai_official':
            print("DEBUG: Returning sessions filtered by athlete")
            print(AssessmentSession.objects.all())
            return AssessmentSession.objects.filter(athlete__auth_user_id=self.request.user_id)

        print("DEBUG: Returning all sessions (SAI official)")
        return AssessmentSession.objects.all()

    @action(detail=False, methods=['post'])
    def start_assessment(self, request):
        print("DEBUG: start_assessment API called")
        print(f"DEBUG: Request data: {request.data}")

        if not getattr(self.request, 'is_authenticated', False):
            print("DEBUG: Authentication failed")
            return Response({'error': 'Authentication required'}, status=status.HTTP_401_UNAUTHORIZED)

        try:
            athlete = AthleteProfile.objects.get(auth_user_id=request.user_id)
            print(f"DEBUG: Athlete found: {athlete}")

            ongoing_session = AssessmentSession.objects.filter(
                athlete=athlete,
                status__in=['created', 'in_progress']
            ).first()

            if ongoing_session:
                print(f"DEBUG: Ongoing session found: {ongoing_session.id}")
                return Response({
                    'session_id': ongoing_session.id,
                    'message': 'Continuing existing assessment session',
                    'status': ongoing_session.status,
                    'progress': f"{ongoing_session.completed_tests}/{ongoing_session.total_tests}"
                })

            total_tests = FitnessTest.objects.filter(is_active=True).count()
            session = AssessmentSession.objects.create(
                athlete=athlete,
                session_name=f"Assessment {datetime.now().strftime('%Y-%m-%d %H:%M')}",
                status='created',
                total_tests=total_tests,
                device_info=request.data.get('device_info', {})
            )
            print(f"DEBUG: New session created: {session.id}")

            return Response({
                'session_id': session.id,
                'message': 'New assessment session started',
                'total_tests': session.total_tests,
                'available_tests': list(FitnessTest.objects.filter(is_active=True).values('id', 'name', 'display_name'))
            }, status=status.HTTP_201_CREATED)

        except AthleteProfile.DoesNotExist:
            print("DEBUG: Athlete profile not found")
            return Response({'error': 'Athlete profile not found'}, status=status.HTTP_404_NOT_FOUND)

    @action(detail=True, methods=['post'])
    def submit_to_sai(self, request, pk=None):
        print(f"DEBUG: submit_to_sai API called for session ID {pk}")
        session = self.get_object()
        print(f"DEBUG: Session status: {session.status}")

        if session.status != 'completed':
            print("DEBUG: Session not completed, cannot submit")
            return Response({'error': 'Assessment must be completed before submission'},
                            status=status.HTTP_400_BAD_REQUEST)

        existing_submission = SAISubmission.objects.filter(assessment_session=session).first()
        if existing_submission:
            print(f"DEBUG: Existing submission found: {existing_submission.sai_reference_id}")
            return Response({
                'sai_reference_id': existing_submission.sai_reference_id,
                'message': 'Already submitted to SAI',
                'status': existing_submission.status
            })

        submission = SAISubmission.objects.create(
            assessment_session=session,
            athlete=session.athlete,
            sai_reference_id=f"SAI{datetime.now().strftime('%Y%m%d')}{str(uuid.uuid4())[:8].upper()}",
            submitted_data=self.prepare_sai_submission_data(session)
        )
        print(f"DEBUG: New submission created: {submission.sai_reference_id}")

        session.status = 'submitted_to_sai'
        session.submitted_at = timezone.now()
        session.save()
        print("DEBUG: Session updated to submitted_to_sai")

        self.award_submission_badge(session.athlete)
        print("DEBUG: Badge awarding attempted")

        return Response({
            'sai_reference_id': submission.sai_reference_id,
            'message': 'Successfully submitted to SAI for review',
            'estimated_review_time': '5-7 business days'
        })

    def prepare_sai_submission_data(self, session):
        print(f"DEBUG: Preparing SAI submission data for session ID {session.id}")
        recordings = TestRecording.objects.filter(session=session, processing_status='completed')
        print(f"DEBUG: Recordings count: {recordings.count()}")

        return {
            'athlete_info': AthleteProfileSerializer(session.athlete).data,
            'session_summary': {
                'overall_score': float(session.overall_score) if session.overall_score else None,
                'overall_grade': session.overall_grade,
                'percentile_rank': float(session.percentile_rank) if session.percentile_rank else None,
                'completed_tests': session.completed_tests,
                'total_tests': session.total_tests
            },
            'test_results': [
                {
                    'test_name': rec.fitness_test.name,
                    'final_score': float(rec.final_score) if rec.final_score else None,
                    'performance_grade': rec.performance_grade,
                    'percentile': float(rec.percentile) if rec.percentile else None,
                    'ai_confidence': float(rec.ai_confidence) if rec.ai_confidence else None,
                    'cheat_detection_score': float(rec.cheat_detection_score) if rec.cheat_detection_score else None,
                    'is_suspicious': rec.is_suspicious,
                    'video_url': rec.original_video_url
                }
                for rec in recordings
            ],
            'submission_metadata': {
                'platform_version': '1.0',
                'submission_date': timezone.now().isoformat(),
                'device_info': session.device_info
            }
        }

    def award_submission_badge(self, athlete):
        print(f"DEBUG: Attempting to award submission badge to athlete {athlete}")
        try:
            submission_badge = Badge.objects.get(name='First SAI Submission')
            AthleteBadge.objects.get_or_create(athlete=athlete, badge=submission_badge)
            print("DEBUG: Badge awarded or already exists")
        except Badge.DoesNotExist:
            print("DEBUG: Badge 'First SAI Submission' does not exist")
            pass

class TestRecordingViewSet(viewsets.ModelViewSet):
    queryset = TestRecording.objects.all()
    serializer_class = TestRecordingSerializer
    parser_classes = [MultiPartParser, FormParser]
    
    def get_queryset(self):
        if not getattr(self.request, 'is_authenticated', False):
            return TestRecording.objects.none()
            
        user_role = getattr(self.request, 'user_role', 'authenticated')
        if user_role != 'sai_official':
            return TestRecording.objects.filter(athlete__auth_user_id=self.request.user_id)
        return TestRecording.objects.all()
    
    @action(detail=False, methods=['post'])
    def upload_video(self, request):
        """Handle video upload and trigger AI analysis"""
        serializer = VideoUploadSerializer(data=request.data)
        
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            # Get session and test info
            session = AssessmentSession.objects.get(id=serializer.validated_data['session_id'])
            fitness_test = FitnessTest.objects.get(id=serializer.validated_data['fitness_test_id'])
            video_file = serializer.validated_data['video_file']
            
            # Check if test already completed for this session
            existing_recording = TestRecording.objects.filter(
                session=session,
                fitness_test=fitness_test
            ).first()
            
            if existing_recording and existing_recording.processing_status == 'completed':
                return Response({
                    'error': 'Test already completed for this session',
                    'recording_id': existing_recording.id
                }, status=status.HTTP_400_BAD_REQUEST)
            
            # Save video to Supabase Storage
            video_url = self.save_to_supabase_storage(video_file)
            
            # Create or update test recording
            recording, created = TestRecording.objects.update_or_create(
                session=session,
                fitness_test=fitness_test,
                athlete=session.athlete,
                defaults={
                    'original_video_url': video_url,
                    'video_duration': serializer.validated_data.get('video_duration'),
                    'video_size_mb': video_file.size / (1024 * 1024),  # Convert to MB
                    'device_analysis_score': serializer.validated_data.get('device_analysis_score'),
                    'device_analysis_confidence': serializer.validated_data.get('device_analysis_confidence'),
                    'device_analysis_data': serializer.validated_data.get('device_analysis_data', {}),
                    'processing_status': 'uploaded'
                }
            )
            
            # Trigger AI analysis (async task)
            from .tasks import process_video_analysis
            process_video_analysis.delay(recording.id)
            
            # Update session progress
            if created:
                session.completed_tests += 1
                if session.status == 'created':
                    session.status = 'in_progress'
                
                # Check if all tests completed
                if session.completed_tests >= session.total_tests:
                    session.status = 'completed'
                    session.completed_at = timezone.now()
                    self.calculate_session_overall_score(session)
                
                session.save()
            
            return Response({
                'recording_id': recording.id,
                'status': 'uploaded',
                'message': 'Video uploaded successfully. AI analysis in progress.',
                'session_progress': f"{session.completed_tests}/{session.total_tests}",
                'estimated_analysis_time': self.estimate_analysis_time(fitness_test.name)
            })
            
        except AssessmentSession.DoesNotExist:
            return Response({'error': 'Assessment session not found'}, status=status.HTTP_404_NOT_FOUND)
        except FitnessTest.DoesNotExist:
            return Response({'error': 'Fitness test not found'}, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    @action(detail=True, methods=['get'])
    def analysis_status(self, request, pk=None):
        """Check analysis status and progress"""
        recording = self.get_object()
        
        # Calculate progress percentage based on status
        progress_map = {
            'uploaded': 10,
            'analyzing': 50,
            'cheat_checking': 80,
            'completed': 100,
            'failed': 0,
            'flagged': 100,
            'manually_verified': 100
        }
        
        response_data = {
            'recording_id': recording.id,
            'processing_status': recording.processing_status,
            'progress_percentage': progress_map.get(recording.processing_status, 0),
        }
        
        # Add results if analysis is complete
        if recording.processing_status in ['completed', 'manually_verified']:
            response_data.update({
                'final_score': recording.final_score,
                'performance_grade': recording.performance_grade,
                'percentile': recording.percentile,
                'points_earned': recording.points_earned,
                'ai_confidence': recording.ai_confidence,
                'benchmark_comparison': self.get_benchmark_comparison(recording)
            })
        
        # Add cheat detection info
        if recording.cheat_detection_score:
            response_data.update({
                'cheat_detection_score': recording.cheat_detection_score,
                'is_suspicious': recording.is_suspicious,
                'cheat_flags': recording.cheat_flags
            })
        
        # Add error info if failed
        if recording.processing_status == 'failed':
            response_data.update({
                'error_message': recording.processing_error,
                'retry_available': recording.retry_count < 3
            })
        
        return Response(response_data)
    
    @action(detail=True, methods=['post'])
    def retry_analysis(self, request, pk=None):
        """Retry failed video analysis"""
        recording = self.get_object()
        
        if recording.processing_status != 'failed' or recording.retry_count >= 3:
            return Response({
                'error': 'Retry not available for this recording'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Reset status and increment retry count
        recording.processing_status = 'uploaded'
        recording.retry_count += 1
        recording.processing_error = None
        recording.save()
        
        # Trigger analysis again
        from .tasks import process_video_analysis
        process_video_analysis.delay(recording.id)
        
        return Response({
            'message': 'Analysis retry initiated',
            'retry_count': recording.retry_count
        })
    
    def save_to_supabase_storage(self, video_file):
        """Save video file to Supabase storage"""
        # This would integrate with your Supabase storage
        # For now, returning a placeholder URL
        file_name = f"videos/{uuid.uuid4()}.mp4"
        # Implement actual Supabase storage upload here
        return f"https://your-supabase-storage-url.com/{file_name}"
    
    def estimate_analysis_time(self, test_name):
        """Estimate analysis time based on test type"""
        time_estimates = {
            'vertical_jump': '30-60 seconds',
            'situps': '1-2 minutes',
            'shuttle_run': '1-2 minutes',
            'endurance_run': '2-3 minutes',
            'height_weight': '10-20 seconds'
        }
        return time_estimates.get(test_name, '1-2 minutes')
    
    def calculate_session_overall_score(self, session):
        """Calculate overall session score when all tests are complete"""
        recordings = TestRecording.objects.filter(
            session=session,
            processing_status='completed'
        )
        
        if recordings.exists():
            # Calculate weighted average based on test importance
            total_points = sum(rec.points_earned or 0 for rec in recordings)
            avg_percentile = recordings.aggregate(avg_percentile=Avg('percentile'))['avg_percentile']
            
            session.overall_score = total_points / len(recordings) if recordings else 0
            session.percentile_rank = avg_percentile
            session.overall_grade = self.calculate_grade_from_score(session.overall_score)
            session.save()
            
            # Update athlete's overall talent score
            self.update_athlete_talent_score(session.athlete)
    
    def calculate_grade_from_score(self, score):
        """Convert score to grade"""
        if score >= 90: return 'A+'
        elif score >= 80: return 'A'
        elif score >= 70: return 'B+'
        elif score >= 60: return 'B'
        elif score >= 50: return 'C+'
        else: return 'C'
    
    def update_athlete_talent_score(self, athlete):
        """Update athlete's overall talent score"""
        completed_sessions = AssessmentSession.objects.filter(
            athlete=athlete,
            status='completed'
        )
        
        if completed_sessions.exists():
            avg_score = completed_sessions.aggregate(
                avg_score=Avg('overall_score')
            )['avg_score']
            
            athlete.overall_talent_score = avg_score
            athlete.talent_grade = self.calculate_grade_from_score(avg_score)
            athlete.save()
    
    def get_benchmark_comparison(self, recording):
        """Get benchmark comparison for the recording"""
        try:
            benchmark = AgeBenchmark.objects.filter(
                fitness_test=recording.fitness_test,
                age_min__lte=recording.athlete.age,
                age_max__gte=recording.athlete.age,
                gender=recording.athlete.gender
            ).first()
            
            if benchmark and recording.final_score:
                score = float(recording.final_score)
                
                # Determine performance category
                if score >= benchmark.excellent_threshold:
                    category = 'Excellent'
                elif score >= benchmark.good_threshold:
                    category = 'Good'
                elif score >= benchmark.average_threshold:
                    category = 'Average'
                else:
                    category = 'Below Average'
                
                return {
                    'athlete_score': score,
                    'benchmark_excellent': float(benchmark.excellent_threshold),
                    'benchmark_good': float(benchmark.good_threshold),
                    'benchmark_average': float(benchmark.average_threshold),
                    'benchmark_below_average': float(benchmark.below_average_threshold),
                    'performance_category': category,
                    'percentile': recording.percentile,
                    'points_earned': recording.points_earned
                }
        except Exception:
            pass
        
        return None

class LeaderboardViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Leaderboard.objects.all()
    serializer_class = LeaderboardSerializer
    
    @action(detail=False, methods=['get'])
    def national_rankings(self, request):
        """Get national leaderboard rankings"""
        test_id = request.query_params.get('test_id')
        age_group = request.query_params.get('age_group')
        gender = request.query_params.get('gender')
        limit = int(request.query_params.get('limit', 100))
        
        queryset = Leaderboard.objects.filter(leaderboard_type='national')
        
        if test_id:
            queryset = queryset.filter(fitness_test_id=test_id)
        if age_group:
            queryset = queryset.filter(age_group=age_group)
        if gender:
            queryset = queryset.filter(gender=gender)
        
        rankings = queryset.order_by('current_rank')[:limit]
        serializer = LeaderboardSerializer(rankings, many=True)
        
        return Response({
            'rankings': serializer.data,
            'total_participants': queryset.count(),
            'filters_applied': {
                'test_id': test_id,
                'age_group': age_group,
                'gender': gender
            }
        })
    
    @action(detail=False, methods=['get'])
    def state_rankings(self, request):
        """Get state-wise leaderboard rankings"""
        state = request.query_params.get('state')
        if not state:
            return Response({'error': 'State parameter required'}, 
                           status=status.HTTP_400_BAD_REQUEST)
        
        test_id = request.query_params.get('test_id')
        limit = int(request.query_params.get('limit', 50))
        
        queryset = Leaderboard.objects.filter(
            leaderboard_type='state',
            state=state
        )
        
        if test_id:
            queryset = queryset.filter(fitness_test_id=test_id)
        
        rankings = queryset.order_by('current_rank')[:limit]
        serializer = LeaderboardSerializer(rankings, many=True)
        
        return Response({
            'state': state,
            'rankings': serializer.data,
            'total_participants': queryset.count()
        })
    
    @action(detail=False, methods=['get'])
    def athlete_rankings(self, request):
        """Get specific athlete's rankings across all categories"""
        if not getattr(self.request, 'is_authenticated', False):
            return Response({'error': 'Authentication required'}, status=status.HTTP_401_UNAUTHORIZED)
            
        try:
            athlete = AthleteProfile.objects.get(auth_user_id=request.user_id)
            rankings = Leaderboard.objects.filter(athlete=athlete)
            serializer = LeaderboardSerializer(rankings, many=True)
            
            return Response({
                'athlete_name': athlete.full_name,
                'rankings': serializer.data,
                'summary': {
                    'best_national_rank': rankings.filter(leaderboard_type='national').aggregate(
                        best_rank=Min('current_rank')
                    )['best_rank'],
                    'total_competitions': rankings.count(),
                    'total_points': athlete.total_points
                }
            })
        except AthleteProfile.DoesNotExist:
            return Response({'error': 'Athlete profile not found'}, 
                           status=status.HTTP_404_NOT_FOUND)

class BadgeViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Badge.objects.filter(is_active=True)
    serializer_class = BadgeSerializer
    
    @action(detail=False, methods=['get'])
    def athlete_badges(self, request):
        """Get all badges earned by the current athlete"""
        if not getattr(self.request, 'is_authenticated', False):
            return Response({'error': 'Authentication required'}, status=status.HTTP_401_UNAUTHORIZED)
            
        try:
            athlete = AthleteProfile.objects.get(auth_user_id=request.user_id)
            earned_badges = AthleteBadge.objects.filter(athlete=athlete).select_related('badge')
            serializer = AthleteBadgeSerializer(earned_badges, many=True)
            
            # Get available badges not yet earned
            earned_badge_ids = earned_badges.values_list('badge_id', flat=True)
            available_badges = Badge.objects.filter(is_active=True).exclude(id__in=earned_badge_ids)
            
            return Response({
                'earned_badges': serializer.data,
                'available_badges': BadgeSerializer(available_badges, many=True).data,
                'total_points_from_badges': sum(badge.badge.points_reward for badge in earned_badges)
            })
        except AthleteProfile.DoesNotExist:
            return Response({'error': 'Athlete profile not found'}, 
                           status=status.HTTP_404_NOT_FOUND)

class SAISubmissionViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = SAISubmission.objects.all()
    serializer_class = SAISubmissionSerializer
    
    def get_queryset(self):
        if not getattr(self.request, 'is_authenticated', False):
            return SAISubmission.objects.none()
            
        # SAI officials see all, athletes see only their own
        user_role = getattr(self.request, 'user_role', 'authenticated')
        if user_role == 'sai_official':
            return SAISubmission.objects.all()
        return SAISubmission.objects.filter(athlete__auth_user_id=self.request.user_id)
    
    @action(detail=True, methods=['post'])
    def sai_review(self, request, pk=None):
        """SAI official review endpoint"""
        user_role = getattr(self.request, 'user_role', 'authenticated')
        if user_role != 'sai_official':
            return Response({'error': 'Access denied'}, status=status.HTTP_403_FORBIDDEN)
        
        submission = self.get_object()
        
        # Update submission with SAI review
        submission.status = request.data.get('status', submission.status)
        submission.sai_officer_id = request.user_email
        submission.sai_comments = request.data.get('comments', '')
        submission.talent_category = request.data.get('talent_category')
        submission.recommended_sports = request.data.get('recommended_sports', [])
        submission.reviewed_at = timezone.now()
        submission.save()
        
        # Update athlete verification status if approved
        if submission.status == 'approved':
            athlete = submission.athlete
            athlete.is_verified = True
            athlete.verification_status = 'verified'
            athlete.save()
        
        return Response({
            'message': 'Review completed successfully',
            'sai_reference_id': submission.sai_reference_id,
            'status': submission.status
        })

# Utility Views
class StatsViewSet(viewsets.ViewSet):
    """Platform statistics for dashboard"""
    
    @action(detail=False, methods=['get'])
    def platform_stats(self, request):
        """Get overall platform statistics"""
        stats = {
            'total_athletes': AthleteProfile.objects.count(),
            'total_assessments': AssessmentSession.objects.filter(status='completed').count(),
            'total_videos_analyzed': TestRecording.objects.filter(processing_status='completed').count(),
            'avg_talent_score': AthleteProfile.objects.aggregate(
                avg_score=Avg('overall_talent_score')
            )['avg_score'],
            'top_performing_states': list(
                AthleteProfile.objects.values('state')
                .annotate(avg_score=Avg('overall_talent_score'))
                .order_by('-avg_score')[:10]
            ),
            'recent_activity': {
                'new_athletes_this_week': AthleteProfile.objects.filter(
                    created_at__gte=timezone.now() - timedelta(days=7)
                ).count(),
                'assessments_this_week': AssessmentSession.objects.filter(
                    created_at__gte=timezone.now() - timedelta(days=7)
                ).count()
            }
        }
        
        return Response(stats)
    
    @action(detail=False, methods=['get'])
    def athlete_stats(self, request):
        """Get statistics for current athlete"""
        if not getattr(self.request, 'is_authenticated', False):
            return Response({'error': 'Authentication required'}, status=status.HTTP_401_UNAUTHORIZED)
            
        try:
            athlete = AthleteProfile.objects.get(auth_user_id=request.user_id)
            
            stats = {
                'personal_best_scores': list(
                    TestRecording.objects.filter(athlete=athlete, processing_status='completed')
                    .values('fitness_test__display_name')
                    .annotate(best_score=Max('final_score'))
                ),
                'assessment_history': list(
                    AssessmentSession.objects.filter(athlete=athlete)
                    .values('created_at', 'overall_score', 'overall_grade')
                    .order_by('-created_at')
                ),
                'badges_earned': AthleteBadge.objects.filter(athlete=athlete).count(),
                'current_level': athlete.level,
                'total_points': athlete.total_points,
                'rank_improvements': self.get_rank_improvements(athlete)
            }
            
            return Response(stats)
        except AthleteProfile.DoesNotExist:
            return Response({'error': 'Athlete profile not found'}, 
                           status=status.HTTP_404_NOT_FOUND)
    
    def get_rank_improvements(self, athlete):
        """Calculate rank improvements over time"""
        rankings = Leaderboard.objects.filter(athlete=athlete).exclude(previous_rank__isnull=True)
        improvements = []
        
        for ranking in rankings:
            if ranking.previous_rank and ranking.current_rank:
                improvement = ranking.previous_rank - ranking.current_rank
                improvements.append({
                    'test_name': ranking.fitness_test.display_name if ranking.fitness_test else 'Overall',
                    'improvement': improvement,
                    'current_rank': ranking.current_rank,
                    'previous_rank': ranking.previous_rank
                })
        
        return improvements

# Device Optimization View
@action(detail=False, methods=['post'])
def optimize_for_device(request):
    """Analyze device capabilities and provide optimization recommendations"""
    device_info = request.data.get('device_info', {})
    
    recommendations = {
        'video_quality': 'medium',
        'offline_analysis': False,
        'batch_upload': False,
        'compression_level': 'medium'
    }
    
    # Analyze device capabilities
    storage = device_info.get('available_storage_mb', 0)
    ram = device_info.get('ram_mb', 0)
    network_speed = device_info.get('network_speed_mbps', 0)
    
    # Adjust recommendations based on capabilities
    if storage > 2000 and ram > 3000:
        recommendations['video_quality'] = 'high'
        recommendations['offline_analysis'] = True
    elif storage < 500 or ram < 1000:
        recommendations['video_quality'] = 'low'
        recommendations['compression_level'] = 'high'
    
    if network_speed < 1:
        recommendations['batch_upload'] = True
        recommendations['offline_analysis'] = True
    
    return Response({
        'device_assessment': device_info,
        'recommendations': recommendations,
        'estimated_performance': {
            'upload_time_per_mb': max(10 / network_speed, 5) if network_speed > 0 else 30,
            'analysis_time_multiplier': 1.5 if ram < 2000 else 1.0,
            'storage_warning': storage < 1000
        }
    })

# Additional views to add to your views.py file

from django.http import JsonResponse
from django.shortcuts import render
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework.reverse import reverse
from rest_framework import status
import sys

@api_view(['GET'])
def api_root(request, format=None):
    """
    API root endpoint - provides links to all major endpoints
    """
    return Response({
        'message': 'Welcome to SAI Talent Assessment Platform API',
        'version': '1.0',
        'endpoints': {
            'athletes': reverse('athletes-list', request=request, format=format),
            'fitness_tests': reverse('fitness-tests-list', request=request, format=format),
            'assessment_sessions': reverse('assessment-sessions-list', request=request, format=format),
            'test_recordings': reverse('test-recordings-list', request=request, format=format),
            'leaderboards': reverse('leaderboards-list', request=request, format=format),
            'badges': reverse('badges-list', request=request, format=format),
            'sai_submissions': reverse('sai-submissions-list', request=request, format=format),
            'stats': reverse('stats-list', request=request, format=format),
            'documentation': reverse('api-docs', request=request, format=format),
        },
        'authentication': {
            'login': reverse('rest_framework:login', request=request, format=format),
            'logout': reverse('rest_framework:logout', request=request, format=format),
        },
        'utilities': {
            'device_optimization': request.build_absolute_uri('/api/v1/device/optimize/'),
            'health_check': reverse('health-check', request=request, format=format),
        }
    })

@api_view(['GET'])
def health_check(request):
    """
    Health check endpoint for monitoring and load balancers
    """
    from django.db import connection
    from django.core.cache import cache
    
    health_data = {
        'status': 'healthy',
        'timestamp': timezone.now().isoformat(),
        'version': '1.0',
        'services': {
            'database': 'unknown',
            'cache': 'unknown'
        }
    }
    
    # Check database connection
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
        health_data['services']['database'] = 'healthy'
    except Exception as e:
        health_data['services']['database'] = f'unhealthy: {str(e)}'
        health_data['status'] = 'degraded'
    
    # Check cache connection
    try:
        cache.set('health_check', 'test', 10)
        cache.get('health_check')
        health_data['services']['cache'] = 'healthy'
    except Exception as e:
        health_data['services']['cache'] = f'unhealthy: {str(e)}'
        health_data['status'] = 'degraded'
    
    # System info
    health_data['system'] = {
        'python_version': sys.version.split()[0],
        'django_version': '3.1.5',  # Update this to match your actual Django version
    }
    
    # Return appropriate HTTP status code
    status_code = 200 if health_data['status'] == 'healthy' else 503
    
    return Response(health_data, status=status_code)

@api_view(['POST'])
def optimize_for_device(request):
    """
    Analyze device capabilities and provide optimization recommendations
    This was referenced in your views.py but defined as a function, converting to proper view
    """
    device_info = request.data.get('device_info', {})
    
    recommendations = {
        'video_quality': 'medium',
        'offline_analysis': False,
        'batch_upload': False,
        'compression_level': 'medium'
    }
    
    # Analyze device capabilities
    storage = device_info.get('available_storage_mb', 0)
    ram = device_info.get('ram_mb', 0)
    network_speed = device_info.get('network_speed_mbps', 0)
    
    # Adjust recommendations based on capabilities
    if storage > 2000 and ram > 3000:
        recommendations['video_quality'] = 'high'
        recommendations['offline_analysis'] = True
    elif storage < 500 or ram < 1000:
        recommendations['video_quality'] = 'low'
        recommendations['compression_level'] = 'high'
    
    if network_speed < 1:
        recommendations['batch_upload'] = True
        recommendations['offline_analysis'] = True
    
    return Response({
        'device_assessment': device_info,
        'recommendations': recommendations,
        'estimated_performance': {
            'upload_time_per_mb': max(10 / network_speed, 5) if network_speed > 0 else 30,
            'analysis_time_multiplier': 1.5 if ram < 2000 else 1.0,
            'storage_warning': storage < 1000
        }
    })

# Error handlers
def custom_404(request, exception):
    """Custom 404 error handler"""
    return JsonResponse({
        'error': 'Not Found',
        'message': 'The requested resource was not found.',
        'status_code': 404,
        'available_endpoints': {
            'api_root': '/api/v1/',
            'documentation': '/api/docs/',
            'admin': '/admin/',
        }
    }, status=404)

def custom_500(request):
    """Custom 500 error handler"""
    return JsonResponse({
        'error': 'Internal Server Error',
        'message': 'An unexpected error occurred. Please try again later.',
        'status_code': 500,
        'support_contact': 'support@sai-talent-platform.gov.in'
    }, status=500)


# Django → Supabase Authentication Views
@csrf_exempt
@csrf_exempt
@api_view(['POST'])
@permission_classes([AllowAny])
def login(request):
    """Flutter → Django login endpoint that authenticates with Supabase"""
    try:
        from supabase import create_client, Client
        import os
        from datetime import datetime
        
        email = request.data.get('email')
        password = request.data.get('password')
        
        if not email or not password:
            return Response({
                'success': False,
                'message': 'Email and password are required'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Initialize Supabase client
        supabase_url = os.getenv('SUPABASE_URL')
        supabase_key = os.getenv('SUPABASE_ANON_KEY')
        supabase: Client = create_client(supabase_url, supabase_key)
        
        # Authenticate with Supabase
        try:
            auth_response = supabase.auth.sign_in_with_password({
                "email": email,
                "password": password
            })
            
            if not auth_response.user:
                return Response({
                    'success': False,
                    'message': 'Invalid email or password'
                }, status=status.HTTP_401_UNAUTHORIZED)
            
            user = auth_response.user
            session = auth_response.session
            
            # Get or create athlete profile in Django
            athlete, created = AthleteProfile.objects.get_or_create(
                auth_user_id=user.id,
                defaults={
                    'email': user.email,
                    'full_name': user.email.split('@')[0],  # Default name from email
                    'date_of_birth': datetime(2000, 1, 1).date(),
                    'gender': 'male',
                    'height': 0,
                    'weight': 0,
                    'age': 25,
                }
            )
            
            return Response({
                'success': True,
                'message': 'Login successful',
                'token': session.access_token,
                'athlete': AthleteProfileSerializer(athlete).data,
                'user_id': user.id,
                'email': user.email
            })
            
        except Exception as e:
            return Response({
                'success': False,
                'message': f'Authentication failed: {str(e)}'
            }, status=status.HTTP_401_UNAUTHORIZED)
            
    except Exception as e:
        return Response({
            'success': False,
            'message': f'Login error: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@csrf_exempt
@api_view(['POST'])
@permission_classes([AllowAny])
def register(request):
    """Flutter → Django registration endpoint that creates user in Supabase"""
    try:
        from supabase import create_client, Client
        import os
        from datetime import datetime
        
        # Extract registration data
        email = request.data.get('email')
        password = request.data.get('password')
        full_name = request.data.get('full_name')
        phone_number = request.data.get('phone_number')
        date_of_birth = request.data.get('date_of_birth')
        gender = request.data.get('gender', 'male')
        height = request.data.get('height', 0)
        weight = request.data.get('weight', 0)
        state = request.data.get('state', '')
        district = request.data.get('district', '')
        address = request.data.get('address', '')
        pincode = request.data.get('pincode', '')
        aadhaar_number = request.data.get('aadhaar_number', '')
        
        if not email or not password:
            return Response({
                'success': False,
                'message': 'Email and password are required'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Initialize Supabase client
        supabase_url = os.getenv('SUPABASE_URL')
        supabase_key = os.getenv('SUPABASE_ANON_KEY')
        supabase: Client = create_client(supabase_url, supabase_key)
        
        # Register with Supabase
        try:
            auth_response = supabase.auth.sign_up({
                "email": email,
                "password": password,
                "options": {
                    "email_confirm": False  # Skip email confirmation for development
                }
            })
            
            if not auth_response.user:
                return Response({
                    'success': False,
                    'message': 'Registration failed'
                }, status=status.HTTP_400_BAD_REQUEST)
            
            user = auth_response.user
            session = auth_response.session
            
            # For development: manually confirm the user
            # This bypasses the email confirmation step
            try:
                # Use admin API to confirm user
                from supabase.client import create_client
                admin_client = create_client(supabase_url, os.getenv('SUPABASE_SERVICE_ROLE_KEY', supabase_key))
                # Note: This would require service role key, but let's try with regular key first
            except Exception as e:
                print(f"Admin confirmation failed: {e}")
                # Continue anyway - user can manually confirm via email
            
            # Parse date of birth with default
            if isinstance(date_of_birth, str):
                try:
                    date_of_birth = datetime.strptime(date_of_birth, '%Y-%m-%d').date()
                except:
                    date_of_birth = datetime(2000, 1, 1).date()
            else:
                # Default date if None
                date_of_birth = datetime(2000, 1, 1).date()
            
            # Create athlete profile in Django
            athlete = AthleteProfile.objects.create(
                auth_user_id=user.id,
                email=user.email,
                full_name=full_name or user.email.split('@')[0],
                phone_number=phone_number or '',
                date_of_birth=date_of_birth,
                gender=gender,
                height=float(height) if height else 0,
                weight=float(weight) if weight else 0,
                state=state,
                district=district,
                address=address,
                pin_code=pincode,
                aadhaar_number=aadhaar_number or str(user.id)[:12],
                age=datetime.now().year - date_of_birth.year,
            )
            
            return Response({
                'success': True,
                'message': 'Registration successful',
                'token': session.access_token if session else None,
                'athlete': AthleteProfileSerializer(athlete).data,
                'user_id': user.id,
                'email': user.email
            }, status=status.HTTP_201_CREATED)
            
        except Exception as e:
            return Response({
                'success': False,
                'message': f'Registration failed: {str(e)}'
            }, status=status.HTTP_400_BAD_REQUEST)
            
    except Exception as e:
        return Response({
            'success': False,
            'message': f'Registration error: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@csrf_exempt
@api_view(['POST'])
@permission_classes([AllowAny])
def logout(request):
    """Flutter → Django logout endpoint"""
    try:
        # Get authorization header
        auth_header = request.META.get('HTTP_AUTHORIZATION')
        
        if auth_header and auth_header.startswith('Bearer '):
            token = auth_header.split(' ')[1]
            
            # Initialize Supabase client and sign out
            from supabase import create_client, Client
            import os
            
            supabase_url = os.getenv('SUPABASE_URL')
            supabase_key = os.getenv('SUPABASE_ANON_KEY')
            supabase: Client = create_client(supabase_url, supabase_key)
            
            try:
                # Set the session token and sign out
                supabase.auth.set_session(token, '')
                supabase.auth.sign_out()
            except:
                pass  # Ignore errors during sign out
        
        return Response({
            'success': True,
            'message': 'Logged out successfully'
        })
        
    except Exception as e:
        return Response({
            'success': True,  # Return success even if logout fails
            'message': 'Logged out'
        })

# Supabase Authentication Views (keep for compatibility)
@api_view(['POST'])
@permission_classes([AllowAny])
def supabase_profile_sync(request):
    """Sync user profile with Supabase authentication"""
    try:
        from datetime import datetime
        
        # This endpoint is called after successful Supabase authentication
        # to create or update athlete profile in Django
        user_id = request.data.get('user_id')
        user_email = request.data.get('email')
        profile_data = request.data.get('profile', {})
        
        if not user_id or not user_email:
            return Response({
                'error': 'Missing required fields: user_id, email'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Parse date of birth
        date_of_birth_str = profile_data.get('date_of_birth', '2000-01-01')
        if isinstance(date_of_birth_str, str):
            date_of_birth = datetime.strptime(date_of_birth_str, '%Y-%m-%d').date()
        else:
            date_of_birth = date_of_birth_str
        
        # Get or create athlete profile
        athlete, created = AthleteProfile.objects.get_or_create(
            auth_user_id=user_id,
            defaults={
                'email': user_email,
                'full_name': profile_data.get('full_name', ''),
                'phone_number': profile_data.get('phone_number', ''),
                'date_of_birth': date_of_birth,
                'gender': profile_data.get('gender', 'male'),
                'height': profile_data.get('height', 0),
                'weight': profile_data.get('weight', 0),
                'address': profile_data.get('address', ''),
                'state': profile_data.get('state', ''),
                'district': profile_data.get('district', ''),
                'pin_code': profile_data.get('pin_code', ''),
                'aadhaar_number': profile_data.get('aadhaar_number') or str(user_id)[:12],  # Truncate to 12 chars
                'location_category': profile_data.get('location_category', 'urban'),
                'age': profile_data.get('age', 0)
            }
        )        # If athlete profile already exists but needs updating
        if not created:
            for field, value in profile_data.items():
                if hasattr(athlete, field) and value:
                    setattr(athlete, field, value)
            athlete.save()
        
        return Response({
            'athlete_id': athlete.id,
            'message': 'Profile synced successfully' if not created else 'Profile created successfully',
            'created': created,
            'athlete': AthleteProfileSerializer(athlete).data
        })
        
    except Exception as e:
        return Response({
            'error': f'Profile sync failed: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['GET'])
@permission_classes([AllowAny])
def get_athlete_profile(request):
    """Get athlete profile by Supabase user ID"""
    user_id = request.GET.get('user_id')
    
    if not user_id:
        return Response({
            'error': 'user_id parameter required'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        athlete = AthleteProfile.objects.get(auth_user_id=user_id)
        return Response({
            'athlete': AthleteProfileSerializer(athlete).data
        })
    except AthleteProfile.DoesNotExist:
        return Response({
            'error': 'Athlete profile not found',
            'message': 'Please complete your profile setup'
        }, status=status.HTTP_404_NOT_FOUND)
