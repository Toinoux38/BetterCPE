/// Authentication response model
class AuthResponse {
  final String normalToken;
  final String? comptageToken;
  
  const AuthResponse({
    required this.normalToken,
    this.comptageToken,
  });
  
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      normalToken: json['normal'] as String,
      comptageToken: json['comptage'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'normal': normalToken,
      'comptage': comptageToken,
    };
  }
}
