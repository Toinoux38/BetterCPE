import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/planning_event.dart';

/// Service for caching planning data locally
class PlanningCacheService {
  static const String _cacheKey = 'planning_cache';
  static const String _lastSyncKey = 'planning_last_sync';
  static const String _cacheRangeKey = 'planning_cache_range';

  final FlutterSecureStorage _storage;

  PlanningCacheService({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

  /// Save planning events to cache
  Future<void> cacheEvents(List<PlanningEvent> events) async {
    try {
      final jsonList = events.map((e) => e.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await _storage.write(key: _cacheKey, value: jsonString);
      await _storage.write(
        key: _lastSyncKey,
        value: DateTime.now().toIso8601String(),
      );
    } catch (_) {
      // Silently fail on cache write errors
    }
  }

  /// Save the cached date range
  Future<void> saveCacheRange(DateTime startDate, DateTime endDate) async {
    try {
      final rangeData = jsonEncode({
        'start': startDate.toIso8601String(),
        'end': endDate.toIso8601String(),
      });
      await _storage.write(key: _cacheRangeKey, value: rangeData);
    } catch (_) {
      // Silently fail
    }
  }

  /// Get cached date range
  Future<({DateTime? start, DateTime? end})> getCacheRange() async {
    try {
      final rangeData = await _storage.read(key: _cacheRangeKey);
      if (rangeData == null) return (start: null, end: null);

      final decoded = jsonDecode(rangeData) as Map<String, dynamic>;
      return (
        start: DateTime.parse(decoded['start'] as String),
        end: DateTime.parse(decoded['end'] as String),
      );
    } catch (_) {
      return (start: null, end: null);
    }
  }

  /// Get cached planning events
  Future<List<PlanningEvent>?> getCachedEvents() async {
    try {
      final jsonString = await _storage.read(key: _cacheKey);
      if (jsonString == null) return null;

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((e) => PlanningEvent.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  /// Get cached events for a specific date range
  Future<List<PlanningEvent>?> getCachedEventsForRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final allEvents = await getCachedEvents();
      if (allEvents == null) return null;

      // Filter events that fall within the requested range
      return allEvents.where((event) {
        if (event.dateDebut == null) return false;
        final eventDate = event.dateDebut!;
        return !eventDate.isBefore(startDate) && !eventDate.isAfter(endDate);
      }).toList();
    } catch (_) {
      return null;
    }
  }

  /// Check if we have cached data for a date range
  Future<bool> hasCacheForRange(DateTime startDate, DateTime endDate) async {
    final range = await getCacheRange();
    if (range.start == null || range.end == null) return false;

    return !startDate.isBefore(range.start!) && !endDate.isAfter(range.end!);
  }

  /// Get last sync timestamp
  Future<DateTime?> getLastSyncTime() async {
    try {
      final timestamp = await _storage.read(key: _lastSyncKey);
      if (timestamp == null) return null;
      return DateTime.parse(timestamp);
    } catch (_) {
      return null;
    }
  }

  /// Check if cache is stale (older than specified duration)
  Future<bool> isCacheStale({
    Duration maxAge = const Duration(hours: 1),
  }) async {
    final lastSync = await getLastSyncTime();
    if (lastSync == null) return true;
    return DateTime.now().difference(lastSync) > maxAge;
  }

  /// Clear all cached planning data
  Future<void> clearCache() async {
    try {
      await _storage.delete(key: _cacheKey);
      await _storage.delete(key: _lastSyncKey);
      await _storage.delete(key: _cacheRangeKey);
    } catch (_) {
      // Silently fail
    }
  }

  /// Merge new events with existing cache (for incremental updates)
  Future<void> mergeEvents(List<PlanningEvent> newEvents) async {
    try {
      final existing = await getCachedEvents() ?? [];

      // Create a map of existing events by id for efficient lookup
      final eventMap = <int, PlanningEvent>{};
      for (final event in existing) {
        if (event.id != null) {
          eventMap[event.id!] = event;
        }
      }

      // Update or add new events
      for (final event in newEvents) {
        if (event.id != null) {
          eventMap[event.id!] = event;
        }
      }

      // Save merged events
      await cacheEvents(eventMap.values.toList());
    } catch (_) {
      // Fall back to just saving new events
      await cacheEvents(newEvents);
    }
  }
}
