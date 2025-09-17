// lib/services/api_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import '../utils/constants.dart';
import '../utils/error_handler.dart';
import '../utils/env_config.dart';

class ApiService {
  // Use constants from ApiConstants class
  String get baseUrl => ApiConstants.apiBaseUrl;
  String get authUrl => ApiConstants.apiAuthUrl;
  
  // Headers for API requests
  Map<String, String> get headers => {
    'Content-Type': 'application/json', 
    'Accept': 'application/json',
  };

  Map<String, String> get authHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer ${_jwtToken ?? EnvConfig.supabaseJwtToken}',
  };

  String? _jwtToken;

  // Constructor - automatically set JWT token from environment
  ApiService() {
    // Set the JWT token from environment config on initialization
    _jwtToken = EnvConfig.supabaseJwtToken;
  }

  // Set JWT token for authentication
  void setJWTToken(String token) {
    _jwtToken = token;
  }

  // Clear authentication token
  void clearToken() {
    _jwtToken = null;
  }

  // Test backend connection
  Future<Map<String, dynamic>> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health-check/'),
        headers: headers,
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'message': 'Connection successful'};
      } else {
        return {'success': false, 'message': 'Connection failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Initialize token from storage and test connection
  Future<ApiResponse<String>> init() async {
    try {
      // JWT tokens are now managed by SupabaseService, not stored locally
      // Just test the connection
      
      // Simple connection test
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/'),
          headers: headers,
        ).timeout(const Duration(seconds: 5));
        
        if (response.statusCode >= 200 && response.statusCode < 300) {
          print('API connection successful');
          return ApiResponse.success('API connection successful');
        } else {
          return ApiResponse.error(
            'API connection failed with status code: ${response.statusCode}',
            errorType: 'http'
          );
        }
      } catch (e) {
        return ApiResponse.error(
          'API connection failed: ${e.toString()}',
          errorType: 'connection'
        );
      }
    } catch (e) {
      print('API initialization error: $e');
      final error = ErrorHandler.handleException(e);
      return ApiResponse.error(
        'API connection error: ${error.message}',
        errorType: error.type
      );
    }
  }

  // JWT tokens are now managed by Supabase, these methods are kept for compatibility
  Future<void> _saveToken(String token) async {
    // JWT tokens are managed by Supabase - no local storage needed
    setJWTToken(token);
  }

  // Remove token from storage
  Future<void> _removeToken() async {
    // JWT tokens are managed by Supabase - just clear local reference
    clearToken();
  }

  // Helper method to handle HTTP requests with proper error handling
  Future<ApiResponse<T>> _safeApiCall<T>(Future<http.Response> Function() apiCall, [T Function(dynamic)? dataConverter]) async {
    try {
      final response = await apiCall();
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = dataConverter != null ? dataConverter(responseData) : responseData as T;
        return ApiResponse<T>.success(data);
      } else {
        String errorMessage = 'Server error';
        if (responseData is Map && responseData.containsKey('error')) {
          errorMessage = responseData['error'].toString();
        } else if (responseData is Map && responseData.containsKey('detail')) {
          errorMessage = responseData['detail'].toString();
        }
        return ApiResponse<T>.error(
          errorMessage,
          statusCode: response.statusCode,
          errorType: 'http',
        );
      }
    } catch (e) {
      print('API call error: $e');
      String errorType = 'unknown';
      String errorMessage = 'An unexpected error occurred';
      
      if (e is SocketException) {
        errorType = 'socket';
        errorMessage = 'Network connection error. Please check your internet connection.';
      } else if (e is HttpException) {
        errorType = 'http';
        errorMessage = 'HTTP error. Could not find the requested resource.';
      } else if (e is FormatException) {
        errorType = 'format';
        errorMessage = 'Invalid response format. Please try again later.';
      } else if (e is TimeoutException) {
        errorType = 'timeout';
        errorMessage = 'Request timed out. Please try again later.';
      } else {
        errorMessage = 'An unexpected error occurred: $e';
      }
      
      return ApiResponse<T>.error(errorMessage, errorType: errorType);
    }
  }
  
  // Authentication Methods
  Future<ApiResponse<Map<String, dynamic>>> login(String username, String password) async {
    final response = await _safeApiCall<Map<String, dynamic>>(() => http.post(
        Uri.parse('$authUrl/login/'),
        headers: headers,
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(ApiConstants.requestTimeout));
      
    if (response.success && response.data != null && response.data!.containsKey('token')) {
      await _saveToken(response.data!['token']);
    }
    
    return response;
  }

  Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$authUrl/logout/'),
        headers: authHeaders,
      );
    } catch (e) {
      print('Logout error: $e');
    } finally {
      await _removeToken();
    }
  }

  // Athlete Profile Methods
  Future<ApiResponse<Map<String, dynamic>>> registerAthlete(Map<String, dynamic> athleteData) async {
    return _safeApiCall<Map<String, dynamic>>(() => http.post(
      Uri.parse('$baseUrl/athletes/register_athlete/'),
      headers: authHeaders,
      body: jsonEncode(athleteData),
    ).timeout(ApiConstants.requestTimeout));
  }
  
  // Get current user profile
  Future<ApiResponse<Map<String, dynamic>>> getCurrentUser() async {
    if (_jwtToken == null) {
      return ApiResponse.error('Not authenticated', errorType: 'auth');
    }
    
    return _safeApiCall<Map<String, dynamic>>(() => http.get(
      Uri.parse('$baseUrl/athletes/me/'),
      headers: authHeaders,
    ).timeout(ApiConstants.requestTimeout));
  }

  Future<ApiResponse<Map<String, dynamic>>> getAthleteProfile() async {
  try {
    print('DEBUG: Fetching athlete profile from ${baseUrl}/athletes/');
    final response = await http.get(
      Uri.parse('$baseUrl/athletes/'),
      headers: authHeaders,
    ).timeout(ApiConstants.requestTimeout);

    print('DEBUG: Response status code: ${response.statusCode}');
    final data = json.decode(response.body);
    print('DEBUG: Response data type: ${data.runtimeType}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Handle both direct list and wrapped response formats
      if (data is Map && data.containsKey('results')) {
        print('DEBUG: Athlete profile has results wrapper');
        return ApiResponse.success({'results': data['results']});
      } else if (data is List) {
        print('DEBUG: Athlete profile is direct list');
        return ApiResponse.success({'results': data});
      } else {
        print('DEBUG: Athlete profile format: Map without results key');
        return ApiResponse.success(data);
      }
    } else {
      return ApiResponse.error('Failed to load athlete profile: ${response.statusCode}');
    }
  } catch (e, stackTrace) {
    print('DEBUG: Exception in getAthleteProfile: $e');
    print('DEBUG: Stack trace: $stackTrace');
    return ApiResponse.error('Exception in getAthleteProfile: $e');
  }
}

  Future<ApiResponse<Map<String, dynamic>>> updateAthleteProfile(String athleteId, Map<String, dynamic> updateData) async {
    return _safeApiCall<Map<String, dynamic>>(() => http.patch(
      Uri.parse('$baseUrl/athletes/$athleteId/'),
      headers: authHeaders,
      body: jsonEncode(updateData),
    ).timeout(ApiConstants.requestTimeout));
  }
  
  // Health check method to test connection to backend
  Future<ApiResponse<Map<String, dynamic>>> healthCheck() async {
    try {
      // Try multiple endpoints to check connectivity
      final endpoints = [
        '$baseUrl/health/',
        '$baseUrl/',
        '$authUrl/'
      ];
      
      for (final endpoint in endpoints) {
        try {
          final response = await http.get(
            Uri.parse(endpoint),
            headers: headers,
          ).timeout(const Duration(seconds: 5));
          
          if (response.statusCode >= 200 && response.statusCode < 300) {
            return ApiResponse.success({
              'endpoint': endpoint,
              'status': response.statusCode,
              'message': 'Connection successful'
            });
          }
        } catch (e) {
          // Continue to next endpoint if this one fails
          continue;
        }
      }
      
      // If all endpoints failed
      return ApiResponse.error(
        'Could not connect to any backend endpoint',
        errorType: 'connection',
        statusCode: 0
      );
    } catch (e) {
      print('Health check error: $e');
      final error = ErrorHandler.handleException(e);
      return ApiResponse.error(
        error.message,
        errorType: error.type,
        statusCode: 0
      );
    }
  }

  // Fitness Tests Methods
  // Updated getFitnessTests method
