import 'package:flutter/material.dart';

class CustomInputField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;

  final bool isPassword;
  final bool? initialObscure;

  final Function(String)? onSubmitted;

  const CustomInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.initialObscure,
    this.onSubmitted,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  static const primaryRed = Color(0xFFE53935);

  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.initialObscure ?? widget.isPassword;
  }

  void _toggle() {
    setState(() {
      _obscure = !_obscure;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscure : false,
      cursorColor: primaryRed,
      onSubmitted: widget.onSubmitted,

      decoration: InputDecoration(
        labelText: widget.label,

        labelStyle: const TextStyle(color: Colors.grey),

        floatingLabelStyle: const TextStyle(
          color: primaryRed,
          fontWeight: FontWeight.w500,
        ),

        prefixIcon: Icon(widget.icon),

        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: _toggle,
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
              )
            : null,

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),

        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: primaryRed),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}
