class CustomerRecordModel {
  final int? id;

  final int? billingPeriodId;
  final String? billingPeriodName;

  final String customerCode;
  final String customerName;
  final String? subscriberNumber;
  final String? phoneNumber;

  final double amountDue;

  final String? province;
  final String? ward;
  final String? hamlet;
  final String? street;
  final String? fullAddress;

  final int? assignedConsultantId;
  final String? assignedConsultantName;

  final String? status;

  final double? collectedAmount;
  final String? collectedByName;

  final DateTime? collectedAt;
  final DateTime? billPrintedAt;

  final String? debtMarkedByName;
  final DateTime? debtMarkedAt;

  final String? syncWarning;
  final String? syncWarningNote;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  CustomerRecordModel({
    this.id,
    this.billingPeriodId,
    this.billingPeriodName,
    required this.customerCode,
    required this.customerName,
    this.subscriberNumber,
    this.phoneNumber,
    required this.amountDue,
    this.province,
    this.ward,
    this.hamlet,
    this.street,
    this.fullAddress,
    this.assignedConsultantId,
    this.assignedConsultantName,
    this.status,
    this.collectedAmount,
    this.collectedByName,
    this.collectedAt,
    this.billPrintedAt,
    this.debtMarkedByName,
    this.debtMarkedAt,
    this.syncWarning,
    this.syncWarningNote,
    this.createdAt,
    this.updatedAt,
  });

  factory CustomerRecordModel.fromJson(Map<String, dynamic> json) {
    return CustomerRecordModel(
      id: json["id"],
      billingPeriodId: json["billingPeriodId"],
      billingPeriodName: json["billingPeriodName"],
      customerCode: json["customerCode"] ?? "",
      customerName: json["customerName"] ?? "",
      subscriberNumber: json["subscriberNumber"],
      phoneNumber: json["phoneNumber"],
      amountDue: (json["amountDue"] as num?)?.toDouble() ?? 0,
      province: json["province"],
      ward: json["ward"],
      hamlet: json["hamlet"],
      street: json["street"],
      fullAddress: json["fullAddress"],
      assignedConsultantId: json["assignedConsultantId"],
      assignedConsultantName: json["assignedConsultantName"],
      status: json["status"],
      collectedAmount: (json["collectedAmount"] as num?)?.toDouble(),
      collectedByName: json["collectedByName"],
      collectedAt: json["collectedAt"] != null
          ? DateTime.parse(json["collectedAt"])
          : null,
      billPrintedAt: json["billPrintedAt"] != null
          ? DateTime.parse(json["billPrintedAt"])
          : null,
      debtMarkedByName: json["debtMarkedByName"],
      debtMarkedAt: json["debtMarkedAt"] != null
          ? DateTime.parse(json["debtMarkedAt"])
          : null,
      syncWarning: json["syncWarning"],
      syncWarningNote: json["syncWarningNote"],
      createdAt: json["createdAt"] != null
          ? DateTime.parse(json["createdAt"])
          : null,
      updatedAt: json["updatedAt"] != null
          ? DateTime.parse(json["updatedAt"])
          : null,
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      "billingPeriodId": billingPeriodId,
      "customerCode": customerCode,
      "customerName": customerName,
      "subscriberNumber": subscriberNumber,
      "phoneNumber": phoneNumber,
      "amountDue": amountDue,
      "province": province,
      "ward": ward,
      "hamlet": hamlet,
      "street": street,
      "fullAddress": fullAddress,
    };
  }
}
