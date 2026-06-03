import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/customer_record_model.dart';

class CustomerRecordService {
  final String baseUrl;

  final String token;

  CustomerRecordService({required this.baseUrl, required this.token});

  Map<String, String> get headers => {
    "Content-Type": "application/json",
    "Authorization": "Bearer $token",
  };

  Future<List<CustomerRecordModel>> getRecords({
    int? periodId,
    String? status,
    String? ward,
    String? search,
    int page = 0,
    int size = 20,
  }) async {
    final query = <String, String>{};

    if (periodId != null) {
      query["periodId"] = periodId.toString();
    }

    if (status != null && status.isNotEmpty) {
      query["status"] = status;
    }

    if (ward != null && ward.isNotEmpty) {
      query["ward"] = ward;
    }

    if (search != null && search.isNotEmpty) {
      query["search"] = search;
    }

    query["page"] = "$page";

    query["size"] = "$size";

    final uri = Uri.parse("$baseUrl/records").replace(queryParameters: query);

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      final List content = json["content"] ?? [];

      return content.map((e) => CustomerRecordModel.fromJson(e)).toList();
    }

    throw Exception("Không thể tải danh sách khách hàng");
  }
}
