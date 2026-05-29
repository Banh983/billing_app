import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../models/billing_period.dart';

class BillingPeriodService {
  final String baseUrl;
  final String token;

  BillingPeriodService({required this.baseUrl, required this.token});

  Map<String, String> get headers => {"Authorization": "Bearer $token"};

  /// =========================
  /// GET ALL
  /// =========================
  Future<List<BillingPeriod>> getBillingPeriods() async {
    final response = await http.get(
      Uri.parse("$baseUrl/billing-periods"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      final List data = body["data"]["content"] ?? [];

      return data.map((e) => BillingPeriod.fromJson(e)).toList();
    }

    throw Exception("Không tải được kỳ cước");
  }

  /// =========================
  /// GET DETAIL
  /// =========================
  Future<BillingPeriod> getBillingPeriodById(int id) async {
    final response = await http.get(
      Uri.parse("$baseUrl/billing-periods/$id"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      return BillingPeriod.fromJson(body["data"]);
    }

    if (response.statusCode == 404) {
      throw Exception("Không tìm thấy kỳ cước");
    }

    throw Exception("Lỗi tải chi tiết");
  }

  /// =========================
  /// CLOSE PERIOD
  /// =========================
  Future<String> closeBillingPeriod(int id) async {
    final response = await http.patch(
      Uri.parse("$baseUrl/billing-periods/$id/close"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return "Đóng kỳ thành công";
    }

    if (response.statusCode == 400) {
      throw Exception("Kỳ này đã được đóng");
    }

    if (response.statusCode == 403) {
      throw Exception("Bạn không có quyền");
    }

    throw Exception("Không thể đóng kỳ");
  }

  /// =========================
  /// IMPORT EXCEL
  /// =========================
  Future<String> importExcel(File file) async {
    final request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/billing-periods/import"),
    );

    request.headers["Authorization"] = "Bearer $token";

    request.files.add(await http.MultipartFile.fromPath("file", file.path));

    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return "Import thành công";
    }

    if (response.statusCode == 400) {
      throw Exception("File không hợp lệ");
    }

    if (response.statusCode == 403) {
      throw Exception("Bạn không có quyền import");
    }

    throw Exception("Import thất bại");
  }

  /// =========================
  /// DOWNLOAD TEMPLATE
  /// =========================
  Future<String> downloadTemplate() async {
    final dio = Dio();

    final dir = await getApplicationDocumentsDirectory();

    final path = "${dir.path}/billing_template.xlsx";

    await dio.download(
      "$baseUrl/billing-periods/import/template",
      path,
      options: Options(headers: headers),
    );

    return path;
  }
}
