import 'dart:io';

import 'package:flutter/material.dart';

import '../models/billing_period.dart';
import '../services/billing_period_service.dart';

class BillingPeriodProvider extends ChangeNotifier {
  BillingPeriodService service;

  BillingPeriodProvider(this.service);

  List<BillingPeriod> periods = [];

  BillingPeriod? selectedPeriod;

  bool isLoading = false;

  String? error;

  /// =========================
  /// GET ALL
  /// =========================
  Future<void> fetchBillingPeriods() async {
    try {
      isLoading = true;
      error = null;

      notifyListeners();

      periods = await service.getBillingPeriods();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// =========================
  /// GET DETAIL
  /// =========================
  Future<void> fetchBillingPeriodDetail(int id) async {
    try {
      isLoading = true;

      notifyListeners();

      selectedPeriod = await service.getBillingPeriodById(id);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// =========================
  /// CLOSE PERIOD
  /// =========================
  Future<String> closePeriod(int id) async {
    final message = await service.closeBillingPeriod(id);

    await fetchBillingPeriods();

    return message;
  }

  /// =========================
  /// IMPORT
  /// =========================
  Future<String> importExcel(File file) async {
    final message = await service.importExcel(file);

    await fetchBillingPeriods();

    return message;
  }

  /// =========================
  /// DOWNLOAD TEMPLATE
  /// =========================
  Future<String> downloadTemplate() async {
    return await service.downloadTemplate();
  }
}
