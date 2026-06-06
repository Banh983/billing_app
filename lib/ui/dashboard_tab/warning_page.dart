import 'package:flutter/material.dart';

import 'components/warning_card.dart';

class WarningPage extends StatelessWidget {
  final List<dynamic> warnings;

  const WarningPage({super.key, required this.warnings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        title: const Text(
          "Chi tiết cảnh báo",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: warnings.isEmpty
          ? const Center(child: Text("Không có cảnh báo"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: warnings.length,
              itemBuilder: (context, index) {
                return WarningCard(item: warnings[index], compact: false);
              },
            ),
    );
  }
}
