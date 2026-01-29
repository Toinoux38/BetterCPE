import '../../core/constants/api_constants.dart';
import '../../core/utils/result.dart';
import '../models/course_grades.dart';
import 'api_client.dart';

/// Service for grades operations
class GradesService {
  final ApiClient _apiClient;
  
  GradesService({required ApiClient apiClient}) : _apiClient = apiClient;
  
  /// Get all grades
  Future<Result<List<CourseGrades>>> getGrades() async {
    return _apiClient.get<List<CourseGrades>>(
      ApiConstants.gradesEndpoint,
      fromJson: (json) {
        if (json is! List) return <CourseGrades>[];
        return json
            .map((e) => CourseGrades.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }
}
