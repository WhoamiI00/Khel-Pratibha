import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';
import '../models/athlete_profile.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _token;
  String? _errorMessage;
  AthleteProfile? _currentAthlete;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  String? get errorMessage => _errorMessage;
  AthleteProfile? get currentAthlete => _currentAthlete;

  Future<Map<String, dynamic>> init() async {
    try {
      // Test backend connection
      final response = await http.get(
        Uri.parse('${ApiConstants.apiBaseUrl}/health-check/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Backend connected'};
      } else {
        return {'success': false, 'message': 'Backend connection failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    required DateTime dateOfBirth,
    required String gender,
    required double height,
    required double weight,
    required String state,
    required String district,
    required String address,
    required String pincode,
    required String aadhaarNumber,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.apiAuthUrl}/register/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'full_name': fullName,
          'email': email,
          'password': password,
          'phone_number': phoneNumber,
          'date_of_birth': dateOfBirth.toIso8601String().split('T'),
          'gender': gender,
          'height': height,
          'weight': weight,
          'state': state,
          'district': district,
          'address': address,
          'pincode': pincode,
          'aadhaar_number': aadhaarNumber,
        }),
      ).timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        _token = data['token'];
        _currentAthlete = AthleteProfile.fromJson(data['athlete']);
        _isAuthenticated = true;
        _setLoading(false);
        return true;
      } else {
        final errorData = json.decode(response.body);
        _setError(errorData['message'] ?? 'Registration failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Network error: Please check your connection');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.apiAuthUrl}/login/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['token'];
        _currentAthlete = AthleteProfile.fromJson(data['athlete']);
        _isAuthenticated = true;
        _setLoading(false);
        return true;
      } else {
        final errorData = json.decode(response.body);
        _setError(errorData['message'] ?? 'Login failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Network error: Please check your connection');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> updateData) async {
    if (!_isAuthenticated || _token == null) {
      _setError('Not authenticated');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final response = await http.patch(
        Uri.parse('${ApiConstants.apiBaseUrl}/athlete/profile/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode(updateData),
      ).timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _currentAthlete = AthleteProfile.fromJson(data);
        _setLoading(false);
        return true;
      } else {
        final errorData = json.decode(response.body);
        _setError(errorData['message'] ?? 'Profile update failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Network error: Please check your connection');
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _currentAthlete = null;
    _isAuthenticated = false;
    notifyListeners();
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
