import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class AppField extends StatefulWidget {
  final String? label;
  final String? placeholder;
  final String? value;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool isPassword;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool autoFocus;
  final int? maxLength;
  final int maxLines;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;

  const AppField({
    super.key,
    this.label,
    this.placeholder,
    this.value,
    this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.isPassword = false,
    this.prefixIcon,
    this.suffixIcon,
    this.autoFocus = false,
    this.maxLength,
    this.maxLines = 1,
    this.textInputAction,
    this.onEditingComplete,
    this.controller,
    this.validator,
  });

  @override
  State<AppField> createState() => _AppFieldState();
}

class _AppFieldState extends State<AppField> {
  late final TextEditingController _ctrl;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _ctrl = widget.controller ?? TextEditingController(text: widget.value ?? '');
  }

  @override
  void didUpdateWidget(AppField old) {
    super.didUpdateWidget(old);
    if (widget.controller == null && old.value != widget.value && _ctrl.text != widget.value) {
      _ctrl.value = _ctrl.value.copyWith(text: widget.value ?? '');
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final obscure = widget.isPassword || widget.obscureText;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _focused ? AppColors.primaryGold : AppColors.darkGray,
              width: 1.0,
            ),
            boxShadow: _focused
                ? [
                    BoxShadow(
                        color: AppColors.primaryGold.withValues(alpha: 0.1), blurRadius: 0, spreadRadius: 4)
                  ]
                : [],
          ),
          child: Row(
            children: [
              if (widget.prefixIcon != null) ...[
                const SizedBox(width: 14),
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    _focused ? AppColors.primaryGold : AppColors.textSecondary,
                    BlendMode.srcIn,
                  ),
                  child: widget.prefixIcon!,
                ),
                const SizedBox(width: 10),
              ] else
                const SizedBox(width: 14),
              Expanded(
                child: Focus(
                  onFocusChange: (f) => setState(() => _focused = f),
                  child: TextFormField(
                    controller: _ctrl,
                    onChanged: widget.onChanged,
                    keyboardType: widget.keyboardType,
                    obscureText: obscure,
                    autofocus: widget.autoFocus,
                    maxLength: widget.maxLength,
                    maxLines: widget.maxLines,
                    textInputAction: widget.textInputAction,
                    onEditingComplete: widget.onEditingComplete,
                    validator: widget.validator,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.placeholder,
                      hintStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15.5,
                        fontWeight: FontWeight.w400,
                        color: AppColors.darkGray,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      fillColor: Colors.transparent,
                      isDense: true,
                      counterText: '',
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      errorStyle: const TextStyle(height: 0, color: Colors.transparent),
                    ),
                  ),
                ),
              ),
              if (widget.suffixIcon != null) ...[
                widget.suffixIcon!,
                const SizedBox(width: 4),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
