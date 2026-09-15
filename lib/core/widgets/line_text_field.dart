import 'package:flutter/material.dart';

import 'package:natal_iq/core/theme/app_theme.dart';

/// A label-above, underline-only text field — no filled box — matching the
/// app's warm/paper aesthetic better than a boxed Material input.
class LineTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? errorText;
  final Widget? suffix;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final bool autofocus;

  const LineTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.errorText,
    this.suffix,
    this.onSubmitted,
    this.onChanged,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: sansFont(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.mutedForeground, letterSpacing: 1.1),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          onChanged: onChanged,
          style: sansFont(fontSize: 16, fontWeight: FontWeight.w600),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            isDense: true,
            hintText: hintText,
            hintStyle: sansFont(fontSize: 16, color: AppColors.mutedForeground.withValues(alpha: 0.6)),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            suffixIcon: suffix,
            border: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border, width: 1.5)),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border, width: 1.5)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)),
            errorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.destructive, width: 1.5)),
            focusedErrorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.destructive, width: 2)),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(errorText!, style: sansFont(fontSize: 12, color: AppColors.destructive)),
        ],
      ],
    );
  }
}
