import 'package:flutter/material.dart';

import 'white_card.dart';

class WarningSection extends StatelessWidget {
  final List<dynamic> warnings;

  const WarningSection({super.key, required this.warnings});

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Cảnh báo hệ thống",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (warnings.isEmpty)
            const Text(
              "Không có cảnh báo",
              style: TextStyle(color: Colors.grey),
            )
          else
            ...warnings.map((item) {
              final text = _getWarningText(item);

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(text)),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  String _getWarningText(dynamic item) {
    if (item is Map<String, dynamic>) {
      return item["message"] ??
          item["title"] ??
          item["customerName"] ??
          item["customerCode"] ??
          item.toString();
    }

    return item.toString();
  }
}
