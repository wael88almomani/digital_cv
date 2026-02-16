import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.obscureText = false,
    this.suffixIcon,
    this.onSubmitted,
    this.validator,
  });

  final String label;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ??
        Theme.of(context).colorScheme.onSurface;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      obscureText: obscureText,
      style: TextStyle(color: textColor),
      cursorColor: Theme.of(context).colorScheme.primary,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      decoration: InputDecoration(labelText: label, suffixIcon: suffixIcon),
    );
  }
}
