class AuthModel {
  final int id;

  final String fullName;

  final String username;

  final String? phone;

  final String role;

  final String? status;

  final String? createdAt;

  final String? updatedAt;

  final String accessToken;

  AuthModel({
    required this.id,
    required this.fullName,
    required this.username,
    this.phone,
    required this.role,
    this.status,
    this.createdAt,
    this.updatedAt,
    required this.accessToken,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    final data = json["data"] ?? json;

    return AuthModel(
      id: data["id"] ?? 0,

      fullName: data["fullName"] ?? "",

      username: data["username"] ?? "",

      phone: data["phone"],

      role: data["role"] ?? "",

      status: data["status"],

      createdAt: data["createdAt"],

      updatedAt: data["updatedAt"],

      // login response mới có token
      accessToken: data["accessToken"] ?? "",
    );
  }
}
