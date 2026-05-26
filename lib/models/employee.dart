class Employee {
  final int? id;
  final String fullName;
  final String email;
  final String? phone;
  final String? password;
  final String role;
  final String? status;

  Employee({
    this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.password,
    required this.role,
    this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      "fullName": fullName,
      "email": email,
      "phone": phone,
      "password": password,
      "role": role,
      "status": status ?? "ACTIVE",
    }..removeWhere((k, v) => v == null || v == "");
  }

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json["id"],
      fullName: json["fullName"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"],
      role: json["role"] ?? "CONSULTANT",
      status: json["status"] ?? "ACTIVE",
    );
  }
}
