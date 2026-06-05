import 'package:billing_app/ui/billing_period_tab/billing_record_detail_page.dart';
import 'package:billing_app/ui/dialog/confirm_action_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/billing_period_model.dart';
import '../../provider/billing_record_provider.dart';
import '../helpers/toast_utils.dart';

import 'components/billing_filter_card.dart';
import 'components/billing_record_card.dart';

class BillingPeriodDetailPage extends StatefulWidget {
  final BillingPeriodModel period;

  const BillingPeriodDetailPage({super.key, required this.period});

  @override
  State<BillingPeriodDetailPage> createState() =>
      _BillingPeriodDetailPageState();
}

class _BillingPeriodDetailPageState extends State<BillingPeriodDetailPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<BillingRecordProvider>().fetchRecordsByPeriod(
        widget.period.id,
      );
    });
  }

  Future<void> _refreshRecords() async {
    await context.read<BillingRecordProvider>().fetchRecordsByPeriod(
      widget.period.id,
    );
  }

  Future<void> _markDebt(int recordId, String customerName) async {
    try {
      await context.read<BillingRecordProvider>().markDebt(recordId);

      if (!mounted) return;

      ToastUtils.success(
        context,
        message: "Đã gạch nợ khách hàng $customerName",
      );
    } catch (e) {
      if (!mounted) return;

      ToastUtils.fromException(context, e);
    }
  }

  void _showConfirmMarkDebtDialog({
    required int recordId,
    required String customerName,
  }) {
    showDialog(
      context: context,
      builder: (_) => ConfirmActionDialog(
        title: "Xác nhận gạch nợ",
        message: "",
        confirmText: "Gạch nợ",
        cancelText: "Hủy",
        icon: Icons.account_balance_wallet_outlined,
        iconColor: Colors.red,
        confirmColor: Colors.red,
        richMessage: TextSpan(
          children: [
            const TextSpan(text: "Bạn có chắc muốn gạch nợ khách hàng "),
            TextSpan(
              text: customerName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: " không?"),
          ],
        ),
        onConfirm: () async {
          await _markDebt(recordId, customerName);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        title: Text(
          widget.period.displayName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          BillingFilterCard(
            type: BillingFilterType.record,
            periodId: widget.period.id,
          ),
          Expanded(
            child: Consumer<BillingRecordProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.records.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null && provider.records.isEmpty) {
                  return Center(child: Text(provider.error!));
                }

                if (provider.records.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _refreshRecords,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 160),
                        Center(child: Text("Không tìm thấy hóa đơn phù hợp")),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refreshRecords,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: provider.records.length,
                    itemBuilder: (context, index) {
                      final record = provider.records[index];

                      return BillingRecordCard(
                        record: record,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  BillingRecordDetailPage(recordId: record.id),
                            ),
                          );
                        },
                        onMarkDebt: () async {
                          _showConfirmMarkDebtDialog(
                            recordId: record.id,
                            customerName: record.customerName,
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
