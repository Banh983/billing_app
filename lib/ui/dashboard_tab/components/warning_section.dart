import 'package:flutter/material.dart';

import '../../helpers/format_helper.dart';
import '../warning_page.dart';
import 'warning_card.dart';
import 'white_card.dart';

class WarningSection extends StatelessWidget {
  final List<dynamic> warnings;

  const WarningSection({super.key, required this.warnings});

  @override
  Widget build(BuildContext context) {
    final visibleWarnings = warnings.take(3).toList();

    return WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red),
              const SizedBox(width: 8),
              const Text(
                "Cảnh báo hệ thống",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),

              if (warnings.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    FormatHelper.formatCount(warnings.length),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],

              const Spacer(),

              if (warnings.isNotEmpty)
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WarningPage(warnings: warnings),
                      ),
                    );
                  },
                  child: const Text("Xem tất cả"),
                ),
            ],
          ),

          const SizedBox(height: 14),

          if (warnings.isEmpty)
            const Text(
              "Không có cảnh báo",
              style: TextStyle(color: Colors.grey),
            )
          else
            ...visibleWarnings.map(
              (item) => WarningCard(item: item, compact: true),
            ),

          if (warnings.length > 3) ...[
            const SizedBox(height: 4),
            Text(
              "Còn ${warnings.length - 3} cảnh báo khác cần kiểm tra.",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }
}
