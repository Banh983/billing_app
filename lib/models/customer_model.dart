class CustomerModel {
  final int id;

  final int billingPeriodId;
  final String billingPeriodName;

  final String customerCode;
  final String customerName;
  final String subscriberNumber;
  final String phoneNumber;

  final double amountDue;

  final String province;
  final String ward;
  final String hamlet;
  final String street;
  final String fullAddress;

  final int? assignedConsultantId;
  final String assignedConsultantName;

  final String status;

  final double collectedAmount;

  final String collectedByName;
  final String collectedAt;
  final String billPrintedAt;

  final String debtMarkedByName;
  final String debtMarkedAt;

  final String syncWarning;
  final String syncWarningNote;

  final String createdAt;
  final String updatedAt;

  CustomerModel({
    required this.id,
    required this.billingPeriodId,
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
    required this.fullAddress,
    required this.assignedConsultantId,
    required this.assignedConsultantName,
    required this.status,
    required this.collectedAmount,
    required this.collectedByName,
    required this.collectedAt,
    required this.billPrintedAt,
    required this.debtMarkedByName,
    required this.debtMarkedAt,
    required this.syncWarning,
    required this.syncWarningNote,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json["id"] ?? 0,

      billingPeriodId: json["billingPeriodId"] ?? 0,
      billingPeriodName: json["billingPeriodName"] ?? "",

      customerCode: json["customerCode"] ?? "",
      customerName: json["customerName"] ?? "",
      subscriberNumber: json["subscriberNumber"] ?? "",
      phoneNumber: json["phoneNumber"] ?? "",

      amountDue: (json["amountDue"] ?? 0).toDouble(),

      province: json["province"] ?? "",
      ward: json["ward"] ?? "",
      hamlet: json["hamlet"] ?? "",
      street: json["street"] ?? "",
      fullAddress: json["fullAddress"] ?? "",

      assignedConsultantId: json["assignedConsultantId"],
      assignedConsultantName: json["assignedConsultantName"] ?? "",

      status: json["status"] ?? "",

      collectedAmount: (json["collectedAmount"] ?? 0).toDouble(),

      collectedByName: json["collectedByName"] ?? "",
      collectedAt: json["collectedAt"] ?? "",
      billPrintedAt: json["billPrintedAt"] ?? "",

      debtMarkedByName: json["debtMarkedByName"] ?? "",

      debtMarkedAt: json["debtMarkedAt"] ?? "",

      syncWarning: json["syncWarning"] ?? "",

      syncWarningNote: json["syncWarningNote"] ?? "",

      createdAt: json["createdAt"] ?? "",
      updatedAt: json["updatedAt"] ?? "",
    );
  }
}
