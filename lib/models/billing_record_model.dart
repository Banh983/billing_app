class BillingRecordModel {
  final int id;

  final int billingPeriodId;
  final String billingPeriodName;

  final String customerCode;
  final String customerName;
  final String subscriberNumber;
  final String phoneNumber;

  final double amountDue;

  final String? serviceType;

  final String? province;
  final String? ward;
  final String? hamlet;
  final String? street;
  final String? fullAddress;

  final int? assignedConsultantId;
  final String? assignedConsultantName;

  final String status;

  final double? collectedAmount;
  final String? collectedByName;

  final DateTime? collectedAt;
  final DateTime? billPrintedAt;

  final String? debtMarkedByName;
  final DateTime? debtMarkedAt;

  final String syncWarning;
  final String? syncWarningNote;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BillingRecordModel({
    required this.id,
    required this.billingPeriodId,
    required this.billingPeriodName,
    required this.customerCode,
    required this.customerName,
    required this.subscriberNumber,
    required this.phoneNumber,
    required this.amountDue,
    this.serviceType,
    this.province,
    this.ward,
    this.hamlet,
    this.street,
    this.fullAddress,
    this.assignedConsultantId,
    this.assignedConsultantName,
    required this.status,
    this.collectedAmount,
    this.collectedByName,
    this.collectedAt,
    this.billPrintedAt,
    this.debtMarkedByName,
    this.debtMarkedAt,
    required this.syncWarning,
    this.syncWarningNote,
    this.createdAt,
    this.updatedAt,
  });

  factory BillingRecordModel.fromJson(Map<String, dynamic> json) {
    return BillingRecordModel(
      id: json['id'] ?? 0,

      billingPeriodId: json['billingPeriodId'] ?? 0,
      billingPeriodName: json['billingPeriodName'] ?? '',

      customerCode: json['customerCode'] ?? '',
      customerName: json['customerName'] ?? '',
      subscriberNumber: json['subscriberNumber'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',

      amountDue: double.tryParse(json['amountDue']?.toString() ?? '0') ?? 0,

      serviceType: json['serviceType'],

      province: json['province'],
      ward: json['ward'],
      hamlet: json['hamlet'],
      street: json['street'],
      fullAddress: json['fullAddress'],

      assignedConsultantId: json['assignedConsultantId'],
      assignedConsultantName: json['assignedConsultantName'],

      status: json['status'] ?? 'CHUA_THU',

      collectedAmount: json['collectedAmount'] != null
          ? double.tryParse(json['collectedAmount'].toString())
          : null,

      collectedByName: json['collectedByName'],

      collectedAt: json['collectedAt'] != null
          ? DateTime.tryParse(json['collectedAt'])
          : null,

      billPrintedAt: json['billPrintedAt'] != null
          ? DateTime.tryParse(json['billPrintedAt'])
          : null,

      debtMarkedByName: json['debtMarkedByName'],

      debtMarkedAt: json['debtMarkedAt'] != null
          ? DateTime.tryParse(json['debtMarkedAt'])
          : null,

      syncWarning: json['syncWarning'] ?? 'NONE',

      syncWarningNote: json['syncWarningNote'],

      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,

      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'billingPeriodId': billingPeriodId,
      'billingPeriodName': billingPeriodName,
      'customerCode': customerCode,
      'customerName': customerName,
      'subscriberNumber': subscriberNumber,
      'phoneNumber': phoneNumber,
      'amountDue': amountDue,
      'serviceType': serviceType,
      'province': province,
      'ward': ward,
      'hamlet': hamlet,
      'street': street,
      'fullAddress': fullAddress,
      'assignedConsultantId': assignedConsultantId,
      'assignedConsultantName': assignedConsultantName,
      'status': status,
      'collectedAmount': collectedAmount,
      'collectedByName': collectedByName,
      'collectedAt': collectedAt?.toIso8601String(),
      'billPrintedAt': billPrintedAt?.toIso8601String(),
      'debtMarkedByName': debtMarkedByName,
      'debtMarkedAt': debtMarkedAt?.toIso8601String(),
      'syncWarning': syncWarning,
      'syncWarningNote': syncWarningNote,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  bool get isUnpaid => status == 'CHUA_THU';

  bool get isPaid => status == 'DA_THANH_TOAN';
}
