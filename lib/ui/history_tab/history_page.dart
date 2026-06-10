import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/billing_record_provider.dart';
import 'components/history_card.dart';
import 'components/history_filter_card.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String? search;
  String? billPrintedDate;
  String? debtStatus;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      _fetchHistory();
    });
  }

  Future<void> _fetchHistory() async {
    await context.read<BillingRecordProvider>().filterRecords(
      collectionStatus: "DA_THANH_TOAN",
      search: search,
      billPrintedDate: billPrintedDate,
      debtStatus: debtStatus,
    );
  }

  Future<void> _refresh() async {
    await _fetchHistory();
  }

  void _applyFilter({
    String? search,
    String? billPrintedDate,
    String? debtStatus,
  }) {
    this.search = search;
    this.billPrintedDate = billPrintedDate;
    this.debtStatus = debtStatus;

    _fetchHistory();
  }

  void _resetFilter() {
    search = null;
    billPrintedDate = null;
    debtStatus = null;

    _fetchHistory();
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
          "Lịch sử thu cước",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          HistoryFilterCard(onFilter: _applyFilter, onReset: _resetFilter),

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
                    onRefresh: _refresh,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: constraints.maxHeight,
                              child: const Center(
                                child: Text(
                                  "Chưa có lịch sử thu cước",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: provider.records.length,
                    itemBuilder: (context, index) {
                      final record = provider.records[index];

                      return HistoryCard(record: record);
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
