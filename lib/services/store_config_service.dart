import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/store_config_model.dart';

class StoreConfigService {
  final String baseUrl = "http://192.168.1.164:8080";

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
