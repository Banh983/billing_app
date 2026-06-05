import 'package:flutter/material.dart';

class ConfirmActionDialog extends StatelessWidget {
  final String title;

  /// Nội dung text thường
  final String message;

  /// Nội dung rich text (nếu muốn bôi đậm 1 phần)
  final InlineSpan? richMessage;

  final String cancelText;
  final String confirmText;

  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  final Color confirmColor;

  final IconData icon;
  final Color iconColor;

  const ConfirmActionDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.onCancel,
    this.richMessage,
    this.cancelText = "Hủy",
    this.confirmText = "Xác nhận",
    this.confirmColor = Colors.red,
    this.icon = Icons.help_outline,
    this.iconColor = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final textStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: 16,
      color: cs.onSurface.withOpacity(0.82),
      height: 1.35,
    );

    return Dialog(
      backgroundColor: cs.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: iconColor.withOpacity(0.12),
              child: Icon(icon, size: 32, color: iconColor),
            ),

            const SizedBox(height: 16),

            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),

            const SizedBox(height: 16),

            if (richMessage != null) ...[
              Text.rich(
                TextSpan(children: [richMessage!]),
                textAlign: TextAlign.center,
                style: textStyle,
              ),
            ] else ...[
              Text(message, textAlign: TextAlign.center, style: textStyle),
            ],

            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () {
                    onCancel?.call();
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(color: cs.outline),
                    foregroundColor: cs.onSurface,
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
                    Navigator.pop(context);
                    onConfirm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: confirmColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: theme.brightness == Brightness.dark ? 0 : 2,
                    shadowColor: cs.shadow.withOpacity(
                      theme.brightness == Brightness.dark ? 0.10 : 0.18,
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
    );
  }
}
