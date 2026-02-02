import '../../core/constants/api_constants.dart';
import '../../core/utils/date_utils.dart' as date_utils;
import '../../core/utils/result.dart';
import '../models/planning_event.dart';
import 'api_client.dart';

/// Service for planning/schedule operations
class PlanningService {
  final ApiClient _apiClient;
  
  PlanningService({required ApiClient apiClient}) : _apiClient = apiClient;
  
  /// Get planning for a specific date range
  Future<Result<List<PlanningEvent>>> getPlanning({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return _apiClient.get<List<PlanningEvent>>(
      ApiConstants.planningEndpoint,
      queryParams: {
        'date_debut': date_utils.DateUtils.formatForApi(startDate),
        'date_fin': date_utils.DateUtils.formatForApi(endDate),
      },
      fromJson: (json) {
        if (json is! List) return <PlanningEvent>[];
        return json
            .map((e) => PlanningEvent.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }
  
  /// Get planning for current week (Monday to Friday)
  Future<Result<List<PlanningEvent>>> getCurrentWeekPlanning() async {
    final now = DateTime.now();
    final monday = date_utils.DateUtils.getMondayOfWeek(now);
    final friday = date_utils.DateUtils.getFridayOfWeek(now);
    
    return getPlanning(startDate: monday, endDate: friday);
  }
  
  /// Get planning for a specific week
  Future<Result<List<PlanningEvent>>> getWeekPlanning(DateTime referenceDate) async {
    final monday = date_utils.DateUtils.getMondayOfWeek(referenceDate);
    final friday = date_utils.DateUtils.getFridayOfWeek(referenceDate);
    
    return getPlanning(startDate: monday, endDate: friday);
  }
  
  /// Group events by day
  List<DayPlanning> groupEventsByDay(
    List<PlanningEvent> events,
    DateTime mondayOfWeek,
  ) {
    final List<DayPlanning> result = [];
    
    // Create entries for Monday to Friday
    for (int i = 0; i < 5; i++) {
      final day = mondayOfWeek.add(Duration(days: i));
      final dayEvents = events.where((event) {
        if (event.dateDebut == null) return false;
        return date_utils.DateUtils.isSameDay(event.dateDebut!, day);
      }).toList();
      
      // Sort events by start time
      dayEvents.sort((a, b) {
        if (a.dateDebut == null) return 1;
        if (b.dateDebut == null) return -1;
        return a.dateDebut!.compareTo(b.dateDebut!);
      });
      
      result.add(DayPlanning(date: day, events: dayEvents));
    }
    
    return result;
  }
}
