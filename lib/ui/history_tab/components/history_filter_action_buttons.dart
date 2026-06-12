import 'package:billing_app/core/app_colors.dart';
import 'package:flutter/material.dart';

class HistoryFilterActionButtons extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback onSearch;

  const HistoryFilterActionButtons({
    super.key,
    required this.onReset,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 360;

        if (isSmall) {
          return Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: onReset,
                  child: const Text(
                    "ĐẶT LẠI",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: _searchButton(),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                ),
                onPressed: onReset,
                child: const Text(
                  "ĐẶT LẠI",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: SizedBox(height: 54, child: _searchButton()),
            ),
          ],
        );
      },
    );
  }

  Widget _searchButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed),
      onPressed: onSearch,
      icon: const Icon(Icons.search, color: Colors.white),
      label: const Text(
        "TÌM KIẾM",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
