import 'package:billing_app/provider/billing_record_provider.dart';
import 'package:billing_app/ui/billing_period_tab/components/record_action_buttons.dart';
import 'package:billing_app/ui/billing_period_tab/components/record_customer_section.dart';
import 'package:billing_app/ui/billing_period_tab/components/record_invoice_section.dart';
import 'package:billing_app/ui/billing_period_tab/components/record_paid_notice.dart';
import 'package:billing_app/ui/billing_period_tab/components/record_printer_section.dart';
import 'package:billing_app/ui/billing_period_tab/controllers/billing_record_print_controller.dart';
import 'package:billing_app/ui/dialog/confirm_action_dialog.dart';
import 'package:billing_app/ui/helpers/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';

class BillingRecordDetailPage extends StatefulWidget {
  final int recordId;

  const BillingRecordDetailPage({super.key, required this.recordId});

  @override
  State<BillingRecordDetailPage> createState() =>
      _BillingRecordDetailPageState();
}

class _BillingRecordDetailPageState extends State<BillingRecordDetailPage>
    with WidgetsBindingObserver {
  late final BillingRecordPrintController _printController;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _printController = BillingRecordPrintController();

    Future.microtask(() {
      context.read<BillingRecordProvider>().fetchRecordDetail(widget.recordId);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _printController.dispose();
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state != AppLifecycleState.resumed) return;

    await _printController.handleAppResumed(context);
  }

  Future<void> _markDebt(BillingRecordProvider provider) async {
    final record = provider.selectedRecord;

    if (record == null) return;

    try {
      await provider.markDebt(record.id);

      if (!mounted) return;

      ToastUtils.success(
        context,
        message: "Đã gạch nợ khách hàng ${record.customerName}",
      );
    } catch (e) {
      if (!mounted) return;

      ToastUtils.fromException(context, e);
    }
  }

  void _showConfirmMarkDebtDialog(BillingRecordProvider provider) {
    final record = provider.selectedRecord;

    if (record == null) return;

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
              text: record.customerName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: " không?"),
          ],
        ),
        onConfirm: () async {
          await _markDebt(provider);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _printController,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.primaryRed,
            foregroundColor: Colors.white,
            title: const Text("Chi tiết hóa đơn"),
          ),
          body: Consumer<BillingRecordProvider>(
            builder: (context, provider, child) {
              final record = provider.selectedRecord;

              if (record == null) {
                return const Center(child: CircularProgressIndicator());
              }

              final bool isUnpaid = record.collectionStatus == "CHUA_THU";

              final bool canMarkDebt =
                  record.collectionStatus == "DA_THANH_TOAN" &&
                  record.debtStatus == "CHUA_GACH_NO";

              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  children: [
                    RecordCustomerSection(record: record),

                    RecordInvoiceSection(record: record),

                    RecordPrinterSection(
                      selectedPrinter: _printController.selectedPrinter,
                      paperSize: _printController.paperSize,
                      onSelectPrinter: () async {
                        await _printController.selectPrinter(context);
                      },
                      onSelectPaperSize: () async {
                        await _printController.selectPaperSize(context);
                      },
                    ),

                    const SizedBox(height: 16),

                    RecordActionButtons(
                      isUnpaid: isUnpaid,
                      canMarkDebt: canMarkDebt,
                      isPrinting: _printController.isPrinting,
                      isOpeningPreview: _printController.isOpeningPreview,
                      onOpenPreview: () async {
                        await _printController.openPreview(
                          context: context,
                          provider: provider,
                          recordId: widget.recordId,
                        );
                      },
                      onMarkDebt: () {
                        _showConfirmMarkDebtDialog(provider);
                      },
                    ),

                    if (!isUnpaid) const RecordPaidNotice(),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
