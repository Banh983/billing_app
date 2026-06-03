class BillingCustomerRecordModel {

  final String customerName;

  final String phone;

  final String address;

  final String period;

  final String service;

  final String amount;

  final String status;

  BillingCustomerRecordModel({
    required this.customerName,
    required this.phone,
    required this.address,
    required this.period,
    required this.service,
    required this.amount,
    required this.status,
  });
}

final List<BillingCustomerRecordModel>
    sampleBillingCustomerRecords = [

  BillingCustomerRecordModel(
    customerName: "HUỲNH THỊ BÍCH LIÊN",
    phone: "0939913467",
    address: "Ấp 6 • Hòa An",
    period: "05/2026",
    service: "FTTH",
    amount: "205,000",
    status: "ĐÃ THU",
  ),

  BillingCustomerRecordModel(
    customerName: "NGUYỄN VĂN BẢN",
    phone: "0901219057",
    address: "Ấp 2 • Hiệp Hưng",
    period: "05/2026",
    service: "ĐÓNG 6 THÁNG",
    amount: "1,560,000",
    status: "ĐÃ THU",
  ),
];
