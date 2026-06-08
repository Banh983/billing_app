import 'package:flutter/material.dart';

class EnableBluetoothDialog extends StatelessWidget {
  final String title;
  final String message;

  const EnableBluetoothDialog({
    super.key,
    this.title = "Bật Bluetooth",
    this.message =
        "Bluetooth hiện đang tắt.\nVui lòng bật Bluetooth để chọn và kết nối máy in.",
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
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: const Icon(
                  Icons.bluetooth,
                  size: 32,
                  color: Colors.blue,
                ),
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
                      "Hủy",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                  ),

                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    icon: const Icon(Icons.bluetooth, color: Colors.white),
                    label: const Text(
                      "Bật Bluetooth",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
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
