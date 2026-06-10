import 'package:flutter/material.dart';

import '../models/billing_record_model.dart';
import '../services/billing_record_service.dart';

class BillingRecordProvider extends ChangeNotifier {
  BillingRecordService service;

  BillingRecordProvider(this.service);

  List<BillingRecordModel> records = [];

  BillingRecordModel? selectedRecord;

  bool isLoading = false;

  String? error;

  int? currentPeriodId;

  // =========================
  // LIST BY PERIOD
  // =========================
  Future<void> fetchRecordsByPeriod(int periodId) async {
    try {
      isLoading = true;
      error = null;
      currentPeriodId = periodId;
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
  // FILTER RECORDS
  // Đúng theo backend:
  // periodId, collectionStatus, debtStatus,
  // assignedUserId, billPrintedDate, search
  // =========================
  Future<void> filterRecords({
    int? periodId,
    String? search,
    String? collectionStatus,
    String? debtStatus,
    int? assignedUserId,
    String? billPrintedDate,
    bool useCurrentPeriod = true,
  }) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final targetPeriodId = useCurrentPeriod
          ? (periodId ?? currentPeriodId)
          : periodId;

      records = await service.getRecords(
        periodId: targetPeriodId,
        page: 0,
        size: 100,
        search: search,
        collectionStatus: collectionStatus,
        debtStatus: debtStatus,
        assignedUserId: assignedUserId,
        billPrintedDate: billPrintedDate,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // RESET FILTER
  // =========================
  Future<void> resetFilter() async {
    if (currentPeriodId == null) return;
    await fetchRecordsByPeriod(currentPeriodId!);
  }

  // =========================
  // GET DETAIL
  // =========================
  Future<void> fetchRecordDetail(int recordId) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      selectedRecord = await service.getRecordDetail(recordId);
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

      if (current.collectionStatus != "CHUA_THU") {
        selectedRecord = current;
        return;
      }

      await service.printBill(
        recordId: recordId,
        collectedAmount: current.amountDue,
      );

      selectedRecord = await service.getRecordDetail(recordId);

      final index = records.indexWhere((e) => e.id == recordId);
      if (index != -1 && selectedRecord != null) {
        records[index] = selectedRecord!;
      }
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
      error = null;

      await service.markDebt(recordId);

      final updatedRecord = await service.getRecordDetail(recordId);

      selectedRecord = updatedRecord;

      final index = records.indexWhere((e) => e.id == recordId);
      if (index != -1) {
        records[index] = updatedRecord;
      }

      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // =========================
  // FORCE REFRESH
  // =========================
  Future<void> refresh(int recordId) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      selectedRecord = await service.getRecordDetail(recordId);
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
