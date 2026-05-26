class AuthModel {
  final int id;

  final String fullName;

  final String email;

  final String? phone;

  final String role;

  final String? status;

  final String? createdAt;

  final String? updatedAt;

  final String accessToken;

  AuthModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.role,
    this.status,
    this.createdAt,
    this.updatedAt,
    required this.accessToken,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    // support both:
    // login response -> data
    // account response -> data nested
    final data = json["data"] ?? json;

    return AuthModel(
      id: data["id"] ?? 0,

      fullName: data["fullName"] ?? "",

      email: data["email"] ?? "",

      phone: data["phone"],

      role: data["role"] ?? "",

      status: data["status"],

      createdAt: data["createdAt"],

      updatedAt: data["updatedAt"],

      accessToken: data["accessToken"] ?? "",
    );
  }
}
