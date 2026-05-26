import 'package:flutter/material.dart';

class AppNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: "Trang chủ",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: "Hóa đơn",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: "Khách hàng"),
        BottomNavigationBarItem(icon: Icon(Icons.badge), label: "Nhân viên"),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Báo cáo"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Cá nhân"),
      ],
    );
  }
}
