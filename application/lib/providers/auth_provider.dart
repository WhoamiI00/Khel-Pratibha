import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../services/api_service.dart';
import '../models/athlete_profile.dart';

class AuthProvider with ChangeNotifier {
  AthleteProfile? _currentAthlete;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  AthleteProfile? get currentAthlete => _currentAthlete;
  bool get isAuthenticated => SupabaseService.instance.isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get accessToken => SupabaseService.instance.accessToken;
  String? get token => accessToken; // For backward compatibility

  final SupabaseService _supabaseService = SupabaseService.instance;
  final ApiService _apiService = ApiService();

  // Constructor - check for existing session
  AuthProvider() {
    _loadUserSession();
    _setupAuthListener();
  }

  // Setup auth state listener
  void _setupAuthListener() {
    _supabaseService.authStateChanges.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      
      if (event == AuthChangeEvent.signedIn && session != null) {
        _onSignIn(session);
      } else if (event == AuthChangeEvent.signedOut) {
        _onSignOut();
      } else if (event == AuthChangeEvent.tokenRefreshed && session != null) {
        _onTokenRefresh(session);
      }
    });
  }

  // Handle sign in
  void _onSignIn(Session session) async {
    try {
      // Set JWT token in API service
      _apiService.setJWTToken(session.accessToken);
      
      // Load athlete profile
      await _loadAthleteProfile(session.user.id);
      
      // Save session
      await _saveSession();
      
      notifyListeners();
    } catch (e) {
      print('Error handling sign in: $e');
      _setError('Failed to load athlete profile');
    }
  }

  // Handle sign out
  void _onSignOut() async {
    _currentAthlete = null;
    _apiService.clearToken();
    await _clearSession();
    notifyListeners();
  }

  // Handle token refresh
  void _onTokenRefresh(Session session) {
    _apiService.setJWTToken(session.accessToken);
  }

  // Load user session from storage
  Future<void> _loadUserSession() async {
    try {
      // Check if user is already authenticated with Supabase
      if (_supabaseService.isAuthenticated) {
        final session = _supabaseService.currentSession;
        if (session != null) {
          _apiService.setJWTToken(session.accessToken);
          await _loadAthleteProfile(_supabaseService.currentUser!.id);
        }
      }
    } catch (e) {
      print('Error loading user session: $e');
      await _clearSession();
    }
    notifyListeners();
  }

  // Load athlete profile from athletes table
  Future<void> _loadAthleteProfile(String userId) async {
    try {
      final profileData = await _supabaseService.getUserProfile(userId);
      if (profileData != null) {
        _currentAthlete = AthleteProfile.fromJson(profileData);
      } else {
        // Create basic athlete profile from Supabase auth user
        final user = _supabaseService.currentUser;
        if (user != null) {
          _currentAthlete = AthleteProfile(
            id: userId,
            authUserId: userId,
            fullName: user.userMetadata?['name'] ?? user.email ?? '',
            dateOfBirth: DateTime.now().subtract(Duration(days: 365 * 15)), // Default age 15
            age: 15,
            gender: 'unknown',
            height: 0.0,
            weight: 0.0,
            phoneNumber: user.userMetadata?['phone'] ?? '',
            email: user.email ?? '',
            address: '',
            state: '',
            district: '',
            pinCode: '',
            locationCategory: 'urban',
            aadhaarNumber: '',
            sportsInterests: [],
            isVerified: false,
            verificationStatus: 'pending',
            totalPoints: 0,
            badgesEarned: [],
            level: 1,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }
      }
    } catch (e) {
      print('Error loading athlete profile: $e');
      throw e;
    }
  }

  // Save session to storage
  Future<void> _saveSession() async {
    try {
      if (_currentAthlete != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('athlete_data', jsonEncode(_currentAthlete!.toJson()));
      }
    } catch (e) {
      print('Error saving session: $e');
    }
  }

  // Clear session from storage
  Future<void> _clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('athlete_data');
      _currentAthlete = null;
    } catch (e) {
      print('Error clearing session: $e');
    }
  }

  // Test backend connection
  Future<Map<String, dynamic>> init() async {
    try {
      // Initialize API service with JWT token if available
      if (isAuthenticated && accessToken != null) {
        _apiService.setJWTToken(accessToken!);
      }
      
      // Test backend connection
      final response = await _apiService.testConnection();
      return response;
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Login method
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _supabaseService.signIn(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        // Success - auth listener will handle the rest
        _setLoading(false);
        return true;
      } else {
        _setError('Login failed - no user returned');
        _setLoading(false);
        return false;
      }
    } on AuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Network error: Please check your connection');
      _setLoading(false);
      return false;
    }
  }

  // Register method
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
      final response = await _supabaseService.signUp(
        email: email,
        password: password,
        data: {
          'name': fullName,
          'phone': phoneNumber,
        },
      );
      
      if (response.user != null) {
        // Create profile in athletes table
        await _supabaseService.upsertUserProfile(
          userId: response.user!.id,
          profileData: {
            'full_name': fullName,
            'email': email,
            'phone_number': phoneNumber,
            'date_of_birth': dateOfBirth.toIso8601String().split('T')[0],
            'gender': gender,
            'height': height,
            'weight': weight,
            'state': state,
            'district': district,
            'address': address,
            'pincode': pincode,
            'aadhaar_number': aadhaarNumber,
            'is_active': true,
          },
        );
        
        _setLoading(false);
        return true;
      } else {
        _setError('Registration failed - no user returned');
        _setLoading(false);
        return false;
      }
    } on AuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Network error: Please check your connection');
      _setLoading(false);
      return false;
    }
  }

  // Update profile method
  Future<bool> updateProfile(Map<String, dynamic> updateData) async {
    if (!isAuthenticated) {
      _setError('Not authenticated');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final userId = _supabaseService.currentUser?.id;
      if (userId != null) {
        await _supabaseService.upsertUserProfile(
          userId: userId,
          profileData: updateData,
        );
        
        await _loadAthleteProfile(userId);
        await _saveSession();
        _setLoading(false);
        return true;
      }
      
      _setError('User not authenticated');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to update profile: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Logout method
  Future<void> logout() async {
    _setLoading(true);

    try {
      await _supabaseService.signOut();
      // Auth listener will handle cleanup
    } catch (e) {
      print('Logout error: $e');
      // Force local cleanup
      _onSignOut();
    }

    _setLoading(false);
  }

  // Refresh athlete data
  Future<void> refreshProfile() async {
    if (!isAuthenticated) return;

    try {
      final userId = _supabaseService.currentUser?.id;
      if (userId != null) {
        await _loadAthleteProfile(userId);
        await _saveSession();
        notifyListeners();
      }
    } catch (e) {
      print('Error refreshing profile: $e');
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
