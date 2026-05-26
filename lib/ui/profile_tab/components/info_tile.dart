import 'package:flutter/material.dart';

class InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final dynamic value;
  final Color primaryRed;

  const InfoTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.primaryRed = const Color(0xFFE53935),
  });

  @override
  Widget build(BuildContext context) {
    final String displayValue =
        (value == null || value.toString().trim().isEmpty)
        ? "Không có dữ liệu"
        : value.toString();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: primaryRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: primaryRed, size: 22),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),

              const SizedBox(height: 4),

              Text(
                displayValue,
                softWrap: true,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
