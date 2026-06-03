import 'package:billing_app/ui/billing_period_tab/billing_record_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/billing_period_model.dart';
import '../../provider/billing_record_provider.dart';

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
          /// FILTER
          const BillingFilterCard(type: BillingFilterType.record),

          /// LIST RECORDS
          Expanded(
            child: Consumer<BillingRecordProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(child: Text(provider.error!));
                }

                if (provider.records.isEmpty) {
                  return const Center(
                    child: Text("Chưa có hóa đơn trong kỳ này"),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      provider.fetchRecordsByPeriod(widget.period.id),

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
