import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/billing_period_model.dart';
import '../../provider/auth_provider.dart';
import '../../provider/billing_period_provider.dart';
import '../dialog/confirm_action_dialog.dart';
import 'billing_period_detail_page.dart';

import 'components/billing_filter_card.dart';
import 'components/billing_period_card.dart';
import 'components/empty_state.dart';

class BillingPeriodPage extends StatefulWidget {
  const BillingPeriodPage({super.key});

  @override
  State<BillingPeriodPage> createState() => _BillingPeriodPageState();
}

class _BillingPeriodPageState extends State<BillingPeriodPage> {
  String? selectedYear;

  String? selectedStatus;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<BillingPeriodProvider>().fetchBillingPeriods();
    });
  }

  List<BillingPeriodModel> _filterPeriods(List<BillingPeriodModel> periods) {
    return periods.where((period) {
      final matchYear =
          selectedYear == null || period.year.toString() == selectedYear;

      final matchStatus =
          selectedStatus == null || period.status == selectedStatus;

      return matchYear && matchStatus;
    }).toList();
  }

  Future<void> _closePeriod(
    BuildContext context,
    BillingPeriodProvider provider,
    int periodId,
  ) async {
    showDialog(
      context: context,
      builder: (_) => ConfirmActionDialog(
        title: "Đóng kỳ cước",
        message:
            "Bạn có chắc muốn đóng kỳ cước này?\n\nSau khi đóng sẽ không thể tiếp tục thu cước.",
        cancelText: "Hủy",
        confirmText: "Đóng kỳ",
        confirmColor: Colors.red,
        icon: Icons.lock_outline,
        iconColor: Colors.red,
        onConfirm: () async {
          try {
            await provider.closePeriod(periodId);

            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Đóng kỳ cước thành công")),
            );
          } catch (e) {
            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString()),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  bool _canManagePeriod(String? role) {
    final normalizedRole = role?.trim().toUpperCase() ?? "";

    return normalizedRole == "ADMIN" || normalizedRole == "MANAGER";
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    final canManagePeriod = _canManagePeriod(auth.user?.role);

    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        title: const Text(
          "Danh sách kỳ cước",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          BillingFilterCard(
            type: BillingFilterType.period,
            onPeriodFilter: ({year, status}) {
              setState(() {
                selectedYear = year;
                selectedStatus = status;
              });
            },
            onPeriodReset: () {
              setState(() {
                selectedYear = null;
                selectedStatus = null;
              });
            },
          ),

          Expanded(
            child: Consumer<BillingPeriodProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(child: Text(provider.error!));
                }

                final filteredPeriods = _filterPeriods(provider.periods);

                if (filteredPeriods.isEmpty) {
                  return const BillingEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: provider.refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredPeriods.length,
                    itemBuilder: (context, index) {
                      final period = filteredPeriods[index];

                      return BillingPeriodCard(
                        billingPeriod: period,
                        canManagePeriod: canManagePeriod,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  BillingPeriodDetailPage(period: period),
                            ),
                          );
                        },
                        onClose: () {
                          _closePeriod(context, provider, period.id);
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
