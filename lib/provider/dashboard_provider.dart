import 'package:flutter/material.dart';

import '../models/dashboard_model.dart';
import '../services/dashboard_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardService service;

  DashboardProvider(this.service);

  bool isLoading = false;
  String? error;

  DashboardOverviewModel? overview;
  List<ConsultantPerformanceModel> consultants = [];
  List<ConsultantDailyStatsModel> dailyStats = [];
  List<dynamic> warnings = [];

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  bool _canViewManagerDashboard(String role) {
    final normalizedRole = role.trim().toUpperCase();

    return normalizedRole == "MANAGER" || normalizedRole == "ADMIN";
  }

  Future<void> fetchDashboard({
    required String token,
    required String role,
    int? month,
    int? year,
  }) async {
    if (token.isEmpty) {
      error = "Phiên đăng nhập đã hết hạn";
      notifyListeners();
      return;
    }

    try {
      isLoading = true;
      error = null;
      notifyListeners();

      selectedMonth = month ?? selectedMonth;
      selectedYear = year ?? selectedYear;

      overview = await service.getOverview(
        month: selectedMonth,
        year: selectedYear,
        token: token,
      );

      if (_canViewManagerDashboard(role)) {
        final today = DateTime.now();

        final date =
            "${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

        final result = await Future.wait([
          service.getConsultants(
            month: selectedMonth,
            year: selectedYear,
            token: token,
          ),
          service.getDailyStats(date: date, token: token),
          service.getWarnings(
            month: selectedMonth,
            year: selectedYear,
            token: token,
          ),
        ]);

        consultants = result[0] as List<ConsultantPerformanceModel>;
        dailyStats = result[1] as List<ConsultantDailyStatsModel>;
        warnings = result[2];
      } else {
        consultants = [];
        dailyStats = [];
        warnings = [];
      }
    } catch (e) {
      error = e.toString().replaceAll("Exception: ", "");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh(String token, String role) async {
    await fetchDashboard(
      token: token,
      role: role,
      month: selectedMonth,
      year: selectedYear,
    );
  }
}
