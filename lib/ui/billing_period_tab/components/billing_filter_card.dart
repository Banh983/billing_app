import 'package:billing_app/ui/helpers/custom_dropdown_field.dart';
import 'package:flutter/material.dart';

import 'package:billing_app/core/app_colors.dart';

enum BillingFilterType { period, record }

class BillingFilterCard extends StatefulWidget {
  final BillingFilterType type;

  const BillingFilterCard({super.key, required this.type});

  @override
  State<BillingFilterCard> createState() => _BillingFilterCardState();
}

class _BillingFilterCardState extends State<BillingFilterCard>
    with TickerProviderStateMixin {
  bool expanded = false;

  /// PERIOD FILTER
  String? selectedYear;
  String? selectedPeriodStatus;

  /// RECORD FILTER
  String? selectedRecordStatus;
  String? selectedWard;

  final TextEditingController searchController = TextEditingController();

  /// MOCK DATA
  /// TODO: Replace with API

  final List<String> years = ["2025", "2026", "2027"];

  final List<String> periodStatuses = ["OPEN", "CLOSED"];

  final List<String> recordStatuses = ["CHUA_THU", "DA_IN_BILL", "DA_GACH_NO"];

  final List<String> wards = ["Hiệp Hưng", "Hòa An"];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void resetFilter() {
    setState(() {
      selectedYear = null;
      selectedPeriodStatus = null;

      selectedRecordStatus = null;
      selectedWard = null;

      searchController.clear();
    });
  }

  void onSearch() {
    if (widget.type == BillingFilterType.period) {
      final filters = {"year": selectedYear, "status": selectedPeriodStatus};

      debugPrint("PERIOD FILTER");
      debugPrint(filters.toString());

      /// TODO
      /// context.read<BillingPeriodProvider>().filter(...)
    } else {
      final filters = {
        "status": selectedRecordStatus,
        "ward": selectedWard,
        "search": searchController.text.trim(),
      };

      debugPrint("RECORD FILTER");
      debugPrint(filters.toString());

      /// TODO
      /// context.read<BillingRecordProvider>().filter(...)
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPeriod = widget.type == BillingFilterType.period;

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

            onTap: () {
              setState(() {
                expanded = !expanded;
              });
            },

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
                      Icons.filter_alt_outlined,
                      color: AppColors.primaryRed,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Text(
                      isPeriod ? "Bộ lọc kỳ cước" : "Bộ lọc hóa đơn",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                          if (isPeriod) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: CustomDropdownField<String>(
                                    label: "Năm",

                                    icon: Icons.calendar_month,

                                    value: selectedYear,

                                    items: years.map((e) {
                                      return DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      );
                                    }).toList(),

                                    onChanged: (v) {
                                      setState(() {
                                        selectedYear = v;
                                      });
                                    },

                                    onClear: () {
                                      setState(() {
                                        selectedYear = null;
                                      });
                                    },
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: CustomDropdownField<String>(
                                    label: "Trạng thái",

                                    icon: Icons.pending_actions,

                                    value: selectedPeriodStatus,

                                    items: periodStatuses.map((e) {
                                      return DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      );
                                    }).toList(),

                                    onChanged: (v) {
                                      setState(() {
                                        selectedPeriodStatus = v;
                                      });
                                    },

                                    onClear: () {
                                      setState(() {
                                        selectedPeriodStatus = null;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],

                          if (!isPeriod) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: CustomDropdownField<String>(
                                    label: "Trạng thái",

                                    icon: Icons.pending_actions,

                                    value: selectedRecordStatus,

                                    items: recordStatuses.map((e) {
                                      return DropdownMenuItem(
                                        value: e,
                                        child: Text(
                                          e,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),

                                    onChanged: (v) {
                                      setState(() {
                                        selectedRecordStatus = v;
                                      });
                                    },

                                    onClear: () {
                                      setState(() {
                                        selectedRecordStatus = null;
                                      });
                                    },
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: CustomDropdownField<String>(
                                    label: "Xã",

                                    icon: Icons.location_city,

                                    value: selectedWard,

                                    items: wards.map((e) {
                                      return DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      );
                                    }).toList(),

                                    onChanged: (v) {
                                      setState(() {
                                        selectedWard = v;
                                      });
                                    },

                                    onClear: () {
                                      setState(() {
                                        selectedWard = null;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            TextField(
                              controller: searchController,

                              decoration: InputDecoration(
                                hintText: "Tên KH / SĐT / Mã khách hàng",

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

                              onChanged: (_) {
                                setState(() {});
                              },
                            ),
                          ],

                          const SizedBox(height: 18),

                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(
                                      double.infinity,
                                      54,
                                    ),
                                  ),

                                  onPressed: resetFilter,

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

                                    onPressed: onSearch,

                                    icon: const Icon(
                                      Icons.search,
                                      color: Colors.white,
                                    ),

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
