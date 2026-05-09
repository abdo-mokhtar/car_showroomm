import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MoneyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isDecimal;
  final String? Function(String?)? validator;

  const MoneyTextField({
    super.key,
    required this.controller,
    required this.label,
    this.isDecimal = true,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
      keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
      inputFormatters: [
        isDecimal
            ? FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))
            : FilteringTextInputFormatter.digitsOnly,
      ],
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        suffixText: 'ج',
        suffixStyle: const TextStyle(
          color: Color(0xFFE94560),
          fontWeight: FontWeight.bold,
        ),
        filled: true,
        fillColor: const Color(0xFF16213E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorStyle: const TextStyle(color: Colors.red),
      ),
    );
  }
}
