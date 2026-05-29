import 'package:flutter/material.dart';

import '../models/bill_data_model.dart';
import '../models/customer_model.dart';
import '../services/customer_service.dart';

class CustomerProvider extends ChangeNotifier {
  CustomerService service;

  CustomerProvider(this.service);

  List<CustomerModel> customers = [];

  List<CustomerModel> warnings = [];

  CustomerModel? selectedCustomer;

  BillDataModel? billData;

  bool loading = false;

  bool actionLoading = false;

  String? error;

  String search = "";

  String status = "";

  int? periodId;

  String province = "";
  String ward = "";
  String hamlet = "";
  String street = "";

  int page = 0;

  Future<void> fetchCustomers() async {
    try {
      loading = true;

      notifyListeners();

      customers = await service.getCustomers(
        search: search,
        status: status,
        periodId: periodId,
        province: province,
        ward: ward,
        hamlet: hamlet,
        street: street,
        page: page,
      );

      error = null;
    } catch (e) {
      error = e.toString();

      customers = [];
    } finally {
      loading = false;

      notifyListeners();
    }
  }

  Future<void> getDetail(int id) async {
    try {
      loading = true;

      notifyListeners();

      selectedCustomer = await service.getDetail(id);

      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;

      notifyListeners();
    }
  }

  Future<void> getBillData(int id) async {
    try {
      loading = true;

      notifyListeners();

      billData = await service.getBillData(id);

      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;

      notifyListeners();
    }
  }

  Future<void> printBill({required int id, required double amount}) async {
    try {
      actionLoading = true;

      notifyListeners();

      await service.printBill(id: id, collectedAmount: amount);

      await fetchCustomers();
    } finally {
      actionLoading = false;

      notifyListeners();
    }
  }

  Future<void> markDebt(int id) async {
    try {
      actionLoading = true;

      notifyListeners();

      await service.markDebt(id);

      await fetchCustomers();
    } finally {
      actionLoading = false;

      notifyListeners();
    }
  }

  Future<bool> createCustomer({
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
    try {
      error = null;

      notifyListeners();

      await service.createCustomer(
        billingPeriodId: billingPeriodId,
        customerCode: customerCode,
        customerName: customerName,
        subscriberNumber: subscriberNumber,
        phoneNumber: phoneNumber,
        amountDue: amountDue,
        province: province,
        ward: ward,
        hamlet: hamlet,
        street: street,
        fullAddress: fullAddress,
        serviceType: serviceType,
        assignedConsultantUsername: assignedConsultantUsername,
      );

      await fetchCustomers();

      return true;
    } catch (e) {
      error = e.toString();

      notifyListeners();

      return false;
    }
  }

  Future<void> fetchWarnings(int periodId) async {
    try {
      loading = true;

      notifyListeners();

      warnings = await service.getWarnings(periodId: periodId);
    } finally {
      loading = false;

      notifyListeners();
    }
  }

  void setSearch(String value) {
    search = value;
    fetchCustomers();
  }

  void setStatus(String value) {
    status = value;
    fetchCustomers();
  }

  void setPeriod(int? value) {
    periodId = value;
    fetchCustomers();
  }

  void clearFilters() {
    search = "";
    status = "";
    province = "";
    ward = "";
    hamlet = "";
    street = "";
    periodId = null;

    fetchCustomers();
  }
}
