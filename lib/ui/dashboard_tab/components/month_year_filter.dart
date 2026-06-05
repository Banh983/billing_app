import 'package:flutter/material.dart';

import '../../../provider/dashboard_provider.dart';
import '../../helpers/custom_dropdown_field.dart';

class MonthYearFilter extends StatelessWidget {
  final DashboardProvider provider;
  final String token;

  const MonthYearFilter({
    super.key,
    required this.provider,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;

    return Row(
      children: [
        Expanded(
          child: CustomDropdownField<int>(
            label: "Tháng",
            icon: Icons.calendar_month,
            value: provider.selectedMonth,
            items: List.generate(12, (index) {
              final month = index + 1;

              return DropdownMenuItem<int>(
                value: month,
                child: Text("Tháng $month"),
              );
            }),
            onChanged: (value) {
              if (value == null) return;

              provider.fetchDashboard(
                token: token,
                month: value,
                year: provider.selectedYear,
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomDropdownField<int>(
            label: "Năm",
            icon: Icons.date_range,
            value: provider.selectedYear,
            items: List.generate(10, (index) {
              final year = currentYear - index;

              return DropdownMenuItem<int>(value: year, child: Text("$year"));
            }),
            onChanged: (value) {
              if (value == null) return;

              provider.fetchDashboard(
                token: token,
                month: provider.selectedMonth,
                year: value,
              );
            },
          ),
        ),
      ],
    );
  }
}
