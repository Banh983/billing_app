import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/auth_model.dart';
import '../../models/billing_record_model.dart';
import '../../models/store_config_model.dart';

class PrintPreviewPage extends StatefulWidget {
  final BillingRecordModel record;
  final StoreConfigModel storeConfig;
  final AuthModel? currentUser;
  final String printerName;
  final String paperSizeLabel;
  final Future<void> Function() onConfirm;

  const PrintPreviewPage({
    super.key,
    required this.record,
    required this.storeConfig,
    required this.currentUser,
    required this.printerName,
    required this.paperSizeLabel,
    required this.onConfirm,
  });

  @override
  State<PrintPreviewPage> createState() => _PrintPreviewPageState();
}

class _PrintPreviewPageState extends State<PrintPreviewPage> {
  bool _isPrinting = false;

  String formatMoney(dynamic value) {
    return NumberFormat("#,###", "vi_VN").format(value ?? 0);
  }

  Future<void> _handleConfirm() async {
    if (_isPrinting) return;

    setState(() => _isPrinting = true);

    try {
      await widget.onConfirm();
    } finally {
      if (mounted) {
        setState(() => _isPrinting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    final user = widget.currentUser;
    final store = widget.storeConfig;

    final billCode =
        "${record.customerCode} - ${DateFormat("dd/MM/yyyy").format(DateTime.now())}";

    final paperWidth = widget.paperSizeLabel == "80mm" ? 430.0 : 330.0;

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(title: const Text("Xem trước phiếu thu")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Column(
            children: [
              _printerInfo(paperWidth),

              const SizedBox(height: 12),

              Container(
                width: paperWidth,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black26),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: DefaultTextStyle(
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    height: 1.3,
                    fontFamily: "monospace",
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _storeBox(store),

                      const SizedBox(height: 12),
                      const Divider(thickness: 1.5, color: Colors.black),

                      const SizedBox(height: 8),

                      _center(
                        "PHIẾU THU CƯỚC VIỄN THÔNG",
                        fontSize: 16,
                        bold: true,
                      ),

                      const SizedBox(height: 4),

                      _center(billCode),

                      const SizedBox(height: 12),

                      _customerBox(record),

                      const SizedBox(height: 12),
                      const Divider(thickness: 1.5, color: Colors.black),

                      _table(record),

                      const SizedBox(height: 8),
                      _dash(),

                      _amountRow(
                        "TỔNG CỘNG",
                        "${formatMoney(record.amountDue)} đ",
                        fontSize: 16,
                        bold: true,
                      ),

                      const SizedBox(height: 8),
                      const Divider(thickness: 1.5, color: Colors.black),

                      _amountRow(
                        "Số tiền thanh toán:",
                        "${formatMoney(record.amountDue)} đ",
                        fontSize: 15,
                        bold: true,
                      ),

                      const SizedBox(height: 12),

                      _noteBox(
                        userName: user?.fullName ?? "",
                        userPhone: user?.phone ?? "",
                        adsText: store.adsText,
                      ),

                      const SizedBox(height: 8),
                      _dash(),

                      if (store.adsText.isNotEmpty)
                        _center(store.adsText, fontSize: 15, bold: true),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: paperWidth,
                height: 50,
                child: ElevatedButton.icon(
                  icon: _isPrinting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.print),
                  onPressed: _isPrinting ? null : _handleConfirm,
                  label: Text(_isPrinting ? "Đang in..." : "IN PHIẾU THU"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _printerInfo(double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueGrey.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.print, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Máy in: ${widget.printerName}",
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            widget.paperSizeLabel,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _storeBox(StoreConfigModel store) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26, style: BorderStyle.solid),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _center(
            store.storeName.isNotEmpty ? store.storeName : "PHIẾU THU",
            fontSize: 20,
            bold: true,
          ),
          if (store.hotline.isNotEmpty) ...[
            const SizedBox(height: 8),
            _iconLine(Icons.phone, store.hotline),
          ],
          if (store.address.isNotEmpty) ...[
            const SizedBox(height: 8),
            _iconLine(Icons.location_on_outlined, store.address),
          ],
        ],
      ),
    );
  }

  Widget _customerBox(BillingRecordModel record) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          _line("Khách hàng:", record.customerName),
          _line("Mã KH:", record.customerCode),
          _line("SĐT:", record.phoneNumber),
          if (record.fullAddress != null && record.fullAddress!.isNotEmpty)
            _line("Địa chỉ:", record.fullAddress!),
        ],
      ),
    );
  }

  Widget _table(BillingRecordModel record) {
    return Column(
      children: [
        Row(
          children: const [
            Expanded(
              flex: 1,
              child: Text("STT", style: TextStyle(fontWeight: FontWeight.bold)),
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

        const SizedBox(height: 8),

        Row(
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
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Kỳ hoá đơn: ${record.billingPeriodName}",
                    style: const TextStyle(fontStyle: FontStyle.italic),
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
      ],
    );
  }

  Widget _noteBox({
    required String userName,
    required String userPhone,
    required String adsText,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(border: Border.all(color: Colors.black26)),
      child: Column(
        children: [
          _rightLine("Ghi chú:", "N1 TT"),
          _rightLine("NVBH:", userName),
          if (userPhone.isNotEmpty) _rightLine("SĐT nhân viên:", userPhone),
          if (adsText.isNotEmpty) _rightLine("Ghi chú cửa hàng:", "ADS"),
        ],
      ),
    );
  }

  Widget _iconLine(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  Widget _center(String text, {double fontSize = 13, bool bold = false}) {
    return SizedBox(
      width: double.infinity,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _dash() {
    return const Text(
      "----------------------------------------",
      maxLines: 1,
      overflow: TextOverflow.clip,
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 92, child: Text(label)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rightLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _amountRow(
    String label,
    String amount, {
    double fontSize = 13,
    bool bold = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
