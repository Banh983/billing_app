import 'package:billing_app/provider/auth_provider.dart';
import 'package:billing_app/provider/billing_period_provider.dart';
import 'package:billing_app/provider/billing_record_provider.dart';
import 'package:billing_app/provider/customer_provider.dart';
import 'package:billing_app/provider/employee_provider.dart';

import 'package:billing_app/services/billing_period_service.dart';
import 'package:billing_app/services/billing_record_service.dart';
import 'package:billing_app/services/customer_service.dart';
import 'package:billing_app/services/employee_service.dart';

import 'package:billing_app/ui/login_page.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const String baseUrl = "http://192.168.1.158:8080";

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        /// =========================
        /// AUTH
        /// =========================
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        /// =========================
        /// EMPLOYEE PROVIDER
        /// =========================
        ChangeNotifierProxyProvider<AuthProvider, EmployeeProvider>(
          create: (_) =>
              EmployeeProvider(EmployeeService(baseUrl: baseUrl, token: "")),

          update: (_, auth, previous) {
            final token = auth.token ?? "";

            previous!.service = EmployeeService(baseUrl: baseUrl, token: token);

            return previous;
          },
        ),

        /// =========================
        /// BILLING PERIOD PROVIDER
        /// =========================
        ChangeNotifierProxyProvider<AuthProvider, BillingPeriodProvider>(
          create: (_) => BillingPeriodProvider(
            BillingPeriodService(baseUrl: baseUrl, token: ""),
          ),

          update: (_, auth, previous) {
            final token = auth.token ?? "";

            previous!.service = BillingPeriodService(
              baseUrl: baseUrl,
              token: token,
            );

            return previous;
          },
        ),

        /// =========================
        /// CUSTOMER PROVIDER
        /// =========================
        ChangeNotifierProxyProvider<AuthProvider, CustomerProvider>(
          create: (_) =>
              CustomerProvider(CustomerService(baseUrl: baseUrl, token: "")),

          update: (_, auth, previous) {
            final token = auth.token ?? "";

            previous!.service = CustomerService(baseUrl: baseUrl, token: token);

            return previous;
          },
        ),

        /// =========================
        /// BILLING RECORD PROVIDER
        /// =========================
        ChangeNotifierProxyProvider<AuthProvider, BillingRecordProvider>(
          create: (_) => BillingRecordProvider(
            BillingRecordService(baseUrl: baseUrl, token: ""),
          ),

          update: (_, auth, previous) {
            final token = auth.token ?? "";

            previous!.service = BillingRecordService(
              baseUrl: baseUrl,
              token: token,
            );

            return previous;
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
