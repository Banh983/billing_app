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
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<BillingRecordProvider>().fetchRecordsByPeriod(
        widget.period.id,
        page: 0,
        size: _pageSize,
      );
    });
  }

  Future<void> _refreshRecords() async {
    await context.read<BillingRecordProvider>().refreshCurrentList();
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

  Widget _buildPagination(BillingRecordProvider provider) {
    if (provider.totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: provider.hasPreviousPage && !provider.isLoading
                  ? provider.previousPage
                  : null,
              icon: const Icon(Icons.chevron_left),
            ),

            ..._buildPages(provider),

            IconButton(
              onPressed: provider.hasNextPage && !provider.isLoading
                  ? provider.nextPage
                  : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPages(BillingRecordProvider provider) {
    final current = provider.currentPage + 1;
    final total = provider.totalPages;

    final widgets = <Widget>[];

    for (int page = 1; page <= total; page++) {
      if (page == 1 ||
          page == total ||
          (page >= current - 1 && page <= current + 1)) {
        widgets.add(_pageButton(provider, page));
      } else if (page == current - 2 || page == current + 2) {
        widgets.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text("..."),
          ),
        );
      }
    }

    return widgets;
  }

  Widget _pageButton(BillingRecordProvider provider, int page) {
    final selected = page == provider.currentPage + 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: provider.isLoading
            ? null
            : () {
                provider.goToPage(page - 1);
              },
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE53935) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            page.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: selected ? Colors.white : Colors.black87,
            ),
          ),
        ),
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
      body: Consumer<BillingRecordProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.records.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.records.isEmpty) {
            return Center(child: Text(provider.error!));
          }

          return RefreshIndicator(
            onRefresh: _refreshRecords,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: BillingFilterCard(
                    type: BillingFilterType.record,
                    periodId: widget.period.id,
                  ),
                ),

                if (provider.isLoading && provider.records.isNotEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),

                if (provider.records.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text("Không tìm thấy hóa đơn phù hợp"),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final record = provider.records[index];

                        return BillingRecordCard(
                          record: record,
                          periodStatus: widget.period.status,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BillingRecordDetailPage(
                                  recordId: record.id,
                                  periodStatus: widget.period.status,
                                ),
                              ),
                            );

                            if (!mounted) return;

                            await _refreshRecords();
                          },
                          onMarkDebt: () async {
                            _showConfirmMarkDebtDialog(
                              recordId: record.id,
                              customerName: record.customerName,
                            );
                          },
                        );
                      }, childCount: provider.records.length),
                    ),
                  ),

                SliverToBoxAdapter(child: _buildPagination(provider)),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            ),
          );
        },
      ),
    );
  }
}
