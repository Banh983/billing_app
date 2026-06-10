import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDateField extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateTime? value;
  final Function(DateTime?) onChanged;
  final bool enabled;
  final VoidCallback? onClear;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const CustomDateField({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.onClear,
    this.firstDate,
    this.lastDate,
  });

  static const primaryRed = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    final text = value == null ? '' : DateFormat('dd-MM-yyyy').format(value!);

    return SizedBox(
      height: 48,
      child: TextFormField(
        readOnly: true,
        enabled: enabled,
        controller: TextEditingController(text: text),
        onTap: enabled
            ? () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: value ?? DateTime.now(),
                  firstDate: firstDate ?? DateTime(1900),
                  lastDate: lastDate ?? DateTime(2100),
                );

                if (picked != null) {
                  onChanged(picked);
                }
              }
            : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF7F8FA),

          labelStyle: TextStyle(
            color: Colors.black.withOpacity(0.65),
            fontWeight: FontWeight.w600,
          ),

          floatingLabelStyle: const TextStyle(
            color: primaryRed,
            fontWeight: FontWeight.w700,
          ),

          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: Icon(icon, size: 20, color: primaryRed),
          ),

          prefixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),

          suffixIcon: value != null && onClear != null
              ? IconButton(
                  onPressed: enabled ? onClear : null,
                  icon: Icon(
                    Icons.close,
                    size: 18,
                    color: Colors.black.withOpacity(0.5),
                  ),
                )
              : const Icon(
                  Icons.calendar_month_rounded,
                  size: 20,
                  color: primaryRed,
                ),

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
            borderSide: const BorderSide(color: primaryRed, width: 1.4),
          ),

          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.black.withOpacity(0.05)),
          ),
        ),
      ),
    );
  }
}
