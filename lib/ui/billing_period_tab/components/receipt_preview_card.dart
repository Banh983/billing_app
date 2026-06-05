import 'package:billing_app/ui/helpers/format_helper.dart';
import 'package:flutter/material.dart';

import '../../../../models/auth_model.dart';
import '../../../../models/billing_record_model.dart';
import '../../../../models/store_config_model.dart';
import 'receipt_preview_painters.dart';

class ReceiptPreviewCard extends StatelessWidget {
  final double width;
  final BillingRecordModel record;
  final StoreConfigModel storeConfig;
  final AuthModel? currentUser;
  final String displayDateTime;

  const ReceiptPreviewCard({
    super.key,
    required this.width,
    required this.record,
    required this.storeConfig,
    required this.currentUser,
    required this.displayDateTime,
  });

  String formatBillingPeriod(String value) {
    return value.replaceAll("Tháng ", "").replaceAll("tháng ", "").trim();
  }

  String get adsContent => record.adsContent.trim();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 16),
      child: DefaultTextStyle(
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          height: 1.25,
          fontFamily: "Roboto",
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _storeBox(),

            const SizedBox(height: 14),
            _solidLine(),

            const SizedBox(height: 14),
            _center("PHIẾU THU CƯỚC VIỄN THÔNG", fontSize: 21, bold: true),

            const SizedBox(height: 6),
            _center(displayDateTime, fontSize: 17),

            const SizedBox(height: 18),
            _customerBox(),

            const SizedBox(height: 14),
            _solidLine(),

            const SizedBox(height: 10),
            _table(),

            const SizedBox(height: 12),
            const DashedLine(),

            const SizedBox(height: 12),
            _amountRow(
              "TỔNG CỘNG",
              FormatHelper.formatMoneyOnly(record.amountDue),
              fontSize: 20,
              bold: true,
            ),

            const SizedBox(height: 14),
            _solidLine(),

            const SizedBox(height: 14),
            _amountRow(
              "Số tiền thanh toán:",
              FormatHelper.formatMoneyOnly(record.amountDue),
              fontSize: 18,
              bold: true,
            ),

            const SizedBox(height: 16),
            _noteBox(),

            const SizedBox(height: 12),
            const DashedLine(),

            const SizedBox(height: 10),
            _center(
              "Cảm ơn quý khách và hẹn gặp lại!",
              fontSize: 18,
              bold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _storeBox() {
    return DashedBorderBox(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              storeConfig.storeName.isNotEmpty
                  ? storeConfig.storeName
                  : "VIETTEL STORE",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                height: 1.15,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
              ),
            ),
          ),
          if (storeConfig.hotline.isNotEmpty) ...[
            const SizedBox(height: 14),
            _iconLine(Icons.phone, storeConfig.hotline),
          ],
          if (storeConfig.address.isNotEmpty) ...[
            const SizedBox(height: 12),
            _iconLine(Icons.location_on_outlined, storeConfig.address),
          ],
        ],
      ),
    );
  }

  Widget _customerBox() {
    return DashedBorderBox(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Column(
        children: [
          _infoLine("Khách hàng:", record.customerName),
          _infoLine("Mã KH:", record.customerCode),
          _infoLine("SĐT:", record.phoneNumber),
          if (record.fullAddress != null && record.fullAddress!.isNotEmpty)
            _infoLine("Địa chỉ:", record.fullAddress!),
        ],
      ),
    );
  }

  Widget _table() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SizedBox(
              width: 42,
              child: Text(
                "STT",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ),
            Expanded(
              child: Text(
                "NỘI DUNG",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ),
            SizedBox(
              width: 42,
              child: Text(
                "SL",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ),
            SizedBox(
              width: 106,
              child: Text(
                "THÀNH TIỀN",
                textAlign: TextAlign.right,
                maxLines: 1,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: 42,
              child: Text("1", style: TextStyle(fontSize: 16)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.serviceType.isNotEmpty
                        ? record.serviceType
                        : "Cước viễn thông",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Kỳ cước: ${formatBillingPeriod(record.billingPeriodName)}",
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 42,
              child: Text(
                "1",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(
              width: 106,
              child: Text(
                FormatHelper.formatMoneyOnly(record.amountDue),
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _noteBox() {
    final userName = currentUser?.fullName ?? "";
    final userPhone = currentUser?.phone ?? "";

    return DashedBorderBox(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoLine("NVBH:", userName),

          if (userPhone.isNotEmpty) _infoLine("SĐT NV:", userPhone),

          if (adsContent.isNotEmpty) ...[
            const SizedBox(height: 4),
            const Text(
              "Ghi chú:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              adsContent,
              textAlign: TextAlign.left,
              style: const TextStyle(fontSize: 15, height: 1.35),
            ),
          ],
        ],
      ),
    );
  }

  Widget _iconLine(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 27),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 18, height: 1.22)),
        ),
      ],
    );
  }

  Widget _center(String text, {double fontSize = 16, bool bold = false}) {
    return SizedBox(
      width: double.infinity,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          height: 1.16,
          fontWeight: bold ? FontWeight.w900 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _infoLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(label, style: const TextStyle(fontSize: 16)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountRow(
    String label,
    String amount, {
    double fontSize = 16,
    bool bold = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              height: 1.12,
              fontWeight: bold ? FontWeight.w900 : FontWeight.normal,
            ),
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: fontSize,
            height: 1.12,
            fontWeight: bold ? FontWeight.w900 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _solidLine() {
    return Container(width: double.infinity, height: 2, color: Colors.black);
  }
}
