import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';

class RecordActionButtons extends StatelessWidget {
  final bool isUnpaid;
  final bool canMarkDebt;
  final bool isPrinting;
  final bool isOpeningPreview;
  final Future<void> Function() onOpenPreview;
  final VoidCallback onMarkDebt;

  const RecordActionButtons({
    super.key,
    required this.isUnpaid,
    required this.canMarkDebt,
    required this.isPrinting,
    required this.isOpeningPreview,
    required this.onOpenPreview,
    required this.onMarkDebt,
  });

  bool get _isProcessing => isPrinting || isOpeningPreview;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: Colors.white,
              ),
              icon: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.print),
              label: Text(
                _isProcessing
                    ? "Đang xử lý..."
                    : isUnpaid
                    ? "Xem trước & thu tiền"
                    : "Xem trước & in lại",
              ),
              onPressed: _isProcessing ? null : onOpenPreview,
            ),
          ),
        ),

        if (canMarkDebt) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.account_balance_wallet_outlined),
                label: const Text(
                  "Gạch nợ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: onMarkDebt,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
