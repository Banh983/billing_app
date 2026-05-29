class BillingPeriod {
  final int id;
  final int month;
  final int year;
  final String name;
  final String status;

  BillingPeriod({
    required this.id,
    required this.month,
    required this.year,
    required this.name,
    required this.status,
  });

  bool get isClosed => status.toUpperCase() == "CLOSED";

  bool get isOpen => status.toUpperCase() == "OPEN";

  factory BillingPeriod.fromJson(Map<String, dynamic> json) {
    return BillingPeriod(
      id: json["id"] ?? 0,
      month: json["month"] ?? 0,
      year: json["year"] ?? 0,
      name: json["name"] ?? "",
      status: json["status"] ?? "OPEN",
    );
  }
}
