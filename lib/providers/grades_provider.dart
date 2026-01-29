import 'package:flutter/foundation.dart';
import '../data/models/course_grades.dart';
import '../data/services/grades_service.dart';

/// Loading state for grades data
enum GradesState {
  initial,
  loading,
  loaded,
  error,
}

/// Provider for grades state management
class GradesProvider extends ChangeNotifier {
  final GradesService _gradesService;
  
  GradesState _state = GradesState.initial;
  String? _errorMessage;
  List<CourseGrades> _courses = [];
  String? _expandedCourseId;
  
  GradesProvider({required GradesService gradesService})
      : _gradesService = gradesService;
  
  GradesState get state => _state;
  String? get errorMessage => _errorMessage;
  List<CourseGrades> get courses => _courses;
  String? get expandedCourseId => _expandedCourseId;
  bool get isLoading => _state == GradesState.loading;
  
  /// Get overall average across all courses
  double? get overallAverage {
    final coursesWithGrades = _courses.where((c) => c.averageGrade != null).toList();
    if (coursesWithGrades.isEmpty) return null;
    
    final sum = coursesWithGrades.fold<double>(0, (prev, c) => prev + c.averageGrade!);
    return sum / coursesWithGrades.length;
  }
  
  /// Get total graded exams count
  int get totalGradedExams => 
      _courses.fold<int>(0, (prev, c) => prev + c.gradedExamsCount);
  
  /// Get total courses count
  int get totalCourses => _courses.length;
  
  /// Load all grades
  Future<void> loadGrades() async {
    _state = GradesState.loading;
    _errorMessage = null;
    notifyListeners();
    
    final result = await _gradesService.getGrades();
    
    result.when(
      success: (courses) {
        _courses = courses;
        _state = GradesState.loaded;
        notifyListeners();
      },
      failure: (message, statusCode) {
        _errorMessage = message;
        _state = GradesState.error;
        notifyListeners();
      },
    );
  }
  
  /// Toggle course expansion
  void toggleCourseExpansion(String courseId) {
    if (_expandedCourseId == courseId) {
      _expandedCourseId = null;
    } else {
      _expandedCourseId = courseId;
    }
    notifyListeners();
  }
  
  /// Refresh grades
  Future<void> refresh() async {
    await loadGrades();
  }
  
  /// Reset to initial state
  void reset() {
    _state = GradesState.initial;
    _courses = [];
    _expandedCourseId = null;
    _errorMessage = null;
    notifyListeners();
  }
}
