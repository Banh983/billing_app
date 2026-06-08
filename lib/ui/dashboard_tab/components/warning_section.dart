import 'package:billing_app/ui/billing_period_tab/billing_record_detail_page.dart';
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
          _WarningSectionHeader(warnings: warnings),

          const SizedBox(height: 14),

          if (warnings.isEmpty)
            const Text(
              "Không có cảnh báo",
              style: TextStyle(color: Colors.grey),
            )
          else
            ...visibleWarnings.map((item) {
              return WarningCard(
                item: item,
                compact: true,
                onTap: () {
                  final recordId = item is Map<String, dynamic>
                      ? item["id"]
                      : null;

                  if (recordId == null) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BillingRecordDetailPage(
                        recordId: recordId,
                        periodStatus: item["billingPeriodStatus"] ?? "OPEN",
                      ),
                    ),
                  );
                },
              );
            }),

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

class _WarningSectionHeader extends StatelessWidget {
  final List<dynamic> warnings;

  const _WarningSectionHeader({required this.warnings});

  @override
  Widget build(BuildContext context) {
    final bool hasWarnings = warnings.isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNarrow = constraints.maxWidth < 330;

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TitleWithBadge(warnings: warnings),
              if (hasWarnings) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: _ViewAllButton(warnings: warnings),
                ),
              ],
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: _TitleWithBadge(warnings: warnings)),
            if (hasWarnings) _ViewAllButton(warnings: warnings),
          ],
        );
      },
    );
  }
}

class _TitleWithBadge extends StatelessWidget {
  final List<dynamic> warnings;

  const _TitleWithBadge({required this.warnings});

  @override
  Widget build(BuildContext context) {
    final bool hasWarnings = warnings.isNotEmpty;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.warning_amber_rounded, color: Colors.red),
        const SizedBox(width: 8),

        const Flexible(
          child: Text(
            "Cảnh báo hệ thống",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),

        if (hasWarnings) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
      ],
    );
  }
}

class _ViewAllButton extends StatelessWidget {
  final List<dynamic> warnings;

  const _ViewAllButton({required this.warnings});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: const Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => WarningPage(warnings: warnings)),
        );
      },
      child: const Text("Xem tất cả"),
    );
  }
}
