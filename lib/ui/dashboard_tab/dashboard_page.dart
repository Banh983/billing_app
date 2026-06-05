import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/auth_provider.dart';
import '../../provider/dashboard_provider.dart';

import 'components/consultant_section.dart';
import 'components/daily_stats_section.dart';
import 'components/error_view.dart';
import 'components/month_year_filter.dart';
import 'components/overview_section.dart';
import 'components/warning_section.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final token = context.read<AuthProvider>().token ?? "";

      context.read<DashboardProvider>().fetchDashboard(token: token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final token = context.read<AuthProvider>().token ?? "";

    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        title: const Text(
          "Dashboard Thu Cước",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.red,
        elevation: 0,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
          ? ErrorView(
              message: provider.error!,
              onRetry: () {
                provider.refresh(token);
              },
            )
          : RefreshIndicator(
              onRefresh: () => provider.refresh(token),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  MonthYearFilter(provider: provider, token: token),
                  const SizedBox(height: 16),

                  if (provider.overview != null)
                    OverviewSection(overview: provider.overview!),

                  const SizedBox(height: 16),
                  ConsultantSection(consultants: provider.consultants),

                  const SizedBox(height: 16),
                  DailyStatsSection(stats: provider.dailyStats),

                  const SizedBox(height: 16),
                  WarningSection(warnings: provider.warnings),
                ],
              ),
            ),
    );
  }
}
