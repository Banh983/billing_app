import 'package:flutter/material.dart';

import '../../../models/dashboard_model.dart';
import '../../helpers/format_helper.dart';
import 'white_card.dart';

class DailyStatsSection extends StatelessWidget {
  final List<ConsultantDailyStatsModel> stats;

  const DailyStatsSection({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Thống kê hôm nay",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (stats.isEmpty)
            const Text(
              "Chưa có dữ liệu hôm nay",
              style: TextStyle(color: Colors.grey),
            )
          else
            ...stats.map((item) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: Color(0xffffebee),
                  child: Icon(Icons.person, color: Colors.red),
                ),
                title: Text(
                  item.consultantName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  item.firstBillPrintedAt == null
                      ? "Chưa in bill hôm nay"
                      : "In bill đầu tiên: ${FormatHelper.formatDateTime(item.firstBillPrintedAt)}",
                ),
                trailing: Text(
                  "${item.collectedCount}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 16,
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
