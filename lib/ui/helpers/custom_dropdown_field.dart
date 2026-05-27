import 'package:flutter/material.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final String label;
  final IconData icon;

  final T value;
  final List<DropdownMenuItem<T>> items;

  final Function(T?) onChanged;

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  static const primaryRed = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,

      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: primaryRed,
      ),

      borderRadius: BorderRadius.circular(12),

      dropdownColor: Colors.white,

      style: const TextStyle(
        color: Colors.black87,
        fontSize: 15,
      ),

      onChanged: onChanged,

      decoration: InputDecoration(
        labelText: label,

        labelStyle: const TextStyle(
          color: Colors.grey,
        ),

        floatingLabelStyle: const TextStyle(
          color: primaryRed,
          fontWeight: FontWeight.w500,
        ),

        prefixIcon: Icon(
          icon,
          color: primaryRed,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.grey,
          ),
        ),

        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(12),
          ),
          borderSide: BorderSide(
            color: primaryRed,
            width: 1.5,
          ),
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
      ),

      items: items,
    );
  }
}