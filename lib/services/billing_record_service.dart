import 'dart:convert';
import 'package:flutter/material.dart';
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

  Future<Map<String, dynamic>> getRecordsByPeriod(
    int periodId, {
    int page = 0,
    int size = 20,
  }) async {
    return getRecordsPage(periodId: periodId, page: page, size: size);
  }

  Future<Map<String, dynamic>> getRecordsPage({
    int page = 0,
    int size = 20,
    int? periodId,
    String? search,
    String? collectionStatus,
    String? debtStatus,
    int? assignedUserId,
    String? billPrintedDate,
  }) async {
    final queryParams = <String, String>{
      "page": page.toString(),
      "size": size.toString(),

      if (periodId != null) "periodId": periodId.toString(),

      if (_hasValue(collectionStatus))
        "collectionStatus": collectionStatus!.trim(),

      if (_hasValue(debtStatus)) "debtStatus": debtStatus!.trim(),

      if (assignedUserId != null) "assignedUserId": assignedUserId.toString(),

      if (_hasValue(billPrintedDate))
        "billPrintedDate": billPrintedDate!.trim(),

      if (_hasValue(search)) "search": search!.trim(),
    };

    final uri = Uri.parse(
      "$baseUrl/records",
    ).replace(queryParameters: queryParams);

    debugPrint("GET RECORDS: $uri");

    final response = await http.get(uri, headers: headers);

    final bodyText = utf8.decode(response.bodyBytes);
    final body = bodyText.isNotEmpty ? jsonDecode(bodyText) : {};

    if (response.statusCode != 200) {
      throw Exception(body["message"] ?? "Không thể tải danh sách khách hàng");
    }

    final pageBody = _extractPageBody(body);
    final List<dynamic> content = _extractList(body);

    final records = content.map((e) => BillingRecordModel.fromJson(e)).toList();

    return {
      "records": records,
      "currentPage": _toInt(pageBody["number"], fallback: page),
      "totalPages": _toInt(pageBody["totalPages"], fallback: 1),
      "totalElements": _toInt(
        pageBody["totalElements"],
        fallback: records.length,
      ),
      "pageSize": _toInt(pageBody["size"], fallback: size),
    };
  }

  Future<List<BillingRecordModel>> getRecords({
    int page = 0,
    int size = 20,
    int? periodId,
    String? search,
    String? collectionStatus,
    String? debtStatus,
    int? assignedUserId,
    String? billPrintedDate,
  }) async {
    final result = await getRecordsPage(
      page: page,
      size: size,
      periodId: periodId,
      search: search,
      collectionStatus: collectionStatus,
      debtStatus: debtStatus,
      assignedUserId: assignedUserId,
      billPrintedDate: billPrintedDate,
    );

    return List<BillingRecordModel>.from(result["records"] ?? []);
  }

  Future<BillingRecordModel> getRecordDetail(int id) async {
    final response = await http.get(
      Uri.parse("$baseUrl/records/$id"),
      headers: headers,
    );

    final bodyText = utf8.decode(response.bodyBytes);
    final body = bodyText.isNotEmpty ? jsonDecode(bodyText) : {};

    if (response.statusCode != 200) {
      throw Exception(body["message"] ?? "Không thể lấy chi tiết khách hàng");
    }

    return BillingRecordModel.fromJson(body["data"] ?? body);
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
      final bodyText = utf8.decode(response.bodyBytes);
      final body = bodyText.isNotEmpty ? jsonDecode(bodyText) : {};
      throw Exception(body["message"] ?? "Không thể in bill");
    }
  }

  Future<void> markDebt(int recordId) async {
    final response = await http.patch(
      Uri.parse("$baseUrl/records/$recordId/mark-debt"),
      headers: headers,
    );

    if (response.statusCode != 200) {
      final bodyText = utf8.decode(response.bodyBytes);
      final body = bodyText.isNotEmpty ? jsonDecode(bodyText) : {};
      throw Exception(body["message"] ?? "Không thể gạch nợ");
    }
  }

  bool _hasValue(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  Map<String, dynamic> _extractPageBody(dynamic body) {
    if (body is Map<String, dynamic>) {
      final data = body["data"];

      if (data is Map<String, dynamic> && data["content"] is List) {
        return data;
      }

      if (body["content"] is List) {
        return body;
      }
    }

    return {};
  }

  List<dynamic> _extractList(dynamic body) {
    if (body is Map<String, dynamic>) {
      final data = body["data"];

      if (data is Map<String, dynamic> && data["content"] is List) {
        return data["content"];
      }

      if (data is List) {
        return data;
      }

      if (body["content"] is List) {
        return body["content"];
      }
    }

    return [];
  }

  int _toInt(dynamic value, {required int fallback}) {
    if (value is int) return value;

    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? "") ?? fallback;
  }
}
