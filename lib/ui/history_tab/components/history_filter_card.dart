import 'package:billing_app/ui/history_tab/components/history_filter_action_buttons.dart';
import 'package:billing_app/ui/history_tab/components/history_filter_form.dart';
import 'package:billing_app/ui/history_tab/components/history_filter_header.dart';
import 'package:flutter/material.dart';

class HistoryFilterCard extends StatefulWidget {
  final void Function({
    String? search,
    String? billPrintedDate,
    String? debtStatus,
  })
  onFilter;

  final VoidCallback onReset;

  const HistoryFilterCard({
    super.key,
    required this.onFilter,
    required this.onReset,
  });

  @override
  State<HistoryFilterCard> createState() => _HistoryFilterCardState();
}

class _HistoryFilterCardState extends State<HistoryFilterCard>
    with TickerProviderStateMixin {
  bool expanded = false;

  String? selectedDebtStatus;
  DateTime? selectedBillPrintedDate;

  final TextEditingController searchController = TextEditingController();

  final List<HistoryFilterOption> debtStatusOptions = const [
    HistoryFilterOption(label: "Chưa gạch nợ", value: "CHUA_GACH_NO"),
    HistoryFilterOption(label: "Đã gạch nợ", value: "DA_GACH_NO"),
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String _formatDateForView(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year.toString().padLeft(4, '0')}";
  }

  String _formatDateForApi(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  String _getDebtStatusLabel(String? value) {
    if (value == null) return "";

    return debtStatusOptions
        .firstWhere(
          (e) => e.value == value,
          orElse: () => const HistoryFilterOption(label: "", value: ""),
        )
        .label;
  }


  bool get _hasFilter {
    return selectedBillPrintedDate != null ||
        selectedDebtStatus != null ||
        searchController.text.trim().isNotEmpty;
  }

  Future<void> _pickBillPrintedDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedBillPrintedDate ?? now,
      firstDate: DateTime(2024),
      lastDate: DateTime(now.year + 2),
    );

    if (picked == null) return;

    setState(() {
      selectedBillPrintedDate = picked;
    });
  }

  void _onSearch() {
    widget.onFilter(
      search: searchController.text.trim().isEmpty
          ? null
          : searchController.text.trim(),
      billPrintedDate: selectedBillPrintedDate == null
          ? null
          : _formatDateForApi(selectedBillPrintedDate!),
      debtStatus: selectedDebtStatus,
    );

    setState(() {
      expanded = false;
    });
  }

  void _resetFilter() {
    setState(() {
      searchController.clear();
      selectedDebtStatus = null;
      selectedBillPrintedDate = null;
      expanded = false;
    });

    widget.onReset();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          HistoryFilterHeader(
            expanded: expanded,
            hasFilter: _hasFilter,
            dateText: selectedBillPrintedDate == null
                ? null
                : _formatDateForView(selectedBillPrintedDate!),
            statusText: selectedDebtStatus == null
                ? null
                : _getDebtStatusLabel(selectedDebtStatus),
            searchText: searchController.text.trim().isEmpty
                ? null
                : searchController.text.trim(),
            onTap: () {
              setState(() {
                expanded = !expanded;
              });
            },
          ),
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: expanded
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
                      child: Column(
                        children: [
                          HistoryFilterForm(
                            searchController: searchController,
                            selectedDebtStatus: selectedDebtStatus,
                            selectedBillPrintedDate: selectedBillPrintedDate,
                            debtStatusOptions: debtStatusOptions,
                            formatDateForView: _formatDateForView,
                            onPickDate: _pickBillPrintedDate,
                            onSearch: _onSearch,
                            onDebtStatusChanged: (value) {
                              setState(() {
                                selectedDebtStatus = value;
                              });
                            },
                            onClearDebtStatus: () {
                              setState(() {
                                selectedDebtStatus = null;
                              });
                            },
                            onClearDate: () {
                              setState(() {
                                selectedBillPrintedDate = null;
                              });
                            },
                            onSearchTextChanged: (_) {
                              setState(() {});
                            },
                            onClearSearch: () {
                              setState(() {
                                searchController.clear();
                              });
                            },
                          ),
                          const SizedBox(height: 18),
                          HistoryFilterActionButtons(
                            onReset: _resetFilter,
                            onSearch: _onSearch,
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryFilterOption {
  final String label;
  final String value;

  const HistoryFilterOption({required this.label, required this.value});
}
