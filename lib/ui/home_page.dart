import 'package:billing_app/ui/billing_period_tab/billing_period_page.dart';
import 'package:billing_app/ui/customer_tab/customer_page.dart';
import 'package:billing_app/ui/dashboard_tab/dashboard_page.dart';
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

  late dynamic currentUser;

  @override
  void initState() {
    super.initState();

    currentUser = widget.user;
  }

  bool get isManager {
    final role = currentUser?.role?.toString().toUpperCase().trim();

    return role == "MANAGER";
  }

  List<Widget> get pages {
    return [
      DashboardPage(),

      BillingPeriodPage(),

      // CustomerPage(),

      if (isManager) EmployeePage(),

      ProfilePage(
        user: currentUser,
        token: widget.token,
        onUserUpdated: (updatedUser) {
          print("HOME RECEIVED: ${updatedUser.fullName}");
          setState(() {
            currentUser = updatedUser;
          });
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final pageList = pages;

    return Scaffold(
      appBar: AppBar(title: const Text("Hệ thống thu cước")),

      body: pageList[currentIndex],

      bottomNavigationBar: AppNavigation(
        currentIndex: currentIndex,
        isManager: isManager,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
