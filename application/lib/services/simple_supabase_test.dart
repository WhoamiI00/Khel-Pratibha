import 'package:supabase_flutter/supabase_flutter.dart';

class SimpleSupabaseTest {
  static const String supabaseUrl = 'https://pxtsrcoyesqbarlzmqmt.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB4dHNyY295ZXNxYmFybHptcW10Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcwNDk5OTAsImV4cCI6MjA3MjYyNTk5MH0.hx_1FyOiKDJejonredZCAfY08b-qbKkZJnAAMpI7Tqg';

  static Future<void> testConnection() async {
    try {
      print('Testing Supabase connection...');
      
      // Initialize Supabase
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      
      print('Supabase initialized successfully');
      
      // Test basic connection
      final client = Supabase.instance.client;
      print('Client created: ${client != null}');
      
      // Try to create a test user instead of signing in
      final response = await client.auth.signUp(
        email: 'test.user@example.com',
        password: 'TestPass123!',
      );
      
      print('Sign up response: ${response.user?.id}');
      print('Sign up error: ${response.session}');
      
    } catch (e) {
      print('Test failed: $e');
      print('Error type: ${e.runtimeType}');
    }
  }
  
  static Future<void> testSignIn() async {
    try {
      print('Testing sign in...');
      
      final client = Supabase.instance.client;
      
      final response = await client.auth.signInWithPassword(
        email: 'test.user@example.com',
        password: 'TestPass123!',
      );
      
      print('Sign in response: ${response.user?.id}');
      print('Session: ${response.session?.accessToken}');
      
    } catch (e) {
      print('Sign in test failed: $e');
    }
  }
}