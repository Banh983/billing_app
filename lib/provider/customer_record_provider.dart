import 'package:flutter/material.dart';

import '../models/customer_record_model.dart';
import '../services/customer_record_service.dart';

class CustomerRecordProvider extends ChangeNotifier {
  final CustomerRecordService service;

  CustomerRecordProvider(this.service);

  bool isLoading = false;

  List<CustomerRecordModel> records = [];

  Future<void> fetchRecords({
    int? periodId,
    String? status,
    String? ward,
    String? search,
  }) async {
    try {
      isLoading = true;

      notifyListeners();

      records = await service.getRecords(
        periodId: periodId,
        status: status,
        ward: ward,
        search: search,
      );
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading = false;

      notifyListeners();
    }
  }
}