Future<ApiResponse<List<Map<String, dynamic>>>> getFitnessTests() async {
  try {
    print('DEBUG: Fetching fitness tests from ${baseUrl}/fitness-tests/');
    print('DEBUG: Using headers: $authHeaders');
    final response = await http.get(
      Uri.parse('${baseUrl}/fitness-tests/'),
      headers: authHeaders,
    );

    print('DEBUG: Response status code: ${response.statusCode}');
    print('DEBUG: Response body length: ${response.body.length}');
    
    // Check if response is HTML (indicates 404 or server error page)
    if (response.body.trim().startsWith('<!DOCTYPE html') || response.body.trim().startsWith('<html')) {
      print('DEBUG: Received HTML response instead of JSON - likely a 404 or server error page');
      print('DEBUG: First 200 characters of response: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
      return ApiResponse.error('Server returned HTML page instead of JSON data. Check API endpoint URL.');
    }
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('DEBUG: Decoded data type: ${data.runtimeType}');
      
      // Safe substring to avoid index errors
      final dataStr = data.toString();
      final maxLen = dataStr.length > 500 ? 500 : dataStr.length;
      print('DEBUG: Raw API response structure: ${dataStr.substring(0, maxLen)}');

      // Handle both cases: direct list or wrapped in results object
      List<dynamic> results;
      
      if (data is List) {
        print('DEBUG: API returned direct list format');
        results = data;
      } else if (data is Map && data.containsKey('results')) {
        print('DEBUG: API returned wrapped format with results key');
        results = data['results'];
      } else {
        print('DEBUG: Unexpected API response format');
        print('DEBUG: Data type: ${data.runtimeType}');
        if (data is Map) {
          print('DEBUG: Map keys: ${data.keys.toList()}');
        }
        return ApiResponse.error('Unexpected API response format');
      }
      
      print('DEBUG: Results list length: ${results.length}');
      print('DEBUG: Results type: ${results.runtimeType}');
      
      if (results.isNotEmpty) {
        print('DEBUG: First result type: ${results[0].runtimeType}');
        final firstResultStr = results[0].toString();
        final firstMaxLen = firstResultStr.length > 300 ? 300 : firstResultStr.length;
        print('DEBUG: First result structure: ${firstResultStr.substring(0, firstMaxLen)}');
      }
      
      List<Map<String, dynamic>> fitnessTests = [];
      for (int i = 0; i < results.length; i++) {
        try {
          print('DEBUG: Processing fitness test $i');
          
          // Ensure each item is a Map<String, dynamic>
          if (results[i] is Map<String, dynamic>) {
            final Map<String, dynamic> testData = results[i] as Map<String, dynamic>;
            fitnessTests.add(testData);
            print('DEBUG: Successfully parsed fitness test $i: ${testData['name'] ?? 'Unknown'}');
          } else {
            print('DEBUG: Item $i is not a Map<String, dynamic>: ${results[i].runtimeType}');
            print('DEBUG: Item $i content: ${results[i]}');
            // Try to convert to Map if possible
            try {
              final Map<String, dynamic> testData = Map<String, dynamic>.from(results[i]);
              fitnessTests.add(testData);
              print('DEBUG: Successfully converted and parsed fitness test $i');
            } catch (conversionError) {
              print('DEBUG: Failed to convert item $i to Map: $conversionError');
              continue; // Skip this item and continue with others
            }
          }
        } catch (e, stackTrace) {
          print('DEBUG: Error parsing fitness test $i: $e');
          print('DEBUG: Stack trace: $stackTrace');
          print('DEBUG: Problematic JSON: ${results[i]}');
          // Continue with other items instead of failing completely
          continue;
        }
      }
      
      print('DEBUG: Successfully processed ${fitnessTests.length} out of ${results.length} fitness tests');
      return ApiResponse.success(fitnessTests);
    } else {
      print('DEBUG: HTTP error - Status code: ${response.statusCode}');
      print('DEBUG: Response body: ${response.body}');
      return ApiResponse.error('Failed to load fitness tests: HTTP ${response.statusCode}');
    }
  } catch (e, stackTrace) {
    print('DEBUG: Exception in getFitnessTests: $e');
    print('DEBUG: Stack trace: $stackTrace');
    return ApiResponse.error('Exception in getFitnessTests: $e');
  }
}

  Future<Map<String, dynamic>> getBenchmarks(int testId, int age, String gender) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/fitness-tests/$testId/benchmarks/?age=$age&gender=$gender'),
        headers: authHeaders,
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Assessment Session Methods
  Future<Map<String, dynamic>> startAssessment() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/assessment-sessions/start_assessment/'),
        headers: authHeaders,
        body: jsonEncode({
          'device_info': await _getDeviceInfo(),
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getAssessmentSessions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/assessment-sessions/'),
        headers: authHeaders,
      );
      print(response);
      print(response.headers);
      print(response.body);
      final data = jsonDecode(response.body);
      print('DEBUG: getAssessmentSessions data type: ${data.runtimeType}');
      
      if (response.statusCode == 200) {
        // Support both list response and paginated { results: [...] } response
        List<dynamic> results;
        if (data is List) {
          results = data;
        } else if (data is Map && data.containsKey('results')) {
          final res = data['results'];
          if (res is List) {
            results = res;
          } else {
            // Unexpected shape, treat as empty list to avoid runtime errors
            results = const [];
          }
        } else {
          // Unknown shape, log and treat as empty
          print('DEBUG: Unexpected sessions response shape: ${data.runtimeType}');
          results = const [];
        }

        return {'success': true, 'data': results};
      } else {
        return {'success': false, 'error': data};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> submitToSAI(String sessionId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/assessment-sessions/$sessionId/submit_to_sai/'),
        headers: authHeaders,
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Video Upload Methods
  Future<Map<String, dynamic>> uploadVideo(
    String sessionId,
    int fitnessTestId,
    File videoFile, {
    double? deviceAnalysisScore,
    double? deviceAnalysisConfidence,
    Map<String, dynamic>? deviceAnalysisData,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/test-recordings/upload_video/'),
      );

      // Add headers
      request.headers.addAll(authHeaders);

      // Add fields
      request.fields['session_id'] = sessionId;
      request.fields['fitness_test_id'] = fitnessTestId.toString();

      if (deviceAnalysisScore != null) {
        request.fields['device_analysis_score'] = deviceAnalysisScore.toString();
      }
      if (deviceAnalysisConfidence != null) {
        request.fields['device_analysis_confidence'] = deviceAnalysisConfidence.toString();
      }
      if (deviceAnalysisData != null) {
        request.fields['device_analysis_data'] = jsonEncode(deviceAnalysisData);
      }
      request.fields['device_info'] = jsonEncode(await _getDeviceInfo());

      // Add video file
      request.files.add(await http.MultipartFile.fromPath(
        'video_file',
        videoFile.path,
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data};
      }
    } catch (e) {
      return {'success': false, 'error': 'Upload error: $e'};
    }
  }

  Future<Map<String, dynamic>> getAnalysisStatus(String recordingId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/test-recordings/$recordingId/analysis_status/'),
        headers: authHeaders,
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Leaderboard Methods
  Future<Map<String, dynamic>> getNationalRankings({
    int? testId,
    String? ageGroup,
    String? gender,
    int limit = 100,
  }) async {
    try {
      var queryParams = <String, String>{
        'limit': limit.toString(),
      };
      
      if (testId != null) queryParams['test_id'] = testId.toString();
      if (ageGroup != null) queryParams['age_group'] = ageGroup;
      if (gender != null) queryParams['gender'] = gender;

      final uri = Uri.parse('$baseUrl/leaderboards/national_rankings/')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: authHeaders);
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getStateRankings(String state, {int? testId}) async {
    try {
      var queryParams = <String, String>{'state': state};
      if (testId != null) queryParams['test_id'] = testId.toString();

      final uri = Uri.parse('$baseUrl/leaderboards/state_rankings/')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: authHeaders);
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getAthleteRankings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/leaderboards/athlete_rankings/'),
        headers: authHeaders,
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Badge Methods
  Future<Map<String, dynamic>> getAthleteBadges() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/badges/athlete_badges/'),
        headers: authHeaders,
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Statistics Methods
  Future<Map<String, dynamic>> getAthleteStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stats/athlete_stats/'),
        headers: authHeaders,
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getPlatformStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stats/platform_stats/'),
        headers: authHeaders,
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Device Optimization
  Future<Map<String, dynamic>> optimizeForDevice() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/device/optimize/'),
        headers: authHeaders,
        body: jsonEncode({
          'device_info': await _getDeviceInfo(),
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Health Check method removed to avoid duplicate declaration

  // Helper method to get device info
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    return {
      'platform': Platform.operatingSystem,
      'version': Platform.operatingSystemVersion,
      'device_type': Platform.isAndroid ? 'android' : 'ios',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Check if user is authenticated
  bool get isAuthenticated => _jwtToken != null && _jwtToken!.isNotEmpty;
}