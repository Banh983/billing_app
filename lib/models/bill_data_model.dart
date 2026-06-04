class BillDataModel {
  final String storeName;
  final String address;
  final String hotline;
  final String? qrUrl;
  final String adsText;

  final String customerCode;
  final String customerName;
  final String subscriberNumber;
  final String fullAddress;
  final String billingPeriodName;
  final String serviceType;

  final num amountDue;
  final num collectedAmount;

  final DateTime? collectedAt;
  final String collectedBy;
  final DateTime? billPrintedAt;

  BillDataModel({
    required this.storeName,
    required this.address,
    required this.hotline,
    required this.qrUrl,
    required this.adsText,
    required this.customerCode,
    required this.customerName,
    required this.subscriberNumber,
    required this.fullAddress,
    required this.billingPeriodName,
    required this.serviceType,
    required this.amountDue,
    required this.collectedAmount,
    required this.collectedAt,
    required this.collectedBy,
    required this.billPrintedAt,
  });

  factory BillDataModel.fromJson(Map<String, dynamic> json) {
    final data = json["data"] ?? json;

    return BillDataModel(
      storeName: data["storeName"]?.toString() ?? "",
      address: data["address"]?.toString() ?? "",
      hotline: data["hotline"]?.toString() ?? "",
      qrUrl: data["qrUrl"]?.toString(),
      adsText: data["adsText"]?.toString() ?? "",

      customerCode: data["customerCode"]?.toString() ?? "",
      customerName: data["customerName"]?.toString() ?? "",
      subscriberNumber: data["subscriberNumber"]?.toString() ?? "",
      fullAddress: data["fullAddress"]?.toString() ?? "",
      billingPeriodName: data["billingPeriodName"]?.toString() ?? "",
      serviceType: data["serviceType"]?.toString() ?? "",

      amountDue: _toNum(data["amountDue"]),
      collectedAmount: _toNum(data["collectedAmount"]),

      collectedAt: _toDate(data["collectedAt"]),
      collectedBy: data["collectedBy"]?.toString() ?? "",
      billPrintedAt: _toDate(data["billPrintedAt"]),
    );
  }

  static num _toNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    return num.tryParse(value.toString()) ?? 0;
  }

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
