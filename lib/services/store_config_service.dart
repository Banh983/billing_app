import 'dart:convert';
import 'package:billing_app/core/app_config.dart';
import 'package:http/http.dart' as http;

import '../models/store_config_model.dart';

class StoreConfigService {
  final String baseUrl = AppConfig.baseUrl;

  Future<StoreConfigModel> getConfig({required String token}) async {
    final res = await http.get(
      Uri.parse("$baseUrl/store-config"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final body = utf8.decode(res.bodyBytes);
    final data = body.isNotEmpty ? jsonDecode(body) : {};

    if (res.statusCode == 200) {
      return StoreConfigModel.fromJson(data);
    }

    throw Exception(data["message"] ?? "Không lấy được cấu hình cửa hàng");
  }
}
