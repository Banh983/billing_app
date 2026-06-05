import 'package:flutter/material.dart';

import '../../../models/dashboard_model.dart';
import '../../helpers/format_helper.dart';
import 'white_card.dart';

class ConsultantSection extends StatelessWidget {
  final List<ConsultantPerformanceModel> consultants;

  const ConsultantSection({super.key, required this.consultants});

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tiến độ nhân viên",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (consultants.isEmpty)
            const Text(
              "Chưa có dữ liệu nhân viên",
              style: TextStyle(color: Colors.grey),
            )
          else
            ...consultants.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.consultantName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: item.progress.clamp(0, 1),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${item.collectedRecords}/${item.targetRecords} hóa đơn",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${FormatHelper.formatMoney(item.collectedAmount)} / ${FormatHelper.formatMoney(item.targetAmount)}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
