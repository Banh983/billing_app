import 'package:flutter/material.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  final String title;

  final String message;

  final String confirmText;

  final String cancelText;

  final IconData icon;

  final Color primaryColor;

  const ConfirmDeleteDialog({
    super.key,
    this.title = "Xác nhận xoá",
    required this.message,
    this.confirmText = "Xóa",
    this.cancelText = "Hủy",
    this.icon = Icons.delete_outline,
    this.primaryColor = const Color(0xFFE53935),
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),

      backgroundColor: cs.surface,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              // ======================
              // ICON
              // ======================
              CircleAvatar(
                radius: 30,

                backgroundColor: primaryColor.withOpacity(0.1),

                child: Icon(icon, size: 32, color: primaryColor),
              ),

              const SizedBox(height: 18),

              // ======================
              // TITLE
              // ======================
              Text(
                title,

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: cs.onSurface,
                ),
              ),

              const SizedBox(height: 14),

              // ======================
              // MESSAGE
              // ======================
              Text(
                message,

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 16,
                  color: cs.onSurfaceVariant,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 28),

              // ======================
              // ACTIONS
              // ======================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },

                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),

                      side: BorderSide(color: cs.outlineVariant),
                    ),

                    child: Text(
                      cancelText,

                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                  ),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,

                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    child: Text(
                      confirmText,

                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
