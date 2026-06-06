import 'package:billing_app/models/billing_record_model.dart';
import 'package:billing_app/ui/billing_period_tab/components/info_tile.dart';
import 'package:billing_app/ui/billing_period_tab/components/record_detail_card.dart';
import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';

class RecordCustomerSection extends StatelessWidget {
  final BillingRecordModel record;

  const RecordCustomerSection({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return RecordDetailCard(
      title: "THÔNG TIN KHÁCH HÀNG",
      titleColor: AppColors.softRed,
      children: [
        InfoTile("Tên khách hàng", record.customerName),
        InfoTile("Mã khách hàng", record.customerCode),
        InfoTile("Số điện thoại", record.phoneNumber),
        if (record.fullAddress != null && record.fullAddress!.isNotEmpty)
          InfoTile("Địa chỉ", record.fullAddress!),
      ],
    );
  }
}
