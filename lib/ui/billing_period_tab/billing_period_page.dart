import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/billing_period_provider.dart';
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
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<BillingPeriodProvider>().fetchBillingPeriods();
    });
  }

  Future<void> _closePeriod(
    BuildContext context,
    BillingPeriodProvider provider,
    int periodId,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Đóng kỳ cước"),
        content: const Text(
          "Bạn có chắc muốn đóng kỳ cước này?\n\nSau khi đóng sẽ không thể tiếp tục thu cước.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Đóng kỳ"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await provider.closePeriod(periodId);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Đóng kỳ cước thành công")));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        title: const Text(
          "Kỳ cước",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: Column(
        children: [
          const BillingFilterCard(type: BillingFilterType.period),

          Expanded(
            child: Consumer<BillingPeriodProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(child: Text(provider.error!));
                }

                if (provider.periods.isEmpty) {
                  return const BillingEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: provider.refresh,

                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),

                    itemCount: provider.periods.length,

                    itemBuilder: (context, index) {
                      final period = provider.periods[index];

                      return BillingPeriodCard(
                        billingPeriod: period,

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
