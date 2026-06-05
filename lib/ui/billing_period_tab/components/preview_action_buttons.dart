import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';

class PreviewActionButtons extends StatelessWidget {
  final double width;
  final bool isPrinting;
  final bool isSharing;
  final bool isSaving;
  final VoidCallback onPrint;
  final VoidCallback onShare;
  final VoidCallback onSave;

  const PreviewActionButtons({
    super.key,
    required this.width,
    required this.isPrinting,
    required this.isSharing,
    required this.isSaving,
    required this.onPrint,
    required this.onShare,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 390;
          final itemWidth = isSmall
              ? (constraints.maxWidth - 10) / 2
              : (constraints.maxWidth - 20) / 3;

          return Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _ActionButton(
                width: itemWidth,
                label: isSaving ? "Đang lưu..." : "Lưu",
                icon: isSaving ? null : Icons.download_rounded,
                color: AppColors.softGreen,
                isLoading: isSaving,
                onPressed: isSaving ? null : onSave,
              ),

              _ActionButton(
                width: itemWidth,
                label: isSharing ? "Đang gửi..." : "Share",
                icon: isSharing ? null : Icons.share_rounded,
                color: AppColors.softBlue,
                isLoading: isSharing,
                onPressed: isSharing ? null : onShare,
              ),

              _ActionButton(
                width: isSmall ? constraints.maxWidth : itemWidth,
                label: isPrinting ? "Đang in..." : "In phiếu",
                icon: isPrinting ? null : Icons.print_rounded,
                color: AppColors.primaryRed,
                isLoading: isPrinting,
                onPressed: isPrinting ? null : onPrint,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final double width;
  final String label;
  final IconData? icon;
  final Color color;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.width,
    required this.label,
    required this.icon,
    required this.color,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(icon, size: 20),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: color.withOpacity(0.55),
          disabledForegroundColor: Colors.white,
          elevation: 3,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
