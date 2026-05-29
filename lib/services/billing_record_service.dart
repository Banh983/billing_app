import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/billing_record.dart';

class BillingRecordService {
  final String baseUrl;
  final String token;

  BillingRecordService({required this.baseUrl, required this.token});

  Map<String, String> get headers => {
    "Content-Type": "application/json",
    "Authorization": "Bearer $token",
  };

  /// =========================
  /// GET RECORDS BY BILLING PERIOD
  /// (FIX: backend KHÔNG có /records endpoint)
  /// =========================
  Future<List<BillingRecord>> getRecordsByPeriod(int periodId) async {
    final uri = Uri.parse("$baseUrl/billing-periods/$periodId");

    final response = await http.get(uri, headers: headers);

    print("GET BILLING PERIOD DETAIL: ${response.body}");

    final body = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(body["message"] ?? "Không thể lấy dữ liệu kỳ cước");
    }

    /// =========================
    /// HANDLE MULTIPLE POSSIBLE BACKEND STRUCTURES
    /// =========================

    dynamic data;

    // Case 1: API wrap kiểu {data: {...}}
    if (body is Map && body["data"] != null) {
      data = body["data"];
    } else {
      data = body;
    }

    /// records có thể nằm trong:
    /// - data.records
    /// - data.billingRecords
    /// - data.content (paging style)
    List<dynamic> records = [];

    if (data is Map) {
      if (data["records"] is List) {
        records = data["records"];
      } else if (data["billingRecords"] is List) {
        records = data["billingRecords"];
      } else if (data["content"] is List) {
        records = data["content"];
      }
    }

    return records
        .map((e) => BillingRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
