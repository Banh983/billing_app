import 'package:billing_app/models/billing_record_model.dart';
import 'package:billing_app/ui/billing_period_tab/components/info_tile.dart';
import 'package:billing_app/ui/billing_period_tab/components/record_detail_card.dart';
import 'package:billing_app/ui/helpers/format_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/app_colors.dart';

class RecordInvoiceSection extends StatelessWidget {
  final BillingRecordModel record;

  RecordInvoiceSection({super.key, required this.record});

  final NumberFormat currencyFormat = NumberFormat("#,###", "vi_VN");

  String _collectionStatusText(String status) {
    if (status == "CHUA_THU") return "Chưa thu";
    if (status == "DA_THANH_TOAN") return "Đã thanh toán";
    return status;
  }

  String _debtStatusText(String status) {
    if (status == "CHUA_GACH_NO") return "Chưa gạch nợ";
    if (status == "DA_GACH_NO") return "Đã gạch nợ";
    return status;
  }

  @override
  Widget build(BuildContext context) {
    return RecordDetailCard(
      title: "THÔNG TIN HÓA ĐƠN",
      titleColor: AppColors.softRed,
      children: [
        InfoTile("Kỳ hoá đơn", record.billingPeriodName),

        InfoTile("Số tiền", "${currencyFormat.format(record.amountDue)} đ"),

        InfoTile(
          "Trạng thái thu",
          _collectionStatusText(record.collectionStatus),
        ),

        if (record.collectionStatus == "DA_THANH_TOAN")
          InfoTile(
            "Ngày thu",
            record.collectedAt == null
                ? "-"
                : FormatHelper.formatDateTime(record.collectedAt),
          ),

        InfoTile("Trạng thái gạch nợ", _debtStatusText(record.debtStatus)),
      ],
    );
  }
}
