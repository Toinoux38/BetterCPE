/// API configuration constants
abstract final class ApiConstants {
  static const String baseUrl = 'https://mycpe.cpe.fr/mobile/';
  
  // Auth endpoints
  static const String loginEndpoint = 'login';
  
  // Planning endpoints
  static const String planningEndpoint = 'mon_planning';
  
  // Grades endpoints
  static const String gradesEndpoint = 'mes_notes';
  
  // Absences endpoints
  static const String absencesEndpoint = 'mes_absences';
  
  // Request timeout
  static const Duration requestTimeout = Duration(seconds: 30);
}
