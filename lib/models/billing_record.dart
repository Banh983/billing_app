class BillingRecord {
  final int id;

  final String customerName;

  final String phone;

  final String address;

  final String billingPeriod;

  final double amount;

  final String serviceType;

  final bool paid;

  BillingRecord({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.billingPeriod,
    required this.amount,
    required this.serviceType,
    required this.paid,
  });

  factory BillingRecord.fromJson(Map<String, dynamic> json) {
    return BillingRecord(
      id: json["id"] ?? 0,

      customerName: json["customerName"] ?? "",

      phone: json["phone"] ?? "",

      address: json["address"] ?? "",

      billingPeriod: json["billingPeriod"] ?? "",

      amount: (json["amount"] ?? 0).toDouble(),

      serviceType: json["serviceType"] ?? "",

      paid: json["paid"] ?? false,
    );
  }
}
