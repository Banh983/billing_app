class BillingPeriodModel {
  final int id;

  final int month;

  final int year;

  final String name;

  final String status;

  BillingPeriodModel({
    required this.id,
    required this.month,
    required this.year,
    required this.name,
    required this.status,
  });

  factory BillingPeriodModel.fromJson(Map<String, dynamic> json) {
    return BillingPeriodModel(
      id: json["id"] ?? 0,
      month: json["month"] ?? 0,
      year: json["year"] ?? 0,
      name: json["name"] ?? "",
      status: json["status"] ?? "",
    );
  }

  String get displayName {
    if (name.isNotEmpty) {
      return name;
    }

    return "Kỳ $month/$year";
  }
}
