import 'package:billing_app/core/app_config.dart';
import 'package:billing_app/provider/auth_provider.dart';
import 'package:billing_app/provider/billing_period_provider.dart';
import 'package:billing_app/provider/billing_record_provider.dart';
import 'package:billing_app/provider/customer_provider.dart';
import 'package:billing_app/provider/dashboard_provider.dart';
import 'package:billing_app/provider/employee_provider.dart';

import 'package:billing_app/services/billing_period_service.dart';
import 'package:billing_app/services/billing_record_service.dart';
import 'package:billing_app/services/customer_service.dart';
import 'package:billing_app/services/dashboard_service.dart';
import 'package:billing_app/services/employee_service.dart';

import 'package:billing_app/ui/home_page.dart';
import 'package:billing_app/ui/login_page.dart';

import 'package:device_preview/device_preview.dart';
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

  final String baseUrl = AppConfig.baseUrl;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initAuth()),

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

        ChangeNotifierProxyProvider<AuthProvider, BillingRecordProvider>(
          create: (_) => BillingRecordProvider(
            BillingRecordService(baseUrl: baseUrl, token: ""),
          ),
          update: (_, auth, previous) {
            final token = auth.token ?? "";

            final provider =
                previous ??
                BillingRecordProvider(
                  BillingRecordService(baseUrl: baseUrl, token: token),
                );

            provider.service = BillingRecordService(
              baseUrl: baseUrl,
              token: token,
            );

            return provider;
          },
        ),

        ChangeNotifierProvider(
          create: (_) => DashboardProvider(DashboardService()),
        ),
      ],
      child: MaterialApp(
        useInheritedMediaQuery: true,
        locale: DevicePreview.locale(context),
        builder: (context, child) {
          child = DevicePreview.appBuilder(context, child);

          return SafeArea(top: false, child: child);
        },
        debugShowCheckedModeBanner: false,
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        if (auth.initializing) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (auth.isLoggedIn) {
          return HomePage(user: auth.user, token: auth.token ?? "");
        }

        return const LoginPage();
      },
    );
  }
}
