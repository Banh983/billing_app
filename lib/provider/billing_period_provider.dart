import 'package:flutter/material.dart';

import '../models/billing_period_model.dart';
import '../services/billing_period_service.dart';

class BillingPeriodProvider extends ChangeNotifier {
  BillingPeriodService service;

  BillingPeriodProvider(this.service);

  bool isLoading = false;

  String? error;

  List<BillingPeriodModel> periods = [];

  Future<void> fetchBillingPeriods() async {
    try {
      isLoading = true;

      error = null;

      notifyListeners();

      periods = await service.getBillingPeriods();
    } catch (e) {
      error = e.toString();

      debugPrint(error);
    } finally {
      isLoading = false;

      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await fetchBillingPeriods();
  }

  void clearError() {
    error = null;

    notifyListeners();
  }

  Future<void> closePeriod(int id) async {
    try {
      await service.closePeriod(id);

      await fetchBillingPeriods();
    } catch (e) {
      rethrow;
    }
  }
}
