import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

enum PaperSizeType { mm58, mm80 }

class PrinterSettingsCard extends StatelessWidget {
  final BluetoothInfo? selectedPrinter;
  final PaperSizeType paperSize;
  final VoidCallback onSelectPrinter;
  final VoidCallback onSelectPaperSize;

  const PrinterSettingsCard({
    super.key,
    required this.selectedPrinter,
    required this.paperSize,
    required this.onSelectPrinter,
    required this.onSelectPaperSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onSelectPrinter,
                icon: const Icon(Icons.print, size: 18),
                label: Text(
                  selectedPrinter?.name ?? "Chọn máy in",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: onSelectPaperSize,
              icon: const Icon(Icons.straighten, size: 18),
              label: Text(paperSize == PaperSizeType.mm58 ? "58mm" : "80mm"),
            ),
          ],
        ),
        if (selectedPrinter != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "${selectedPrinter!.name} • ${selectedPrinter!.macAdress}",
                    style: const TextStyle(fontSize: 12, color: Colors.green),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
