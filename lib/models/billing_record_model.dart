class BillingRecordModel {
  final int id;
  final int? billingPeriodId;
  final String billingPeriodName;

  final String customerCode;
  final String customerName;
  final String subscriberNumber;
  final String phoneNumber;
  final num amountDue;

  final String province;
  final String ward;
  final String hamlet;
  final String street;
  final String? fullAddress;

  final int? assignedConsultantId;
  final String assignedConsultantName;

  final String collectionStatus;
  final String debtStatus;

  final num collectedAmount;
  final String collectedBy;
  final DateTime? collectedAt;
  final DateTime? billPrintedAt;

  final String debtMarkedBy;
  final DateTime? debtMarkedAt;

  final String syncWarning;
  final String? syncWarningNote;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  BillingRecordModel({
    required this.id,
    this.billingPeriodId,
    required this.billingPeriodName,
    required this.customerCode,
    required this.customerName,
    required this.subscriberNumber,
    required this.phoneNumber,
    required this.amountDue,
    required this.province,
    required this.ward,
    required this.hamlet,
    required this.street,
    this.fullAddress,
    this.assignedConsultantId,
    required this.assignedConsultantName,
    required this.collectionStatus,
    required this.debtStatus,
    required this.collectedAmount,
    required this.collectedBy,
    this.collectedAt,
    this.billPrintedAt,
    required this.debtMarkedBy,
    this.debtMarkedAt,
    required this.syncWarning,
    this.syncWarningNote,
    this.createdAt,
    this.updatedAt,
  });

  factory BillingRecordModel.fromJson(Map<String, dynamic> json) {
    final data = json["data"] ?? json;

    return BillingRecordModel(
      id: data["id"] ?? 0,
      billingPeriodId: data["billingPeriodId"],
      billingPeriodName: data["billingPeriodName"]?.toString() ?? "",

      customerCode: data["customerCode"]?.toString() ?? "",
      customerName: data["customerName"]?.toString() ?? "",
      subscriberNumber: data["subscriberNumber"]?.toString() ?? "",
      phoneNumber: data["phoneNumber"]?.toString() ?? "",
      amountDue: _toNum(data["amountDue"]),

      province: data["province"]?.toString() ?? "",
      ward: data["ward"]?.toString() ?? "",
      hamlet: data["hamlet"]?.toString() ?? "",
      street: data["street"]?.toString() ?? "",
      fullAddress: data["fullAddress"]?.toString(),

      assignedConsultantId: data["assignedConsultantId"],
      assignedConsultantName: data["assignedConsultantName"]?.toString() ?? "",

      collectionStatus: data["collectionStatus"]?.toString() ?? "",
      debtStatus: data["debtStatus"]?.toString() ?? "",

      collectedAmount: _toNum(data["collectedAmount"]),
      collectedBy: data["collectedBy"]?.toString() ?? "",
      collectedAt: _toDate(data["collectedAt"]),
      billPrintedAt: _toDate(data["billPrintedAt"]),

      debtMarkedBy: data["debtMarkedBy"]?.toString() ?? "",
      debtMarkedAt: _toDate(data["debtMarkedAt"]),

      syncWarning: data["syncWarning"]?.toString() ?? "",
      syncWarningNote: data["syncWarningNote"]?.toString(),

      createdAt: _toDate(data["createdAt"]),
      updatedAt: _toDate(data["updatedAt"]),
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
