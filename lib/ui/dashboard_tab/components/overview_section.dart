import 'package:flutter/material.dart';

import '../../../models/dashboard_model.dart';
import '../../helpers/format_helper.dart';
import 'kpi_card.dart';
import 'money_row.dart';
import 'white_card.dart';

class OverviewSection extends StatelessWidget {
  final DashboardOverviewModel overview;

  const OverviewSection({super.key, required this.overview});

  @override
  Widget build(BuildContext context) {
    final remainRecords =
        overview.totalRecordsImported - overview.totalCollectedRecords;

    final remainAmount =
        overview.totalExpectedAmount - overview.totalCollectedAmount;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: KpiCard(
                title: "Tổng số hồ sơ",
                value: "${overview.totalRecordsImported}",
                icon: Icons.upload_file,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KpiCard(
                title: "Đã thu",
                value: "${overview.totalCollectedRecords}",
                icon: Icons.check_circle,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: KpiCard(
                title: "Còn lại",
                value: "$remainRecords",
                icon: Icons.pending_actions,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KpiCard(
                title: "Tiến độ",
                value: "${overview.progressPercentage.toStringAsFixed(1)}%",
                icon: Icons.trending_up,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        WhiteCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Tổng quan tiền thu",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              MoneyRow(
                label: "Tổng phải thu",
                value: FormatHelper.formatMoney(overview.totalExpectedAmount),
              ),
              MoneyRow(
                label: "Đã thu",
                value: FormatHelper.formatMoney(overview.totalCollectedAmount),
                color: Colors.green,
              ),
              MoneyRow(
                label: "Còn lại",
                value: FormatHelper.formatMoney(remainAmount),
                color: Colors.red,
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (overview.progressPercentage / 100).clamp(0, 1),
                minHeight: 8,
                borderRadius: BorderRadius.circular(20),
                color: Colors.red,
                backgroundColor: Colors.red.withOpacity(0.2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
