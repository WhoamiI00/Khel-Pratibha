/// Test file to validate JWT token integration
/// Run this to test if the JWT token from backend/.env is working properly

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/env_config.dart';

class JwtTokenTest extends StatefulWidget {
  const JwtTokenTest({super.key});

  @override
  State<JwtTokenTest> createState() => _JwtTokenTestState();
}

class _JwtTokenTestState extends State<JwtTokenTest> {
  final ApiService _apiService = ApiService();
  String _testResult = 'Not tested yet';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _runJwtTest();
  }

  Future<void> _runJwtTest() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Running JWT token test...';
    });

    try {
      // Test 1: Check if JWT token is set
      print('Test 1: Checking JWT token configuration');
      final tokenFromEnv = EnvConfig.supabaseJwtToken;
      print('JWT Token from env: ${tokenFromEnv.substring(0, 50)}...');
      
      // Test 2: Check API headers
      print('Test 2: Checking API headers');
      final headers = _apiService.authHeaders;
      print('API Headers: $headers');
      
      // Test 3: Try to fetch fitness tests
      print('Test 3: Attempting to fetch fitness tests');
      final result = await _apiService.getFitnessTests();
      
      if (result.success) {
        setState(() {
          _testResult = 'SUCCESS! JWT token is working. Fetched ${result.data?.length ?? 0} fitness tests.';
        });
      } else {
        setState(() {
          _testResult = 'FAILED! Error: ${result.error}';
        });
      }
      
    } catch (e) {
      setState(() {
        _testResult = 'ERROR! Exception: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JWT Token Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'JWT Token Configuration Test',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'This test verifies that the JWT token from backend/.env is properly configured in the Flutter app.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Result:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _testResult,
                      style: TextStyle(
                        color: _testResult.startsWith('SUCCESS') 
                            ? Colors.green 
                            : _testResult.startsWith('FAILED') || _testResult.startsWith('ERROR')
                                ? Colors.red
                                : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _runJwtTest,
              child: const Text('Run Test Again'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Token Info:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Token Source: backend/.env SUPABASE_JWT_SECRET'),
            Text('Token Length: ${EnvConfig.supabaseJwtToken.length} characters'),
            Text('Token Preview: ${EnvConfig.supabaseJwtToken.substring(0, 30)}...'),
          ],
        ),
      ),
    );
  }
}