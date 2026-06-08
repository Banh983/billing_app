import 'package:flutter/material.dart';

import '../../../provider/dashboard_provider.dart';
import '../../helpers/custom_dropdown_field.dart';

class MonthYearFilter extends StatelessWidget {
  final DashboardProvider provider;
  final String token;
  final String role;

  const MonthYearFilter({
    super.key,
    required this.provider,
    required this.token,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 430;

        final itemWidth = isSmallScreen
            ? constraints.maxWidth
            : (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: itemWidth,
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
                    role: role,
                    month: value,
                    year: provider.selectedYear,
                  );
                },
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: CustomDropdownField<int>(
                label: "Năm",
                icon: Icons.date_range,
                value: provider.selectedYear,
                items: List.generate(10, (index) {
                  final year = currentYear - index;

                  return DropdownMenuItem<int>(
                    value: year,
                    child: Text("$year"),
                  );
                }),
                onChanged: (value) {
                  if (value == null) return;

                  provider.fetchDashboard(
                    token: token,
                    role: role,
                    month: provider.selectedMonth,
                    year: value,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
