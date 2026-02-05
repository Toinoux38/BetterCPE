import 'package:flutter/foundation.dart';
import '../core/utils/date_utils.dart' as date_utils;
import '../data/models/planning_event.dart';
import '../data/services/planning_service.dart';

/// Loading state for planning data
enum PlanningState { initial, loading, loaded, error }

/// Sync status for planning data
enum PlanningSyncStatus {
  /// Data is from cache, not yet synced
  cached,

  /// Currently fetching fresh data from server
  syncing,

  /// Data is fresh from server
  synced,

  /// Offline mode, showing cached data
  offline,
}

/// Provider for planning/schedule state management
class PlanningProvider extends ChangeNotifier {
  final PlanningService _planningService;

  PlanningState _state = PlanningState.initial;
  PlanningSyncStatus _syncStatus = PlanningSyncStatus.synced;
  String? _errorMessage;
  List<DayPlanning> _weekPlanning = [];
  DateTime _currentMonday = date_utils.DateUtils.getMondayOfWeek(
    DateTime.now(),
  );
  int _selectedDayIndex = 0; // 0 = Monday, 4 = Friday
  DateTime? _lastSyncTime;
  bool _isOffline = false;
  bool _hasInitializedCache = false;

  PlanningProvider({required PlanningService planningService})
    : _planningService = planningService {
    // Set initial selected day to today if it's a weekday
    final today = DateTime.now();
    final monday = date_utils.DateUtils.getMondayOfWeek(today);
    final dayDiff = today.difference(monday).inDays;
    if (dayDiff >= 0 && dayDiff <= 4) {
      _selectedDayIndex = dayDiff;
    }
  }

  PlanningState get state => _state;
  PlanningSyncStatus get syncStatus => _syncStatus;
  String? get errorMessage => _errorMessage;
  List<DayPlanning> get weekPlanning => _weekPlanning;
  DateTime get currentMonday => _currentMonday;
  bool get isLoading => _state == PlanningState.loading;
  int get selectedDayIndex => _selectedDayIndex;
  DateTime? get lastSyncTime => _lastSyncTime;
  bool get isOffline => _isOffline;
  bool get isSyncing => _syncStatus == PlanningSyncStatus.syncing;

  /// Get selected date
  DateTime get selectedDate =>
      _currentMonday.add(Duration(days: _selectedDayIndex));

  /// Get selected day planning
  DayPlanning? get selectedDayPlanning {
    if (_weekPlanning.isEmpty) return null;
    if (_selectedDayIndex >= _weekPlanning.length) return null;
    return _weekPlanning[_selectedDayIndex];
  }

  /// Check if selected date is today
  bool get isToday =>
      date_utils.DateUtils.isSameDay(selectedDate, DateTime.now());

  /// Get week range string for current view
  String get weekRangeString =>
      date_utils.DateUtils.getWeekRangeString(_currentMonday);

  /// Select a day by index (0-4 for Mon-Fri)
  void selectDay(int index) {
    if (index >= 0 && index <= 4 && index != _selectedDayIndex) {
      _selectedDayIndex = index;
      notifyListeners();
    }
  }

  /// Load planning with cache-first strategy
  /// Shows cached data immediately, then fetches fresh data in background
  Future<void> loadWeekPlanning() async {
    _errorMessage = null;

    // Try to load from cache first
    final cachedEvents = await _planningService.getCachedWeekPlanning(
      _currentMonday,
    );

    if (cachedEvents != null && cachedEvents.isNotEmpty) {
      // Show cached data immediately
      _weekPlanning = _planningService.groupEventsByDay(
        cachedEvents,
        _currentMonday,
      );
      _state = PlanningState.loaded;
      _syncStatus = PlanningSyncStatus.cached;
      notifyListeners();

      // Fetch fresh data in background
      _fetchFreshDataInBackground();
    } else {
      // No cache, show loading and fetch from network
      _state = PlanningState.loading;
      _syncStatus = PlanningSyncStatus.syncing;
      notifyListeners();

      await _fetchFromNetwork();
    }
  }

