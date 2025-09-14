import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();
  
  SupabaseService._();

  // Supabase configuration - replace with your actual values
  static const String supabaseUrl = 'https://aaeduwgqwsrfclvfhkmk.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFhZWR1d2dxd3NyZmNsdmZoa21rIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQwMzM0ODcsImV4cCI6MjA0OTYwOTQ4N30.d7gXJJ0KUYEfCdEQXIDlI7mZFAfaJPE8d5bgwX5bKJY';

  SupabaseClient get client => Supabase.instance.client;

  // Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  // Get current user
  User? get currentUser => client.auth.currentUser;

  // Get current session
  Session? get currentSession => client.auth.currentSession;

  // Get access token (JWT)
  String? get accessToken => currentSession?.accessToken;

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        print('Sign in successful for user: ${response.user!.email}');
      }
      
      return response;
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
  }

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: data,
      );
      
      if (response.user != null) {
        print('Sign up successful for user: ${response.user!.email}');
      }
      
      return response;
    } catch (e) {
      print('Sign up error: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
      print('Sign out successful');
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  // Refresh session
  Future<AuthResponse> refreshSession() async {
    try {
      final response = await client.auth.refreshSession();
      return response;
    } catch (e) {
      print('Session refresh error: $e');
      rethrow;
    }
  }

  // Get user profile from athletes table
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await client
          .from('athletes')
          .select()
          .eq('auth_user_id', userId)
          .maybeSingle();
      
      return response;
    } catch (e) {
      print('Get user profile error: $e');
      return null;
    }
  }

  // Create or update user profile in athletes table
  Future<void> upsertUserProfile({
    required String userId,
    required Map<String, dynamic> profileData,
  }) async {
    try {
      await client
          .from('athletes')
          .upsert({
            'auth_user_id': userId,
            ...profileData,
          });
      
      print('User profile updated successfully');
    } catch (e) {
      print('Update user profile error: $e');
      rethrow;
    }
  }
}