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

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        /// ======================
        /// AUTH
        /// ======================
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        /// ======================
        /// EMPLOYEE (AUTO SYNC TOKEN)
        /// ======================
        ChangeNotifierProxyProvider<AuthProvider, EmployeeProvider>(
          create: (_) => EmployeeProvider(
            EmployeeService(baseUrl: "http://192.168.97.204:8080", token: ""),
          ),

          update: (_, auth, previous) {
            final token = auth.token ?? "";

            return EmployeeProvider(
              EmployeeService(
                baseUrl: "http://192.168.97.204:8080",
                token: token,
              ),
            );
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
