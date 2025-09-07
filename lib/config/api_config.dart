class ApiConfig {

  static const String baseUrl = "https://aces-utky.onrender.com";

  // Endpoint to ping server
  static const String wakeUpEndpoint = "/docs";
  static const String loginEndpoint = "/api/student/auth/login";
  static const String forgottenPasswordEndpoint = "/api/student/auth/forgot-password";
  static const String verifyCodeEndpoint = "/api/student/auth/verify-code";
  static const String resetPasswordEndpoint = "/api/student/auth/reset-password";
  static const String profileEndpoint = "/api/student/auth/profile";
  static const String forumEndpoint = "/api/admin/forum/read";
  static const String timetableEndpoint = "/api/admin/timetable/read";
}
