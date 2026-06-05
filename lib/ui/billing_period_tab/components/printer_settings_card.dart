import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../core/app_colors.dart';

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
    final hasPrinter = selectedPrinter != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 340;

          return Column(
            children: [
              if (isSmall)
                Column(
                  children: [
                    _SettingTile(
                      icon: Icons.print_rounded,
                      title: hasPrinter ? "Máy in đã chọn" : "Máy in",
                      value: selectedPrinter?.name ?? "Chọn máy in",
                      color: hasPrinter
                          ? AppColors.softGreen
                          : AppColors.softBlue,
                      onTap: onSelectPrinter,
                    ),
                    const SizedBox(height: 10),
                    _SettingTile(
                      icon: Icons.straighten_rounded,
                      title: "Khổ giấy",
                      value: paperSize == PaperSizeType.mm58 ? "58mm" : "80mm",
                      color: AppColors.softRed,
                      onTap: onSelectPaperSize,
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: _SettingTile(
                        icon: Icons.print_rounded,
                        title: hasPrinter ? "Máy in đã chọn" : "Máy in",
                        value: selectedPrinter?.name ?? "Chọn máy in",
                        color: hasPrinter
                            ? AppColors.softGreen
                            : AppColors.softBlue,
                        onTap: onSelectPrinter,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: _SettingTile(
                        icon: Icons.straighten_rounded,
                        title: "Khổ giấy",
                        value: paperSize == PaperSizeType.mm58
                            ? "58mm"
                            : "80mm",
                        color: AppColors.softRed,
                        onTap: onSelectPaperSize,
                      ),
                    ),
                  ],
                ),

              if (hasPrinter) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.softGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.softGreen,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "${selectedPrinter!.name} • ${selectedPrinter!.macAdress}",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.softGreenDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      child: Material(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
