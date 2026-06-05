import 'dart:convert';

import 'package:billing_app/core/app_config.dart';
import 'package:http/http.dart' as http;

import '../models/dashboard_model.dart';

class DashboardService {
  final String baseUrl = AppConfig.baseUrl;

  Map<String, String> _headers(String token) {
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  Future<DashboardOverviewModel> getOverview({
    required int month,
    required int year,
    required String token,
  }) async {
    final res = await http.get(
      Uri.parse("$baseUrl/dashboard/overview?month=$month&year=$year"),
      headers: _headers(token),
    );

    final data = jsonDecode(res.body);

    print("DASHBOARD OVERVIEW STATUS: ${res.statusCode}");
    print("DASHBOARD OVERVIEW BODY: ${res.body}");

    if (res.statusCode == 200 && data["data"] != null) {
      return DashboardOverviewModel.fromJson(data["data"]);
    }

    if (data["message"] != null) {
      throw Exception(data["message"]);
    }

    throw Exception("Không tải được tổng quan Dashboard");
  }

  Future<List<ConsultantPerformanceModel>> getConsultants({
    required int month,
    required int year,
    required String token,
  }) async {
    final res = await http.get(
      Uri.parse("$baseUrl/dashboard/consultants?month=$month&year=$year"),
      headers: _headers(token),
    );

    final data = jsonDecode(res.body);

    print("DASHBOARD CONSULTANTS STATUS: ${res.statusCode}");
    print("DASHBOARD CONSULTANTS BODY: ${res.body}");

    if (res.statusCode == 200 && data["data"] != null) {
      final list = data["data"] is List
          ? data["data"]
          : data["data"]["content"] ?? [];

      return List<ConsultantPerformanceModel>.from(
        list.map((e) => ConsultantPerformanceModel.fromJson(e)),
      );
    }

    if (data["message"] != null) {
      throw Exception(data["message"]);
    }

    throw Exception("Không tải được tiến độ nhân viên");
  }

  Future<List<ConsultantDailyStatsModel>> getDailyStats({
    required String date,
    required String token,
  }) async {
    final res = await http.get(
      Uri.parse("$baseUrl/dashboard/daily-stats?date=$date"),
      headers: _headers(token),
    );

    final data = jsonDecode(res.body);

    print("DASHBOARD DAILY STATUS: ${res.statusCode}");
    print("DASHBOARD DAILY BODY: ${res.body}");

    if (res.statusCode == 200 && data["data"] != null) {
      final list = data["data"] is List
          ? data["data"]
          : data["data"]["content"] ?? [];

      return List<ConsultantDailyStatsModel>.from(
        list.map((e) => ConsultantDailyStatsModel.fromJson(e)),
      );
    }

    if (data["message"] != null) {
      throw Exception(data["message"]);
    }

    throw Exception("Không tải được thống kê hôm nay");
  }

  Future<List<dynamic>> getWarnings({
    required int month,
    required int year,
    required String token,
    int page = 0,
    int size = 20,
  }) async {
    final res = await http.get(
      Uri.parse(
        "$baseUrl/dashboard/warnings?month=$month&year=$year&page=$page&size=$size",
      ),
      headers: _headers(token),
    );

    final data = jsonDecode(res.body);

    print("DASHBOARD WARNINGS STATUS: ${res.statusCode}");
    print("DASHBOARD WARNINGS BODY: ${res.body}");

    if (res.statusCode == 200 && data["data"] != null) {
      if (data["data"] is List) return data["data"];

      return data["data"]["content"] ?? [];
    }

    if (data["message"] != null) {
      throw Exception(data["message"]);
    }

    throw Exception("Không tải được danh sách cảnh báo");
  }
}
