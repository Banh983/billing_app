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

  int currentPage = 0;

  int totalPages = 1;

  int totalElements = 0;

  int pageSize = 20;

  String? currentSearch;

  String? currentCollectionStatus;

  String? currentDebtStatus;

  int? currentAssignedUserId;

  String? currentBillPrintedDate;

  bool get hasPreviousPage => currentPage > 0;

  bool get hasNextPage => currentPage < totalPages - 1;

  Future<void> fetchRecordsByPeriod(
    int periodId, {
    int page = 0,
    int size = 20,
  }) async {
    currentSearch = null;
    currentCollectionStatus = null;
    currentDebtStatus = null;
    currentAssignedUserId = null;
    currentBillPrintedDate = null;

    currentPeriodId = periodId;

    await _loadRecords(periodId: periodId, page: page, size: size);
  }

  Future<void> filterRecords({
    int? periodId,
    String? search,
    String? collectionStatus,
    String? debtStatus,
    int? assignedUserId,
    String? billPrintedDate,
    bool useCurrentPeriod = true,
    int page = 0,
    int size = 20,
  }) async {
    final targetPeriodId = useCurrentPeriod
        ? (periodId ?? currentPeriodId)
        : periodId;

    currentPeriodId = targetPeriodId;
    currentSearch = search;
    currentCollectionStatus = collectionStatus;
    currentDebtStatus = debtStatus;
    currentAssignedUserId = assignedUserId;
    currentBillPrintedDate = billPrintedDate;

    await _loadRecords(
      periodId: targetPeriodId,
      page: page,
      size: size,
      search: search,
      collectionStatus: collectionStatus,
      debtStatus: debtStatus,
      assignedUserId: assignedUserId,
      billPrintedDate: billPrintedDate,
    );
  }

  Future<void> goToPage(int page) async {
    if (currentPeriodId == null) return;

    final safePage = page.clamp(0, totalPages - 1);

    await _loadRecords(
      periodId: currentPeriodId,
      page: safePage,
      size: pageSize,
      search: currentSearch,
      collectionStatus: currentCollectionStatus,
      debtStatus: currentDebtStatus,
      assignedUserId: currentAssignedUserId,
      billPrintedDate: currentBillPrintedDate,
    );
  }

  Future<void> nextPage() async {
    if (!hasNextPage) return;

    await goToPage(currentPage + 1);
  }

  Future<void> previousPage() async {
    if (!hasPreviousPage) return;

    await goToPage(currentPage - 1);
  }

  Future<void> refreshCurrentList() async {
    await goToPage(currentPage);
  }

  Future<void> resetFilter() async {
    if (currentPeriodId == null) return;

    await fetchRecordsByPeriod(currentPeriodId!, page: 0, size: pageSize);
  }

  Future<void> _loadRecords({
    int? periodId,
    int page = 0,
    int size = 20,
    String? search,
    String? collectionStatus,
    String? debtStatus,
    int? assignedUserId,
    String? billPrintedDate,
  }) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final result = await service.getRecordsPage(
        periodId: periodId,
        page: page,
        size: size,
        search: search,
        collectionStatus: collectionStatus,
        debtStatus: debtStatus,
        assignedUserId: assignedUserId,
        billPrintedDate: billPrintedDate,
      );

      records = List<BillingRecordModel>.from(result["records"] ?? []);

      currentPage = result["currentPage"] ?? page;
      totalPages = result["totalPages"] ?? 1;
      totalElements = result["totalElements"] ?? records.length;
      pageSize = result["pageSize"] ?? size;

      if (totalPages <= 0) {
        totalPages = 1;
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

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
