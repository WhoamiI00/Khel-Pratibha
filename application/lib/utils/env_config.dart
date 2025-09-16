/// Environment configuration for the Flutter app
/// This includes tokens and keys from the backend environment
class EnvConfig {
  // JWT token from backend .env file
  // This is the SUPABASE_JWT_SECRET from backend/.env
  static const String supabaseJwtToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1NTBlODQwMC1lMjliLTQxZDQtYTcxNi00NDY2NTU0NDAwMDQiLCJlbWFpbCI6InRlc3RuZXc1QGV4YW1wbGUuY29tIiwicm9sZSI6ImF1dGhlbnRpY2F0ZWQiLCJhdWQiOiJhdXRoZW50aWNhdGVkIiwiZXhwIjoxNzU3ODM3MTgzLCJpYXQiOjE3NTc4MzM1ODMsImlzcyI6InN1cGFiYXNlIn0.Jcr1AOUjVzLF2QoqAt7QdBDCTHHr1DXUOeFVAMl9g0k';
  
  // Supabase Anon Key from backend .env file
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB4dHNyY295ZXNxYmFybHptcW10Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcwNDk5OTAsImV4cCI6MjA3MjYyNTk5MH0.hx_1FyOiKDJejonredZCAfY08b-qbKkZJnAAMpI7Tqg';
  
  // Supabase URL from backend .env file
  static const String supabaseUrl = 'https://pxtsrcoyesqbarlzmqmt.supabase.co';
}