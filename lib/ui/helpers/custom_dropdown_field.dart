import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final String label;
  final IconData icon;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final Function(T?) onChanged;
  final bool enabled;
  final VoidCallback? onClear;

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
    this.enabled = true,
    this.onClear,
  });

  static const primaryRed = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField2<T>(
      value: value,
      isExpanded: true,
      items: items,
      onChanged: enabled ? onChanged : null,

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

        prefixIcon: Icon(icon, color: primaryRed),

        suffixIcon: value != null
            ? IconButton(
                onPressed: onClear,
                icon: Icon(
                  Icons.close,
                  size: 18,
                  color: Colors.black.withOpacity(0.5),
                ),
              )
            : null,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primaryRed, width: 1.5),
        ),
      ),

      buttonStyleData: const ButtonStyleData(height: 58),

      iconStyleData: const IconStyleData(
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: primaryRed),
      ),

      dropdownStyleData: DropdownStyleData(
        maxHeight: 250,

        offset: const Offset(0, 8),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
      ),

      menuItemStyleData: const MenuItemStyleData(height: 48),
    );
  }
}
