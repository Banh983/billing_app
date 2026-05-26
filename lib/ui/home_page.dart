import 'package:billing_app/ui/employee_tab/employee_page.dart';
import 'package:billing_app/ui/profile_tab/profile_page.dart';
import 'package:flutter/material.dart';
import 'helpers/app_navigation.dart';

class HomePage extends StatefulWidget {
  final dynamic user;
  final String token;

  const HomePage({super.key, required this.user, required this.token});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    pages = [
      const Center(child: Text("Dashboard")), // 0
      const Center(child: Text("Hóa đơn chưa thu")), // 1
      const Center(child: Text("Khách hàng")), // 2
      const EmployeePage(), // 3
      const Center(child: Text("Báo cáo")), // 4
      ProfilePage(user: widget.user, token: widget.token), // 5
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hệ thống thu cước")),

      body: pages[currentIndex],

      bottomNavigationBar: AppNavigation(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
