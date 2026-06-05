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

  Future<void> fetchDashboard({
    required String token,
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

      final today = DateTime.now();
      final date =
          "${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      final result = await Future.wait([
        service.getOverview(
          month: selectedMonth,
          year: selectedYear,
          token: token,
        ),
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

      overview = result[0] as DashboardOverviewModel;
      consultants = result[1] as List<ConsultantPerformanceModel>;
      dailyStats = result[2] as List<ConsultantDailyStatsModel>;
      warnings = result[3] as List<dynamic>;
    } catch (e) {
      error = e.toString().replaceAll("Exception: ", "");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh(String token) async {
    await fetchDashboard(
      token: token,
      month: selectedMonth,
      year: selectedYear,
    );
  }
}
