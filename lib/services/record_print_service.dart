import 'dart:convert';
import 'package:billing_app/core/app_config.dart';
import 'package:http/http.dart' as http;

import '../models/bill_data_model.dart';

class RecordPrintService {
  final String baseUrl = AppConfig.baseUrl;

  Future<void> printBill({
    required int recordId,
    required num collectedAmount,
    required String token,
  }) async {
    final res = await http.patch(
      Uri.parse("$baseUrl/records/$recordId/print-bill"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"collectedAmount": collectedAmount}),
    );

    final body = utf8.decode(res.bodyBytes);
    final data = body.isNotEmpty ? jsonDecode(body) : {};

    if (res.statusCode == 200) return;

    throw Exception(data["message"] ?? "Thu tiền/in phiếu thất bại");
  }

  Future<BillDataModel> getBillData({
    required int recordId,
    required String token,
  }) async {
    final res = await http.get(
      Uri.parse("$baseUrl/records/$recordId/bill-data"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final body = utf8.decode(res.bodyBytes);
    final data = body.isNotEmpty ? jsonDecode(body) : {};

    if (res.statusCode == 200) {
      return BillDataModel.fromJson(data);
    }

    throw Exception(data["message"] ?? "Không lấy được dữ liệu phiếu thu");
  }
}
