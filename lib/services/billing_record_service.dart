import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/billing_record_model.dart';

class BillingRecordService {
  final String baseUrl;
  final String token;

  BillingRecordService({required this.baseUrl, required this.token});

  Map<String, String> get headers => {
    "Content-Type": "application/json",
    "Authorization": "Bearer $token",
  };

  Future<List<BillingRecordModel>> getRecordsByPeriod(int periodId) async {
    final uri = Uri.parse(
      "$baseUrl/records?periodId=$periodId&page=0&size=100",
    );

    final response = await http.get(uri, headers: headers);

    final body = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode != 200) {
      throw Exception(body["message"] ?? "Không thể tải danh sách khách hàng");
    }

    final List<dynamic> content = body["data"]?["content"] ?? [];

    return content.map((e) => BillingRecordModel.fromJson(e)).toList();
  }

  Future<BillingRecordModel> getRecordDetail(int id) async {
    final response = await http.get(
      Uri.parse("$baseUrl/records/$id"),
      headers: headers,
    );

    final body = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode != 200) {
      throw Exception(body["message"] ?? "Không thể lấy chi tiết khách hàng");
    }

    return BillingRecordModel.fromJson(body["data"]);
  }

  Future<void> printBill({
    required int recordId,
    required num collectedAmount,
  }) async {
    final response = await http.patch(
      Uri.parse("$baseUrl/records/$recordId/print-bill"),
      headers: headers,
      body: jsonEncode({"collectedAmount": collectedAmount}),
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(utf8.decode(response.bodyBytes));

      throw Exception(body["message"] ?? "Không thể in bill");
    }
  }

  Future<void> markDebt(int recordId) async {
    final response = await http.patch(
      Uri.parse("$baseUrl/records/$recordId/mark-debt"),
      headers: headers,
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(utf8.decode(response.bodyBytes));

      throw Exception(body["message"] ?? "Không thể gạch nợ");
    }
  }
}
