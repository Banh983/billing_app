import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/billing_period_model.dart';

class BillingPeriodService {
  final String baseUrl;

  final String token;

  BillingPeriodService({required this.baseUrl, required this.token});

  Map<String, String> get headers => {
    "Content-Type": "application/json",
    "Authorization": "Bearer $token",
  };

  Future<List<BillingPeriodModel>> getBillingPeriods() async {
    final response = await http.get(
      Uri.parse("$baseUrl/billing-periods"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);

      final List<dynamic> content = json["data"]?["content"] ?? [];

      return content
          .map((e) => BillingPeriodModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception("Không thể tải kỳ cước: ${response.body}");
  }

  Future<void> closePeriod(int id) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/billing-periods/$id/close'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }
}
