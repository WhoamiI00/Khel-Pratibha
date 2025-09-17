class ApiConstants {
  // For Android emulator
  static String baseUrl = '172.27.75.222:8000/api/v1';
  static String authUrl = '172.27.75.222:8000/api/auth';
  
  // Add http:// prefix to URLs
  static String get apiBaseUrl => 'http://$baseUrl';
  static String get apiAuthUrl => 'http://$authUrl';
  
  static const Duration requestTimeout = Duration(seconds: 15); // Increased timeout
  static const Duration uploadTimeout = Duration(minutes: 5);
  
  // HTTP status codes
  static const int statusOk = 200;
  static const int statusCreated = 201;
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusForbidden = 403;
  static const int statusNotFound = 404;
  static const int statusInternalServerError = 500;

}

