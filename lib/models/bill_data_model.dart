class BillDataModel {
  final String customerName;
  final String customerCode;

  final String subscriberNumber;

  final String address;

  final double amountDue;

  final String billingPeriod;

  BillDataModel({
    required this.customerName,
    required this.customerCode,
    required this.subscriberNumber,
    required this.address,
    required this.amountDue,
    required this.billingPeriod,
  });

  factory BillDataModel.fromJson(Map<String, dynamic> json) {
    return BillDataModel(
      customerName: json["customerName"] ?? "",
      customerCode: json["customerCode"] ?? "",
      subscriberNumber: json["subscriberNumber"] ?? "",
      address: json["address"] ?? "",
      amountDue: (json["amountDue"] ?? 0).toDouble(),
      billingPeriod: json["billingPeriod"] ?? "",
    );
  }
}
