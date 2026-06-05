class Employee {
  final int? id;

  final String fullName;

  final String username;

  final String? phone;

  final String? password;

  final String role;

  final String? status;

  final String? createdAt;

  final String? updatedAt;

  Employee({
    this.id,
    required this.fullName,
    required this.username,
    this.phone,
    this.password,
    required this.role,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  Employee copyWith({
    int? id,
    String? fullName,
    String? username,
    String? phone,
    String? password,
    String? role,
    String? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return Employee(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "fullName": fullName,
      "username": username,
      "phone": phone,
      "password": password,
      "role": role,
      "status": status ?? "ACTIVE",
    }..removeWhere((k, v) => v == null);
  }

  factory Employee.fromJson(Map<String, dynamic> json) {
    final data = json["data"] ?? json;

    return Employee(
      id: data["id"],
      fullName: data["fullName"] ?? "",
      username: data["username"] ?? "",
      phone: data["phone"],
      password: data["password"],
      role: data["role"] ?? "CONSULTANT",
      status: data["status"] ?? "ACTIVE",
      createdAt: data["createdAt"],
      updatedAt: data["updatedAt"],
    );
  }
}
