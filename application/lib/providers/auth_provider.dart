import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/athlete_profile.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _token;
  bool _isAuthenticated = false;
  AthleteProfile? _currentAthlete;

  // Django backend URL - Use your Django server IP
  static const String _baseUrl = 'http://172.27.75.222:8000/api/auth';

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get token => _token;
  AthleteProfile? get currentAthlete => _currentAthlete;

  // Constructor - load saved session
  AuthProvider() {
    _loadUserSession();
  }

  // Load user session from storage
  Future<void> _loadUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final athleteJson = prefs.getString('current_athlete');
      
      if (token != null && athleteJson != null) {
        _token = token;
        _currentAthlete = AthleteProfile.fromJson(jsonDecode(athleteJson));
        _isAuthenticated = true;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading user session: $e');
    }
  }

  // Login method - calls Django backend
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _token = data['token'];
        _currentAthlete = AthleteProfile.fromJson(data['athlete']);
        _isAuthenticated = true;
        
        await _saveUserSession();
        
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError(data['message'] ?? 'Login failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Registration method - calls Django backend
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
    String? dateOfBirth,
    String? gender,
    double? height,
    double? weight,
    String? state,
    String? district,
    String? address,
    String? pincode,
    String? aadhaarNumber,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'full_name': fullName,
          'phone_number': phoneNumber,
          'date_of_birth': dateOfBirth,
          'gender': gender,
          'height': height,
          'weight': weight,
          'state': state,
          'district': district,
          'address': address,
          'pincode': pincode,
          'aadhaar_number': aadhaarNumber,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _token = data['token'];
        _currentAthlete = AthleteProfile.fromJson(data['athlete']);
        _isAuthenticated = true;
        
        await _saveUserSession();
        
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError(data['message'] ?? 'Registration failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Logout method
  Future<bool> logout() async {
    _token = null;
    _currentAthlete = null;
    _isAuthenticated = false;
    
    await _clearUserSession();
    notifyListeners();
    return true;
  }

  // Test backend connection
  Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('http://172.27.75.222:8000/health/'),
        headers: {'Content-Type': 'application/json'},
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }

  // Save user session to storage
  Future<void> _saveUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_token != null && _currentAthlete != null) {
        await prefs.setString('auth_token', _token!);
        await prefs.setString('current_athlete', jsonEncode(_currentAthlete!.toJson()));
      }
    } catch (e) {
      print('Error saving user session: $e');
    }
  }

  // Clear user session from storage
  Future<void> _clearUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('current_athlete');
    } catch (e) {
      print('Error clearing user session: $e');
    }
  }

  // Helper methods
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

  // Initialize app - test connection and load session
  Future<Map<String, dynamic>> init() async {
    try {
      // Test backend connection
      final connectionSuccess = await testConnection();
      if (!connectionSuccess) {
        return {'success': false, 'message': 'Cannot connect to backend server'};
      }
      
      // Load user session
      await _loadUserSession();
      
      return {'success': true, 'message': 'Initialization successful'};
    } catch (e) {
      return {'success': false, 'message': 'Initialization failed: ${e.toString()}'};
    }
  }

  // Update profile method
  Future<bool> updateProfile(Map<String, dynamic> updateData) async {
    if (!_isAuthenticated) {
      _setError('Not authenticated');
      return false;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      // TODO: Implement profile update API call to Django backend
      // For now, just update local data
      if (_currentAthlete != null) {
        // Update local athlete data
        // This would normally call your Django profile update endpoint
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError('No athlete profile found');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to update profile: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }
}
