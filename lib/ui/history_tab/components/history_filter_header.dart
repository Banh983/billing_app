import 'package:billing_app/core/app_colors.dart';
import 'package:flutter/material.dart';

class HistoryFilterHeader extends StatelessWidget {
  final bool expanded;
  final bool hasFilter;

  final String? dateText;
  final String? statusText;
  final String? searchText;

  final VoidCallback onTap;

  const HistoryFilterHeader({
    super.key,
    required this.expanded,
    required this.hasFilter,
    required this.dateText,
    required this.statusText,
    required this.searchText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.history, color: AppColors.primaryRed),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Bộ lọc lịch sử thu cước",
                    maxLines: 1,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  hasFilter ? _summaryText() : _emptySummaryText(),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AnimatedRotation(
              turns: expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 250),
              child: const Icon(Icons.keyboard_arrow_down),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptySummaryText() {
    return Text(
      "Chưa áp dụng bộ lọc",
      maxLines: 1,
      style: TextStyle(
        fontSize: 14,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: Colors.black.withOpacity(0.45),
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _summaryText() {
    return RichText(
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: const TextStyle(fontSize: 14, height: 1.45),
        children: [
          if (dateText != null && dateText!.trim().isNotEmpty) ...[
            const TextSpan(
              text: "Ngày thu: ",
              style: TextStyle(
                color: Color(0xFF616161),
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: dateText!,
              style: const TextStyle(
                color: Color(0xFFB71C1C),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (dateText != null &&
              dateText!.trim().isNotEmpty &&
              statusText != null &&
              statusText!.trim().isNotEmpty)
            const TextSpan(text: "\n"),
          if (statusText != null && statusText!.trim().isNotEmpty) ...[
            const TextSpan(
              text: "Trạng thái: ",
              style: TextStyle(
                color: Color(0xFF616161),
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: statusText!,
              style: const TextStyle(
                color: Color(0xFFB71C1C),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if ((dateText != null && dateText!.trim().isNotEmpty ||
                  statusText != null && statusText!.trim().isNotEmpty) &&
              searchText != null &&
              searchText!.trim().isNotEmpty)
            const TextSpan(text: "\n"),
          if (searchText != null && searchText!.trim().isNotEmpty) ...[
            const TextSpan(
              text: "Từ khóa: ",
              style: TextStyle(
                color: Color(0xFF616161),
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: searchText!,
              style: const TextStyle(
                color: Color(0xFFB71C1C),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
