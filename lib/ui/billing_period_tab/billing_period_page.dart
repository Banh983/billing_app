import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/billing_period_provider.dart';

import 'billing_period_detail_page.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.red,

        title: const Text(
          "Kỳ cước",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: Consumer<BillingPeriodProvider>(
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
            onRefresh: provider.fetchBillingPeriods,

            child: ListView.builder(
              padding: const EdgeInsets.all(16),

              itemCount: provider.periods.length,

              itemBuilder: (context, index) {
                final period = provider.periods[index];

                return BillingPeriodCard(
                  billingPeriod: period,

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BillingPeriodDetailPage(period: period),
                      ),
                    );
                  },

                  onClose: () async {
                    final confirm = await showDialog<bool>(
                      context: context,

                      builder: (_) => AlertDialog(
                        title: const Text("Đóng kỳ cước?"),

                        content: Text(
                          "Sau khi đóng ${period.name}, hệ thống sẽ khóa import và chỉnh sửa dữ liệu.",
                        ),

                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, false);
                            },

                            child: const Text("Huỷ"),
                          ),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),

                            onPressed: () {
                              Navigator.pop(context, true);
                            },

                            child: const Text("Đóng kỳ"),
                          ),
                        ],
                      ),
                    );

                    if (confirm != true) return;

                    try {
                      final message = await provider.closePeriod(period.id);

                      if (context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(message)));
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
