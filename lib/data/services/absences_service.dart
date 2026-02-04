import '../../core/constants/api_constants.dart';
import '../../core/utils/result.dart';
import '../models/absences_response.dart';
import 'api_client.dart';

/// Service for absences operations
class AbsencesService {
  final ApiClient _apiClient;

  AbsencesService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Fetch absences from the server
  Future<Result<AbsencesResponse>> fetchAbsences() async {
    return _apiClient.get<AbsencesResponse>(
      ApiConstants.absencesEndpoint,
      fromJson: (json) =>
          AbsencesResponse.fromJson(json as Map<String, dynamic>),
    );
  }
}
