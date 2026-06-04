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
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('vi_VN', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const String baseUrl = "http://192.168.1.164:8080";

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

            final provider =
                previous ??
                EmployeeProvider(
                  EmployeeService(baseUrl: baseUrl, token: token),
                );

            provider.service = EmployeeService(baseUrl: baseUrl, token: token);

            return provider;
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

            final provider =
                previous ??
                BillingPeriodProvider(
                  BillingPeriodService(baseUrl: baseUrl, token: token),
                );

            provider.service = BillingPeriodService(
              baseUrl: baseUrl,
              token: token,
            );

            return provider;
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

            final provider =
                previous ??
                CustomerProvider(
                  CustomerService(baseUrl: baseUrl, token: token),
                );

            provider.service = CustomerService(baseUrl: baseUrl, token: token);

            return provider;
          },
        ),

        /// =========================
        /// BILLING RECORD PROVIDER
        /// =========================
        ChangeNotifierProxyProvider<AuthProvider, BillingRecordProvider>(
          create: (_) => BillingRecordProvider(
            BillingRecordService(baseUrl: baseUrl, token: ""),
          ),

          update: (_, auth, _) {
            final token = auth.token ?? "";

            return BillingRecordProvider(
              BillingRecordService(baseUrl: baseUrl, token: token),
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
