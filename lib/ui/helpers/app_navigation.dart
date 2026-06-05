import 'package:flutter/material.dart';

class AppNavigation extends StatelessWidget {
  final int currentIndex;
  final bool isManager;
  final Function(int) onTap;

  const AppNavigation({
    super.key,
    required this.currentIndex,
    required this.isManager,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFE53935),
      unselectedItemColor: Colors.grey,
      onTap: onTap,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: "Trang chủ",
        ),

        const BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: "Hóa đơn",
        ),

        // const BottomNavigationBarItem(
        //   icon: Icon(Icons.people),
        //   label: "Khách hàng",
        // ),
        if (isManager)
          const BottomNavigationBarItem(
            icon: Icon(Icons.badge),
            label: "Nhân viên",
          ),

        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Cá nhân",
        ),
      ],
    );
  }
}