  /// Fetch fresh data in background without blocking UI
  Future<void> _fetchFreshDataInBackground() async {
    _syncStatus = PlanningSyncStatus.syncing;
    notifyListeners();

    final result = await _planningService.fetchAndCacheWeekPlanning(
      _currentMonday,
    );

    result.when(
      success: (events) {
        _weekPlanning = _planningService.groupEventsByDay(
          events,
          _currentMonday,
        );
        _state = PlanningState.loaded;
        _syncStatus = PlanningSyncStatus.synced;
        _isOffline = false;
        _lastSyncTime = DateTime.now();
        notifyListeners();
      },
      failure: (message, statusCode) {
        // Keep showing cached data, just update sync status
        _syncStatus = PlanningSyncStatus.offline;
        _isOffline = true;
        // Don't set error state since we have cached data
        notifyListeners();
      },
    );
  }

  /// Fetch data from network (used when no cache available)
  Future<void> _fetchFromNetwork() async {
    final result = await _planningService.fetchAndCacheWeekPlanning(
      _currentMonday,
    );

    result.when(
      success: (events) {
        _weekPlanning = _planningService.groupEventsByDay(
          events,
          _currentMonday,
        );
        _state = PlanningState.loaded;
        _syncStatus = PlanningSyncStatus.synced;
        _isOffline = false;
        _lastSyncTime = DateTime.now();
        notifyListeners();
      },
      failure: (message, statusCode) {
        _errorMessage = message;
        _state = PlanningState.error;
        _syncStatus = PlanningSyncStatus.offline;
        _isOffline = true;
        notifyListeners();
      },
    );
  }

  /// Initialize and prefetch extended planning (call on app start)
  Future<void> initializeWithCache() async {
    if (_hasInitializedCache) return;
    _hasInitializedCache = true;

    // Load last sync time immediately for display
    _lastSyncTime = await _planningService.getLastSyncTime();

    // Load current week first
    await loadWeekPlanning();

    // Prefetch 2 months of data in background
    _prefetchExtendedPlanning();
  }

  /// Prefetch extended planning data in background
  Future<void> _prefetchExtendedPlanning() async {
    // Don't block or show any UI for this
    await _planningService.fetchAndCacheExtendedPlanning();
    _lastSyncTime = await _planningService.getLastSyncTime();
  }

  /// Navigate to previous week
  Future<void> previousWeek() async {
    _currentMonday = _currentMonday.subtract(const Duration(days: 7));
    _selectedDayIndex = 4; // Set to Friday immediately before loading
    await loadWeekPlanning();
  }

  /// Navigate to next week
  Future<void> nextWeek() async {
    _currentMonday = _currentMonday.add(const Duration(days: 7));
    _selectedDayIndex = 0; // Set to Monday immediately before loading
    await loadWeekPlanning();
  }

  /// Navigate to current week and select today
  Future<void> goToToday() async {
    final today = DateTime.now();
    _currentMonday = date_utils.DateUtils.getMondayOfWeek(today);
    final dayDiff = today.difference(_currentMonday).inDays;
    _selectedDayIndex = (dayDiff >= 0 && dayDiff <= 4) ? dayDiff : 0;
    await loadWeekPlanning();
  }

  /// Navigate to current week
  Future<void> goToCurrentWeek() async {
    _currentMonday = date_utils.DateUtils.getMondayOfWeek(DateTime.now());
    await loadWeekPlanning();
  }

  /// Force refresh from network (ignores cache)
  Future<void> forceRefresh() async {
    _state = PlanningState.loading;
    _syncStatus = PlanningSyncStatus.syncing;
    notifyListeners();

    await _fetchFromNetwork();
  }

  /// Refresh current week data
  Future<void> refresh() async {
    await loadWeekPlanning();
  }

  /// Clear cache and reset
  Future<void> clearCache() async {
    await _planningService.clearCache();
    _hasInitializedCache = false;
  }

  /// Reset to initial state
  void reset() {
    _state = PlanningState.initial;
    _syncStatus = PlanningSyncStatus.synced;
    _weekPlanning = [];
    _currentMonday = date_utils.DateUtils.getMondayOfWeek(DateTime.now());
    _selectedDayIndex = 0;
    _errorMessage = null;
    _isOffline = false;
    _hasInitializedCache = false;
    notifyListeners();
  }
}
