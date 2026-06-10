import 'package:billing_app/core/app_colors.dart';
import 'package:billing_app/ui/helpers/custom_dropdown_field.dart';
import 'package:billing_app/ui/history_tab/components/history_filter_card.dart';
import 'package:flutter/material.dart';

class HistoryFilterForm extends StatelessWidget {
  final TextEditingController searchController;

  final String? selectedDebtStatus;
  final DateTime? selectedBillPrintedDate;

  final List<HistoryFilterOption> debtStatusOptions;

  final String Function(DateTime date) formatDateForView;

  final VoidCallback onPickDate;
  final VoidCallback onSearch;
  final ValueChanged<String?> onDebtStatusChanged;
  final VoidCallback onClearDebtStatus;
  final VoidCallback onClearDate;
  final ValueChanged<String> onSearchTextChanged;
  final VoidCallback onClearSearch;

  const HistoryFilterForm({
    super.key,
    required this.searchController,
    required this.selectedDebtStatus,
    required this.selectedBillPrintedDate,
    required this.debtStatusOptions,
    required this.formatDateForView,
    required this.onPickDate,
    required this.onSearch,
    required this.onDebtStatusChanged,
    required this.onClearDebtStatus,
    required this.onClearDate,
    required this.onSearchTextChanged,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _responsiveTwoColumns(
          first: CustomDropdownField<String>(
            label: "Trạng thái",
            icon: Icons.account_balance_wallet_outlined,
            value: selectedDebtStatus,
            items: debtStatusOptions
                .map(
                  (e) => DropdownMenuItem(
                    value: e.value,
                    child: Text(e.label, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: onDebtStatusChanged,
            onClear: onClearDebtStatus,
          ),
          second: _dateField(),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: searchController,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => onSearch(),
          decoration: InputDecoration(
            hintText: "Tên KH / SĐT / Thuê bao / Địa chỉ",
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            prefixIcon: const Icon(Icons.search, color: AppColors.primaryRed),
            suffixIcon: searchController.text.isEmpty
                ? null
                : IconButton(
                    onPressed: onClearSearch,
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
          onChanged: onSearchTextChanged,
        ),
      ],
    );
  }

  Widget _dateField() {
    return SizedBox(
      height: 48,
      child: TextFormField(
        key: ValueKey(selectedBillPrintedDate),
        readOnly: true,
        onTap: onPickDate,
        controller: TextEditingController(
          text: selectedBillPrintedDate == null
              ? ""
              : formatDateForView(selectedBillPrintedDate!),
        ),
        decoration: InputDecoration(
          labelText: "Ngày thu",
          hintText: "Chọn ngày thu",
          filled: true,
          fillColor: const Color(0xFFF7F8FA),
          labelStyle: TextStyle(
            color: Colors.black.withOpacity(0.65),
            fontWeight: FontWeight.w600,
          ),
          floatingLabelStyle: const TextStyle(
            color: AppColors.primaryRed,
            fontWeight: FontWeight.w700,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 12, right: 8),
            child: Icon(
              Icons.calendar_today_rounded,
              size: 20,
              color: AppColors.primaryRed,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
          suffixIcon: selectedBillPrintedDate != null
              ? IconButton(
                  onPressed: onClearDate,
                  icon: Icon(
                    Icons.close,
                    size: 18,
                    color: Colors.black.withOpacity(0.5),
                  ),
                )
              : null,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.primaryRed,
              width: 1.4,
            ),
          ),
        ),
      ),
    );
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
}
