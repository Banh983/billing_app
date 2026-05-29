import 'package:flutter/material.dart';

import '../models/billing_record.dart';

import '../services/billing_record_service.dart';

class BillingRecordProvider extends ChangeNotifier {
  BillingRecordService service;

  BillingRecordProvider(this.service);

  List<BillingRecord> records = [];

  bool isLoading = false;

  String? error;

  /// =========================
  /// FETCH RECORDS BY PERIOD
  /// =========================
  Future<void> fetchRecordsByPeriod(int periodId) async {
    try {
      isLoading = true;

      error = null;

      notifyListeners();

      records = await service.getRecordsByPeriod(periodId);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;

      notifyListeners();
    }
  }
}
