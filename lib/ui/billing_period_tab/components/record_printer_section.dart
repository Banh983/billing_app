import 'package:billing_app/ui/billing_period_tab/components/printer_settings_card.dart';
import 'package:billing_app/ui/billing_period_tab/components/record_detail_card.dart';
import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../core/app_colors.dart';

class RecordPrinterSection extends StatelessWidget {
  final BluetoothInfo? selectedPrinter;
  final PaperSizeType paperSize;
  final Future<void> Function() onSelectPrinter;
  final Future<void> Function() onSelectPaperSize;

  const RecordPrinterSection({
    super.key,
    required this.selectedPrinter,
    required this.paperSize,
    required this.onSelectPrinter,
    required this.onSelectPaperSize,
  });

  @override
  Widget build(BuildContext context) {
    return RecordDetailCard(
      title: "CÀI ĐẶT MÁY IN",
      titleColor: AppColors.softRed,
      children: [
        PrinterSettingsCard(
          selectedPrinter: selectedPrinter,
          paperSize: paperSize,
          onSelectPrinter: onSelectPrinter,
          onSelectPaperSize: onSelectPaperSize,
        ),
      ],
    );
  }
}
