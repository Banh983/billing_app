class CustomerRecordModel {
  final int id;

  final String customerCode;

  final String customerName;

  final String phoneNumber;

  final String ward;

  final String status;

  final double amountDue;

  CustomerRecordModel({
    required this.id,
    required this.customerCode,
    required this.customerName,
    required this.phoneNumber,
    required this.ward,
    required this.status,
    required this.amountDue,
  });

  factory CustomerRecordModel.fromJson(Map<String, dynamic> json) {
    return CustomerRecordModel(
      id: json["id"],

      customerCode: json["customerCode"] ?? "",

      customerName: json["customerName"] ?? "",

      phoneNumber: json["phoneNumber"] ?? "",

      ward: json["ward"] ?? "",

      status: json["status"] ?? "",

      amountDue: (json["amountDue"] ?? 0).toDouble(),
    );
  }
}
