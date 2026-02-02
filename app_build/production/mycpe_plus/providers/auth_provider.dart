import 'package:flutter/foundation.dart';
import '../data/models/auth_response.dart';
import '../data/services/auth_service.dart';
import '../core/utils/result.dart';

/// Authentication state
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Provider for authentication state management
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  
  AuthState _state = AuthState.initial;
  String? _errorMessage;
  String? _userEmail;
  
  AuthProvider({required AuthService authService}) : _authService = authService;
  
  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get userEmail => _userEmail;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;
  
  /// Initialize and check for existing session
  Future<void> initialize() async {
    _state = AuthState.loading;
    notifyListeners();
    
    final hasSession = await _authService.restoreSession();
    if (hasSession) {
      _userEmail = await _authService.getUserEmail();
      _state = AuthState.authenticated;
    } else {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }
  
  /// Login with email and password
  Future<bool> login(String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();
    
    final Result<AuthResponse> result = await _authService.login(email, password);
    
    return result.when(
      success: (authResponse) {
        _userEmail = email;
        _state = AuthState.authenticated;
        notifyListeners();
        return true;
      },
      failure: (message, statusCode) {
        _errorMessage = message;
        _state = AuthState.error;
        notifyListeners();
        return false;
      },
    );
  }
  
  /// Logout
  Future<void> logout() async {
    await _authService.logout();
    _userEmail = null;
    _errorMessage = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }
  
  /// Clear error state
  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }
}
