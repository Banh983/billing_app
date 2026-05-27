import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'provider/auth_provider.dart';
import 'provider/employee_provider.dart';

import 'services/employee_service.dart';

import 'ui/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const String baseUrl = "http://192.168.1.73:8080";

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        /// ======================
        /// AUTH
        /// ======================
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        /// ======================
        /// EMPLOYEE (FIXED)
        /// ======================
        ChangeNotifierProxyProvider<AuthProvider, EmployeeProvider>(
          create: (_) =>
              EmployeeProvider(EmployeeService(baseUrl: baseUrl, token: "")),

          update: (_, auth, employeeProvider) {
            final token = auth.token ?? "";

            employeeProvider!.service = EmployeeService(
              baseUrl: baseUrl,
              token: token,
            );

            return employeeProvider;
          },
        ),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginPage(),
      ),
    );
  }
}
