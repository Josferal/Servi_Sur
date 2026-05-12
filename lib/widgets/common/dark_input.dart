import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class DarkInput extends StatefulWidget {
  const DarkInput({
    super.key,
    required this.hint,
    this.label,
    this.icon,
    this.trailing,
    this.maxLines = 1,
    this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.readOnly = false,
    this.onTap,
    this.isPassword = false,
    this.focusNode,
    this.onChanged,
  });

  final String hint;
  final String? label;
  final IconData? icon;
  final Widget? trailing;
  final int maxLines;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool isPassword;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;

  @override
  State<DarkInput> createState() => _DarkInputState();
}

class _DarkInputState extends State<DarkInput> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  void didUpdateWidget(covariant DarkInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPassword != widget.isPassword) {
      _obscureText = widget.isPassword;
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final suffixIcon = widget.isPassword
        ? IconButton(
            onPressed: _togglePasswordVisibility,
            tooltip: _obscureText ? 'Mostrar contraseña' : 'Ocultar contraseña',
            icon: Icon(
              _obscureText
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.textSecondary,
            ),
          )
        : widget.trailing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          obscureText: _obscureText,
          enableSuggestions: !widget.isPassword,
          autocorrect: !widget.isPassword,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.icon == null
                ? null
                : Icon(widget.icon, color: AppColors.textSecondary),
            suffixIcon: suffixIcon,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: widget.maxLines > 1 ? 22 : 0,
            ),
          ),
        ),
      ],
    );
  }
}
