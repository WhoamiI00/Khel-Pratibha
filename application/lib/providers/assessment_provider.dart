// Updated AssessmentProvider with better error handling
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:math' as math;
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
    _clearError(); // Clear any previous errors
    
    try {
      print('DEBUG: AssessmentProvider - Starting to load fitness tests');
      final result = await _apiService.getFitnessTests();
      
      print('DEBUG: AssessmentProvider - API call completed');
      print('DEBUG: AssessmentProvider - Result success: ${result.success}');
      print('DEBUG: AssessmentProvider - Result error: ${result.error}');
      print('DEBUG: AssessmentProvider - Result data type: ${result.data?.runtimeType}');
      
      if (result.success && result.data != null) {
        final List<Map<String, dynamic>> apiData = result.data!;
        print('DEBUG: AssessmentProvider - Received ${apiData.length} fitness tests from API');
        
        _fitnessTests = [];
        int successfullyParsed = 0;
        
        for (int i = 0; i < apiData.length; i++) {
          try {
            print('DEBUG: AssessmentProvider - Processing fitness test $i');
            final testData = apiData[i];
            
            // Debug the structure of each test
            print('DEBUG: AssessmentProvider - Test $i data keys: ${testData.keys.toList()}');
            print('DEBUG: AssessmentProvider - Test $i ID: ${testData['id']}');
            print('DEBUG: AssessmentProvider - Test $i Name: ${testData['name']}');
            print('DEBUG: AssessmentProvider - Test $i Display Name: ${testData['display_name']}');
            
            final fitnessTest = FitnessTest.fromJson(testData);
            _fitnessTests.add(fitnessTest);
            successfullyParsed++;
            print('DEBUG: AssessmentProvider - Successfully parsed fitness test $i: ${fitnessTest.name} (Display: ${fitnessTest.displayName})');
          } catch (e, stackTrace) {
            print('ERROR: AssessmentProvider - Error parsing fitness test $i: $e');
            print('ERROR: Stack trace: $stackTrace');
            print('ERROR: Problematic test data: ${apiData[i]}');
            // Continue with other tests instead of failing completely
            continue;
          }
        }
        
        print('DEBUG: AssessmentProvider - Total successfully parsed tests: $successfullyParsed out of ${apiData.length}');
        
        if (_fitnessTests.isEmpty && apiData.isNotEmpty) {
          _setError('Failed to parse any fitness tests from API response');
        } else if (successfullyParsed < apiData.length) {
          print('WARNING: Some fitness tests failed to parse (${successfullyParsed}/${apiData.length} successful)');
        }
        
      } else {
        final errorMsg = result.error ?? 'Failed to load fitness tests - unknown error';
        print('ERROR: AssessmentProvider - API call failed: $errorMsg');
        _setError(errorMsg);
      }
    } catch (e, stackTrace) {
      print('ERROR: AssessmentProvider - Exception loading fitness tests: $e');
      print('ERROR: Stack trace: $stackTrace');
      _setError('Error loading fitness tests: $e');
    } finally {
      _setLoading(false);
      print('DEBUG: AssessmentProvider - loadFitnessTests completed. Final count: ${_fitnessTests.length}');
    }
  }

  Future<bool> startAssessment() async {
    _setLoading(true);
    _clearError();

    try {
      print('DEBUG: AssessmentProvider - Starting assessment');
      final result = await _apiService.startAssessment();
      
      print('DEBUG: AssessmentProvider - Start assessment result: ${result['success']}');
      
      if (result['success']) {
        final sessionData = result['data'];
        print('DEBUG: AssessmentProvider - Session data: $sessionData');
        
        _currentSession = AssessmentSession.fromJson({
          ...sessionData,
          'progress_percentage': sessionData['progress_percentage'] ?? 0.0,
        });
        
        print('DEBUG: AssessmentProvider - Created session: ${_currentSession?.id}');
        return true;
      } else {
        final errorMsg = result['error']?.toString() ?? 'Unknown error starting assessment';
        print('ERROR: AssessmentProvider - Start assessment failed: $errorMsg');
        _setError(errorMsg);
        return false;
      }
    } catch (e, stackTrace) {
      print('ERROR: AssessmentProvider - Exception starting assessment: $e');
      print('ERROR: Stack trace: $stackTrace');
      _setError('Error starting assessment: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAssessmentSessions() async {
    _setLoading(true);
    _clearError();
    
    try {
      print('DEBUG: AssessmentProvider - Loading assessment sessions');
      final result = await _apiService.getAssessmentSessions();
      
      print('DEBUG: AssessmentProvider - Sessions result: ${result['success']}');
      
      if (result['success']) {
        final data = result['data'];
        print('DEBUG: AssessmentProvider - Sessions data type: ${data.runtimeType}');
        print('DEBUG: AssessmentProvider - Sessions data: $data');
        
        if (data is List) {
          List<AssessmentSession> sessions = [];
          
          for (int i = 0; i < data.length; i++) {
            try {
              final sessionItem = data[i];
              if (sessionItem is Map<String, dynamic>) {
                final session = AssessmentSession.fromJson(sessionItem);
                sessions.add(session);
                print('DEBUG: AssessmentProvider - Parsed session $i: ${session.id} (${session.status})');
              } else {
                print('WARNING: AssessmentProvider - Session $i is not a Map: ${sessionItem.runtimeType}');
              }
            } catch (e) {
              print('ERROR: AssessmentProvider - Error parsing session $i: $e');
              continue;
            }
          }
          
          print('DEBUG: AssessmentProvider - Total sessions parsed: ${sessions.length}');
          
          // Set current session to the most recent in-progress session
          if (sessions.isNotEmpty) {
            try {
              _currentSession = sessions.firstWhere(
                (session) => ['created', 'in_progress'].contains(session.status),
              );
              print('DEBUG: AssessmentProvider - Found in-progress session: ${_currentSession!.id}');
            } catch (e) {
              // If no session with the desired status is found, use the first one
              _currentSession = sessions.first;
              print('DEBUG: AssessmentProvider - Using first session: ${_currentSession!.id}');
            }
          } else {
            _currentSession = null;
            print('DEBUG: AssessmentProvider - No sessions found');
          }
        } else {
          _currentSession = null;
          print('ERROR: AssessmentProvider - Sessions data is not a List: ${data.runtimeType}');
          _setError('Invalid assessment sessions data format');
        }
      } else {
        final errorMsg = result['error']?.toString() ?? 'Unknown error loading sessions';
        print('ERROR: AssessmentProvider - Load sessions failed: $errorMsg');
        _setError(errorMsg);
      }
    } catch (e, stackTrace) {
      print('ERROR: AssessmentProvider - Exception loading sessions: $e');
      print('ERROR: Stack trace: $stackTrace');
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
      print('ERROR: AssessmentProvider - No active session for video upload');
      _setError('No active assessment session');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      print('DEBUG: AssessmentProvider - Uploading video for test ID: $fitnessTestId');
      print('DEBUG: AssessmentProvider - Session ID: ${_currentSession!.id}');
      print('DEBUG: AssessmentProvider - Video file path: ${videoFile.path}');
      
      final result = await _apiService.uploadVideo(
        _currentSession!.id,
        fitnessTestId,
        videoFile,
        deviceAnalysisScore: deviceAnalysisScore,
        deviceAnalysisConfidence: deviceAnalysisConfidence,
        deviceAnalysisData: deviceAnalysisData,
      );
      
      print('DEBUG: AssessmentProvider - Upload result: ${result['success']}');
      
      if (result['success']) {
        // Update session progress
        final uploadData = result['data'];
        print('DEBUG: AssessmentProvider - Upload response data: $uploadData');
        
        final progressData = uploadData['session_progress'];
        print('DEBUG: AssessmentProvider - Progress data: $progressData (type: ${progressData.runtimeType})');
        
        int completed = 0;
        int total = 1;
        
        // Safely parse progress data with extensive debugging
        try {
          if (progressData != null) {
            if (progressData is String) {
              print('DEBUG: AssessmentProvider - Processing progress as String: "$progressData"');
              final progressParts = progressData.split('/');
              print('DEBUG: AssessmentProvider - Progress parts: $progressParts (length: ${progressParts.length})');
              
              if (progressParts.isNotEmpty) {
                final completedStr = progressParts[0].trim();
                completed = int.tryParse(completedStr) ?? 0;
                print('DEBUG: AssessmentProvider - Parsed completed: $completed from "$completedStr"');
              }
              if (progressParts.length > 1) {
                final totalStr = progressParts[1].trim();
                total = int.tryParse(totalStr) ?? 1;
                print('DEBUG: AssessmentProvider - Parsed total: $total from "$totalStr"');
              }
            } else if (progressData is Map) {
              print('DEBUG: AssessmentProvider - Processing progress as Map: $progressData');
              completed = int.tryParse(progressData['completed']?.toString() ?? '0') ?? 0;
              total = int.tryParse(progressData['total']?.toString() ?? '1') ?? 1;
              print('DEBUG: AssessmentProvider - Map parsed - completed: $completed, total: $total');
            } else if (progressData is int) {
              print('DEBUG: AssessmentProvider - Progress data is int: $progressData');
              completed = progressData;
              total = _fitnessTests.length; // Use total fitness tests as fallback
              print('DEBUG: AssessmentProvider - Using fitness tests length for total: $total');
            } else {
              print('DEBUG: AssessmentProvider - Unknown progress data type: ${progressData.runtimeType}');
              print('DEBUG: AssessmentProvider - Progress data value: $progressData');
            }
          } else {
            print('DEBUG: AssessmentProvider - Progress data is null, using current session data');
            completed = _currentSession!.completedTests + 1; // Increment current
            total = _currentSession!.totalTests;
          }
        } catch (e, stackTrace) {
          print('ERROR: AssessmentProvider - Progress parsing error: $e');
          print('ERROR: Stack trace: $stackTrace');
          print('ERROR: Progress data was: $progressData');
          // Fallback values
          completed = _currentSession!.completedTests + 1;
          total = _currentSession!.totalTests;
        }
        
        // Ensure total is never 0 to avoid division by zero
        if (total <= 0) {
          total = math.max(1, _fitnessTests.length);
          print('DEBUG: AssessmentProvider - Adjusted total to avoid zero: $total');
        }
        
        // Ensure completed doesn't exceed total
        completed = math.min(completed, total);
        
        final newProgressPercentage = (completed / total) * 100;
        final newStatus = completed >= total ? 'completed' : 'in_progress';
        
        print('DEBUG: AssessmentProvider - Final progress: $completed/$total = ${newProgressPercentage.toStringAsFixed(1)}%');
        print('DEBUG: AssessmentProvider - New status: $newStatus');
        
        _currentSession = AssessmentSession(
          id: _currentSession!.id,
          sessionName: _currentSession!.sessionName,
          status: newStatus,
          totalTests: total,
          completedTests: completed,
          createdAt: _currentSession!.createdAt,
          progressPercentage: newProgressPercentage,
        );
        
        print('DEBUG: AssessmentProvider - Session updated successfully');
        return true;
      } else {
        final errorMsg = result['error']?.toString() ?? 'Unknown upload error';
        print('ERROR: AssessmentProvider - Upload failed: $errorMsg');
        _setError(errorMsg);
        return false;
      }
    } catch (e, stackTrace) {
      print('ERROR: AssessmentProvider - Exception uploading video: $e');
      print('ERROR: Stack trace: $stackTrace');
      _setError('Error uploading video: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>?> checkAnalysisStatus(String recordingId) async {
    try {
      print('DEBUG: AssessmentProvider - Checking analysis status for: $recordingId');
      final result = await _apiService.getAnalysisStatus(recordingId);
      
      if (result['success']) {
        print('DEBUG: AssessmentProvider - Analysis status: ${result['data']}');
        return result['data'];
      } else {
        final errorMsg = result['error']?.toString() ?? 'Unknown analysis status error';
        print('ERROR: AssessmentProvider - Analysis status failed: $errorMsg');
        _setError(errorMsg);
        return null;
      }
    } catch (e, stackTrace) {
      print('ERROR: AssessmentProvider - Exception checking analysis status: $e');
      print('ERROR: Stack trace: $stackTrace');
      _setError('Error checking analysis status: $e');
      return null;
    }
  }

  Future<bool> submitToSAI() async {
    if (_currentSession == null || _currentSession!.status != 'completed') {
      final errorMsg = 'Assessment must be completed before submission. Current status: ${_currentSession?.status ?? 'no session'}';
      print('ERROR: AssessmentProvider - $errorMsg');
      _setError(errorMsg);
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      print('DEBUG: AssessmentProvider - Submitting to SAI: ${_currentSession!.id}');
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
        
        print('DEBUG: AssessmentProvider - Successfully submitted to SAI');
        return true;
      } else {
        final errorMsg = result['error']?.toString() ?? 'Unknown submission error';
        print('ERROR: AssessmentProvider - SAI submission failed: $errorMsg');
        _setError(errorMsg);
        return false;
      }
    } catch (e, stackTrace) {
      print('ERROR: AssessmentProvider - Exception submitting to SAI: $e');
      print('ERROR: Stack trace: $stackTrace');
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
    if (!_isLoading) {
      notifyListeners();
    }
  }

  // Method to manually retry loading fitness tests (useful for error recovery)
  Future<void> retryLoadFitnessTests() async {
    print('DEBUG: AssessmentProvider - Manual retry of fitness tests loading');
    _fitnessTests.clear();
    await loadFitnessTests();
  }

  // Method to reset the current session (useful for debugging)
  void resetSession() {
    print('DEBUG: AssessmentProvider - Resetting session');
    _currentSession = null;
    _clearError();
    notifyListeners();
  }

  // Method to get detailed debug info
  String getDebugInfo() {
    return '''
DEBUG INFO:
- Fitness tests loaded: ${_fitnessTests.length}
- Current session: ${_currentSession?.id ?? 'None'}
- Session status: ${_currentSession?.status ?? 'N/A'}
- Session progress: ${_currentSession?.completedTests ?? 0}/${_currentSession?.totalTests ?? 0}
- Is loading: $_isLoading
- Error message: ${_errorMessage ?? 'None'}
- Fitness test names: ${_fitnessTests.map((t) => t.name).join(', ')}
''';
  }
}