import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PrintPreviewPage extends StatelessWidget {
  final dynamic record;
  final String printerName;
  final String paperSizeLabel;
  final VoidCallback onConfirm;

  const PrintPreviewPage({
    super.key,
    required this.record,
    required this.printerName,
    required this.paperSizeLabel,
    required this.onConfirm,
  });

  String formatMoney(dynamic value) {
    final amount = (value ?? 0).toDouble();
    return NumberFormat("#,###", "vi_VN").format(amount);
  }

  @override
  Widget build(BuildContext context) {
    const shopName = "VIETTEL PHÙNG HIỆP";
    const shopPhone = "0987654321";
    const shopAddress = "Cây Dương, Hiệp Hưng, TP Cần Thơ";

    const consultantName = "Bui Dieu Huong";
    const consultantPhone = "0912345619";

    final billCode =
        "${record.customerCode}-${DateFormat("dd/MM/yyyy").format(DateTime.now())}";

    return Scaffold(
      appBar: AppBar(title: const Text("Xem trước hóa đơn")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= HEADER =================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black26,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          shopName,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          const Icon(Icons.phone),
                          const SizedBox(width: 10),
                          Text(shopPhone, style: const TextStyle(fontSize: 20)),
                        ],
                      ),

                      const SizedBox(height: 15),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              shopAddress,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                const Divider(thickness: 2, color: Colors.black),

                const SizedBox(height: 10),

                const Center(
                  child: Text(
                    "PHIẾU THU CƯỚC VIỄN THÔNG",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                  ),
                ),

                const SizedBox(height: 10),

                Center(
                  child: Text(billCode, style: const TextStyle(fontSize: 18)),
                ),

                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                  ),
                  child: Column(
                    children: [
                      _row("Khách hàng:", record.customerName),
                      _row("Mã KH:", record.customerCode),
                      _row("SĐT:", record.phoneNumber),
                      _row("Địa chỉ:", record.fullAddress ?? ""),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ================= TABLE =================
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: const [
                            Expanded(
                              flex: 1,
                              child: Text(
                                "STT",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(
                                "NỘI DUNG",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                "SL",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                "THÀNH TIỀN",
                                textAlign: TextAlign.right,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Divider(),

                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Expanded(flex: 1, child: Text("1")),
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Cước viễn thông",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Kỳ hóa đơn: ${record.billingPeriodName}",
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Expanded(
                              flex: 1,
                              child: Text("1", textAlign: TextAlign.center),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                formatMoney(record.amountDue),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const Divider(thickness: 1.5, color: Colors.black),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "TỔNG CỘNG",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      formatMoney(record.amountDue),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                const Divider(thickness: 1.5, color: Colors.black),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Số tiền thanh toán:",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      formatMoney(record.amountDue),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                  ),
                  child: Column(
                    children: [
                      _row("Ghi chú:", "N1 TT"),
                      _row("NVBH:", consultantName),
                      _row("SĐT nhân viên:", consultantPhone),
                      _row("Ghi chú cửa hàng:", "ADS"),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Center(
                  child: Text(
                    "Cảm ơn quý khách và hẹn gặp lại!",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.print),
                    onPressed: onConfirm,
                    label: const Text("IN HÓA ĐƠN"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(title, style: const TextStyle(fontSize: 18)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
