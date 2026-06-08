import 'package:billing_app/core/app_colors.dart';
import 'package:billing_app/ui/helpers/custom_dropdown_field.dart';
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
  String? selectedBillPrintedDate;

  final TextEditingController searchController = TextEditingController();

  final List<_FilterOption> debtStatusOptions = const [
    _FilterOption(label: "Chưa gạch nợ", value: "CHUA_GACH_NO"),
    _FilterOption(label: "Đã gạch nợ", value: "DA_GACH_NO"),
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _pickBillPrintedDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2024),
      lastDate: DateTime(now.year + 2),
    );

    if (picked == null) return;

    setState(() {
      selectedBillPrintedDate =
          "${picked.year.toString().padLeft(4, '0')}-"
          "${picked.month.toString().padLeft(2, '0')}-"
          "${picked.day.toString().padLeft(2, '0')}";
    });
  }

  void _onSearch() {
    widget.onFilter(
      search: searchController.text.trim().isEmpty
          ? null
          : searchController.text.trim(),
      billPrintedDate: selectedBillPrintedDate,
      debtStatus: selectedDebtStatus,
    );
  }

  void _resetFilter() {
    setState(() {
      searchController.clear();
      selectedDebtStatus = null;
      selectedBillPrintedDate = null;
    });

    widget.onReset();
  }

  Widget _responsiveTwoColumns({
    required Widget first,
    required Widget second,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 430;

        final itemWidth = isSmall
            ? constraints.maxWidth
            : (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 14,
          children: [
            SizedBox(width: itemWidth, child: first),
            SizedBox(width: itemWidth, child: second),
          ],
        );
      },
    );
  }

  Widget _actionButtons() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 360;

        if (isSmall) {
          return Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: _resetFilter,
                  child: const Text("ĐẶT LẠI"),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                  ),
                  onPressed: _onSearch,
                  icon: const Icon(Icons.search, color: Colors.white),
                  label: const Text(
                    "TÌM KIẾM",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                ),
                onPressed: _resetFilter,
                child: const Text("ĐẶT LẠI"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                  ),
                  onPressed: _onSearch,
                  icon: const Icon(Icons.search, color: Colors.white),
                  label: const Text(
                    "TÌM KIẾM",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
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
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            onTap: () => setState(() => expanded = !expanded),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.history,
                      color: AppColors.primaryRed,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      "Bộ lọc lịch sử thu cước",
                      maxLines: 3,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(Icons.keyboard_arrow_down),
                  ),
                ],
              ),
            ),
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
                          _responsiveTwoColumns(
                            first: CustomDropdownField<String>(
                              label: "Gạch nợ",
                              icon: Icons.account_balance_wallet_outlined,
                              value: selectedDebtStatus,
                              items: debtStatusOptions
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e.value,
                                      child: Text(
                                        e.label,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) {
                                setState(() => selectedDebtStatus = v);
                              },
                              onClear: () {
                                setState(() => selectedDebtStatus = null);
                              },
                            ),
                            second: InkWell(
                              onTap: _pickBillPrintedDate,
                              borderRadius: BorderRadius.circular(18),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: "Ngày thu",
                                  prefixIcon: const Icon(
                                    Icons.event_available,
                                    color: AppColors.primaryRed,
                                  ),
                                  suffixIcon: selectedBillPrintedDate == null
                                      ? null
                                      : IconButton(
                                          onPressed: () {
                                            setState(() {
                                              selectedBillPrintedDate = null;
                                            });
                                          },
                                          icon: const Icon(
                                            Icons.close,
                                            size: 18,
                                          ),
                                        ),
                                  filled: true,
                                  fillColor: AppColors.background,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                child: Text(
                                  selectedBillPrintedDate ?? "Chọn ngày",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          TextField(
                            controller: searchController,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (_) => _onSearch(),
                            decoration: InputDecoration(
                              hintText: "Tên KH / SĐT/ Thuê bao/ Địa chỉ",
                              hintStyle: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: AppColors.primaryRed,
                              ),
                              suffixIcon: searchController.text.isEmpty
                                  ? null
                                  : IconButton(
                                      onPressed: () {
                                        setState(() {
                                          searchController.clear();
                                        });
                                      },
                                      icon: Icon(
                                        Icons.close,
                                        size: 18,
                                        color: Colors.black.withOpacity(0.5),
                                      ),
                                    ),
                              filled: true,
                              fillColor: AppColors.background,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),

                          const SizedBox(height: 18),

                          _actionButtons(),
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

class _FilterOption {
  final String label;
  final String value;

  const _FilterOption({required this.label, required this.value});
}
