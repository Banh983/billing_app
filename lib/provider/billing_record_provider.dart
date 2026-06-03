import 'package:flutter/material.dart';

import '../models/billing_record_model.dart';
import '../services/billing_record_service.dart';

class BillingRecordProvider extends ChangeNotifier {
  final BillingRecordService service;

  BillingRecordProvider(this.service);

  List<BillingRecordModel> records = [];

  BillingRecordModel? selectedRecord;

  bool isLoading = false;

  String? error;

  // =========================
  // LIST BY PERIOD
  // =========================
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

  // =========================
  // GET DETAIL
  // =========================
  Future<void> fetchRecordDetail(int recordId) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final data = await service.getRecordDetail(recordId);

      selectedRecord = null;
      notifyListeners();

      selectedRecord = data;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // PRINT BILL
  // LUÔN THU ĐÚNG amountDue
  // =========================
  Future<void> printBill({required int recordId}) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final current = await service.getRecordDetail(recordId);

      await service.printBill(
        recordId: recordId,
        collectedAmount: current.amountDue,
      );

      final updated = await service.getRecordDetail(recordId);

      selectedRecord = updated;
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // MARK DEBT
  // =========================
  Future<void> markDebt(int recordId) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await service.markDebt(recordId);

      selectedRecord = await service.getRecordDetail(recordId);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // FORCE REFRESH
  // =========================
  Future<void> refresh(int recordId) async {
    try {
      isLoading = true;
      notifyListeners();

      selectedRecord = await service.getRecordDetail(recordId);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
