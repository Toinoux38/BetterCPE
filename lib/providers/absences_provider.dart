import 'package:flutter/foundation.dart';
import '../data/models/absences_response.dart';
import '../data/services/absences_service.dart';

/// Loading state for absences data
enum AbsencesState {
  initial,
  loading,
  loaded,
  error,
}

/// Provider for absences state management
class AbsencesProvider extends ChangeNotifier {
  final AbsencesService _absencesService;

  AbsencesState _state = AbsencesState.initial;
  String? _errorMessage;
  AbsencesResponse? _absencesData;

  AbsencesProvider({required AbsencesService absencesService})
      : _absencesService = absencesService;

  AbsencesState get state => _state;
  String? get errorMessage => _errorMessage;
  AbsencesResponse? get absencesData => _absencesData;
  bool get isLoading => _state == AbsencesState.loading;

  /// Get total absences count
  int get totalAbsences =>
      (_absencesData?.nbrTotalAbsenceExcuser ?? 0) +
      (_absencesData?.nbrTotalAbsenceNonExcuser ?? 0);

  /// Get excused absences count
  int get excusedAbsencesCount => _absencesData?.nbrTotalAbsenceExcuser ?? 0;

  /// Get unexcused absences count
  int get unexcusedAbsencesCount =>
      _absencesData?.nbrTotalAbsenceNonExcuser ?? 0;

  /// Get list of absences
  List<Absence> get absences => _absencesData?.absences ?? [];

  /// Load absences from server
  Future<void> loadAbsences() async {
    _state = AbsencesState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _absencesService.fetchAbsences();

    result.when(
      success: (data) {
        _absencesData = data;
        _state = AbsencesState.loaded;
        notifyListeners();
      },
      failure: (message, statusCode) {
        _errorMessage = message;
        _state = AbsencesState.error;
        notifyListeners();
      },
    );
  }

  /// Refresh absences
  Future<void> refresh() async {
    await loadAbsences();
  }
}
