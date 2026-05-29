import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../models/billing_period.dart';

import '../../provider/billing_record_provider.dart';

import 'components/billing_record_card.dart';

class BillingPeriodDetailPage extends StatefulWidget {
  final BillingPeriod period;

  const BillingPeriodDetailPage({super.key, required this.period});

  @override
  State<BillingPeriodDetailPage> createState() =>
      _BillingPeriodDetailPageState();
}

class _BillingPeriodDetailPageState extends State<BillingPeriodDetailPage> {
  final searchController = TextEditingController();

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
        backgroundColor: Colors.white,

        foregroundColor: Colors.red,

        elevation: 0,

        title: Text(widget.period.name),
      ),

      body: Column(
        children: [
          /// HEADER
          Container(
            margin: const EdgeInsets.all(16),

            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(24),
            ),

            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: buildStat("Tổng hóa đơn", "523", Colors.blue),
                    ),

                    Expanded(child: buildStat("Đã thu", "312", Colors.green)),

                    Expanded(child: buildStat("Chưa thu", "211", Colors.red)),
                  ],
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: searchController,

                  decoration: InputDecoration(
                    hintText: "Tìm khách hàng...",

                    prefixIcon: const Icon(Icons.search),

                    filled: true,

                    fillColor: Colors.grey.shade100,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),

                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// LIST
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
                  return const Center(child: Text("Chưa có hóa đơn"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),

                  itemCount: provider.records.length,

                  itemBuilder: (context, index) {
                    final record = provider.records[index];

                    return BillingRecordCard(record: record, onTap: () {});
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStat(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          value,

          style: TextStyle(
            fontSize: 26,

            fontWeight: FontWeight.bold,

            color: color,
          ),
        ),

        const SizedBox(height: 4),

        Text(title, style: TextStyle(color: Colors.grey.shade700)),
      ],
    );
  }
}
