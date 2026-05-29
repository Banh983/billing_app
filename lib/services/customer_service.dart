import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/bill_data_model.dart';
import '../models/customer_model.dart';

class CustomerService {
  final String baseUrl;
  final String token;

  CustomerService({required this.baseUrl, required this.token});

  Map<String, String> get headers => {
    "Content-Type": "application/json",
    "Authorization": "Bearer $token",
  };

  Future<List<CustomerModel>> getCustomers({
    String? search,
    String? status,
    int? periodId,
    String? province,
    String? ward,
    String? hamlet,
    String? street,
    int page = 0,
    int size = 20,
  }) async {
    final query = <String>["page=$page", "size=$size"];

    if (search != null && search.isNotEmpty) {
      query.add("search=$search");
    }

    if (status != null && status.isNotEmpty) {
      query.add("status=$status");
    }

    if (periodId != null) {
      query.add("periodId=$periodId");
    }

    if (province != null && province.isNotEmpty) {
      query.add("province=$province");
    }

    if (ward != null && ward.isNotEmpty) {
      query.add("ward=$ward");
    }

    if (hamlet != null && hamlet.isNotEmpty) {
      query.add("hamlet=$hamlet");
    }

    if (street != null && street.isNotEmpty) {
      query.add("street=$street");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/records?${query.join("&")}"),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final json = jsonDecode(response.body);

    final List content = (json["content"] ?? []) as List;

    return content.map((e) => CustomerModel.fromJson(e)).toList();
  }

  Future<CustomerModel> getDetail(int id) async {
    final response = await http.get(
      Uri.parse("$baseUrl/records/$id"),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    return CustomerModel.fromJson(jsonDecode(response.body));
  }

  Future<BillDataModel> getBillData(int id) async {
    final response = await http.get(
      Uri.parse("$baseUrl/records/$id/bill-data"),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    return BillDataModel.fromJson(jsonDecode(response.body));
  }

  Future<void> printBill({
    required int id,
    required double collectedAmount,
  }) async {
    final response = await http.patch(
      Uri.parse("$baseUrl/records/$id/print-bill"),
      headers: headers,
      body: jsonEncode({"collectedAmount": collectedAmount}),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }

  Future<void> markDebt(int id) async {
    final response = await http.patch(
      Uri.parse("$baseUrl/records/$id/mark-debt"),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }

  Future<List<CustomerModel>> getWarnings({
    required int periodId,
    int page = 0,
    int size = 20,
  }) async {
    final response = await http.get(
      Uri.parse(
        "$baseUrl/records/warnings"
        "?periodId=$periodId"
        "&page=$page"
        "&size=$size",
      ),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final json = jsonDecode(response.body);

    final List content = (json["content"] ?? []) as List;

    return content.map((e) => CustomerModel.fromJson(e)).toList();
  }

  Future<void> createCustomer({
    required int billingPeriodId,
    required String customerCode,
    required String customerName,
    String subscriberNumber = "",
    String phoneNumber = "",
    required double amountDue,
    String province = "",
    String ward = "",
    String hamlet = "",
    String street = "",
    String fullAddress = "",
    String serviceType = "",
    String assignedConsultantUsername = "",
  }) async {
    final uri = Uri.parse('$baseUrl/records');

    final body = {
      "billingPeriodId": billingPeriodId,
      "customerCode": customerCode,
      "customerName": customerName,
      "subscriberNumber": subscriberNumber,
      "phoneNumber": phoneNumber,
      "amountDue": amountDue,
      "province": province,
      "ward": ward,
      "hamlet": hamlet,
      "street": street,
      "fullAddress": fullAddress,
      "serviceType": serviceType,
      "assignedConsultantUsername": assignedConsultantUsername,
    };

    debugPrint("========== CREATE CUSTOMER ==========");
    debugPrint("URL: $uri");
    debugPrint("BODY: ${jsonEncode(body)}");
    debugPrint("HEADERS: $headers");

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    debugPrint("STATUS CODE: ${response.statusCode}");
    debugPrint("RESPONSE: ${response.body}");

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(response.body);
    }
  }
}
