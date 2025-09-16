import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/assessment_session.dart';
import '../models/fitness_test.dart';
import '../models/test_recording.dart';
import '../services/api_service.dart';

class AssessmentProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  // Constructor - ensure API service is initialized with JWT token
  AssessmentProvider() {
    // The API service now automatically sets the JWT token from environment
    print('DEBUG: AssessmentProvider initialized with API service');
  }
  
  List<FitnessTest> _fitnessTests = [];
  AssessmentSession? _currentSession;
  List<TestRecording> _testRecordings = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<FitnessTest> get fitnessTests => _fitnessTests;
  AssessmentSession? get currentSession => _currentSession;
  List<TestRecording> get testRecordings => _testRecordings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadFitnessTests() async {
    _setLoading(true);
    
    try {
      print('DEBUG: AssessmentProvider - Starting to load fitness tests');
      final result = await _apiService.getFitnessTests();
      
      if (result.success && result.data != null) {
        print('DEBUG: AssessmentProvider - Received ${result.data!.length} fitness tests from API');
        
        _fitnessTests = [];
        for (int i = 0; i < result.data!.length; i++) {
          try {
            print('DEBUG: AssessmentProvider - Processing fitness test $i');
            final testData = result.data![i];
            print('DEBUG: AssessmentProvider - Test data keys: ${testData.keys.toList()}');
            print('DEBUG: AssessmentProvider - Test data: ${testData.toString().substring(0, testData.toString().length > 200 ? 200 : testData.toString().length)}');
            
            final fitnessTest = FitnessTest.fromJson(testData);
            _fitnessTests.add(fitnessTest);
            print('DEBUG: AssessmentProvider - Successfully parsed fitness test $i: ${fitnessTest.name}');
          } catch (e) {
            print('DEBUG: AssessmentProvider - Error parsing fitness test $i: $e');
            print('DEBUG: AssessmentProvider - Problematic test data: ${result.data![i]}');
            // Continue with other tests instead of failing completely
          }
        }
        
        print('DEBUG: AssessmentProvider - Total successfully parsed tests: ${_fitnessTests.length}');
      } else {
        _setError(result.error ?? 'Failed to load fitness tests');
        print('DEBUG: AssessmentProvider - API response error: ${result.error}');
      }
    } catch (e) {
      print('DEBUG: AssessmentProvider - Exception loading fitness tests: $e');
      _setError('Error loading fitness tests: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> startAssessment() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _apiService.startAssessment();
      
      if (result['success']) {
        _currentSession = AssessmentSession.fromJson({
          ...result['data'],
          'progress_percentage': 0.0,
        });
        return true;
      } else {
        _setError(result['error'].toString());
        return false;
      }
    } catch (e) {
      _setError('Error starting assessment: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAssessmentSessions() async {
    _setLoading(true);
    
    try {
      final result = await _apiService.getAssessmentSessions();
      
      if (result['success']) {
        final data = result['data'];
        if (data is List) {
          final sessions = data
              .map((item) {
                try {
                  return AssessmentSession.fromJson(item as Map<String, dynamic>);
                } catch (e) {
                  print('Error parsing assessment session: $e');
                  return null;
                }
              })
              .where((session) => session != null)
              .cast<AssessmentSession>()
              .toList();
          
          // Set current session to the most recent in-progress session
          if (sessions.isNotEmpty) {
            try {
              _currentSession = sessions.firstWhere(
                (session) => ['created', 'in_progress'].contains(session.status),
              );
            } catch (e) {
              // If no session with the desired status is found, use the first one
              _currentSession = sessions.first;
            }
          } else {
            _currentSession = null;
          }
        } else {
          _currentSession = null;
          _setError('Invalid assessment sessions data format');
        }
      } else {
        _setError(result['error'].toString());
      }
    } catch (e) {
      _setError('Error loading assessment sessions: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> uploadVideo(
    int fitnessTestId,
    File videoFile, {
    double? deviceAnalysisScore,
    double? deviceAnalysisConfidence,
    Map<String, dynamic>? deviceAnalysisData,
  }) async {
    if (_currentSession == null) {
      _setError('No active assessment session');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final result = await _apiService.uploadVideo(
        _currentSession!.id,
        fitnessTestId,
        videoFile,
        deviceAnalysisScore: deviceAnalysisScore,
        deviceAnalysisConfidence: deviceAnalysisConfidence,
        deviceAnalysisData: deviceAnalysisData,
      );
      
      if (result['success']) {
        // Update session progress
        final progressData = result['data']['session_progress'];
        
        int completed = 0;
        int total = 1;
        
        // Safely parse progress data
        try {
          print('DEBUG: progressData = $progressData (type: ${progressData.runtimeType})');
          
          if (progressData != null) {
            if (progressData is String) {
              print('DEBUG: Processing progress as String: $progressData');
              final progressParts = progressData.split('/');
              print('DEBUG: progressParts = $progressParts, length = ${progressParts.length}');
              
              if (progressParts.isNotEmpty) {
                final part0 = progressParts[0];
                print('DEBUG: progressParts[0] = $part0 (type: ${part0.runtimeType})');
                completed = int.tryParse(part0) ?? 0;
                print('DEBUG: parsed completed = $completed');
              }
              if (progressParts.length > 1) {
                final part1 = progressParts[1];
                print('DEBUG: progressParts[1] = $part1 (type: ${part1.runtimeType})');
                total = int.tryParse(part1) ?? 1;
                print('DEBUG: parsed total = $total');
              }
            } else if (progressData is Map) {
              print('DEBUG: Processing progress as Map: $progressData');
              completed = int.tryParse(progressData['completed']?.toString() ?? '0') ?? 0;
              total = int.tryParse(progressData['total']?.toString() ?? '1') ?? 1;
              print('DEBUG: Map parsed - completed: $completed, total: $total');
            } else {
              print('DEBUG: Unknown progressData type: ${progressData.runtimeType}');
            }
          }
        } catch (e, stackTrace) {
          print('ERROR in progress parsing: $e');
          print('Stack trace: $stackTrace');
          print('progressData was: $progressData');
        }
        
        // Ensure total is never 0 to avoid division by zero
        if (total == 0) total = 1;
        
        _currentSession = AssessmentSession(
          id: _currentSession!.id,
          sessionName: _currentSession!.sessionName,
          status: completed >= total ? 'completed' : 'in_progress',
          totalTests: total,
          completedTests: completed,
          createdAt: _currentSession!.createdAt,
          progressPercentage: (completed / total) * 100,
        );
        
        return true;
      } else {
        _setError(result['error'].toString());
        return false;
      }
    } catch (e) {
      _setError('Error uploading video: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>?> checkAnalysisStatus(String recordingId) async {
    try {
      final result = await _apiService.getAnalysisStatus(recordingId);
      
      if (result['success']) {
        return result['data'];
      } else {
        _setError(result['error'].toString());
        return null;
      }
    } catch (e) {
      _setError('Error checking analysis status: $e');
      return null;
    }
  }

  Future<bool> submitToSAI() async {
    if (_currentSession == null || _currentSession!.status != 'completed') {
      _setError('Assessment must be completed before submission');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final result = await _apiService.submitToSAI(_currentSession!.id);
      
      if (result['success']) {
        // Update session status
        _currentSession = AssessmentSession(
          id: _currentSession!.id,
          sessionName: _currentSession!.sessionName,
          status: 'submitted_to_sai',
          totalTests: _currentSession!.totalTests,
          completedTests: _currentSession!.completedTests,
          createdAt: _currentSession!.createdAt,
          progressPercentage: _currentSession!.progressPercentage,
          submittedAt: DateTime.now(),
        );
        
        return true;
      } else {
        _setError(result['error'].toString());
        return false;
      }
    } catch (e) {
      _setError('Error submitting to SAI: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
