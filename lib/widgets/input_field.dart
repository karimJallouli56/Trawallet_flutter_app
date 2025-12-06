import 'package:flutter/material.dart';

class InputField extends StatefulWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final int maxLines;
  final bool withBorder;
  final bool isPassword;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const InputField({
    super.key,
    required this.label,
    required this.icon,
    required this.controller,
    this.maxLines = 1,
    required this.withBorder,
    this.isPassword = false,
    this.validator,
    this.keyboardType,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  bool _hidePassword = true;
  String? _errorText;

  void _validate(String value) {
    if (widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            border: widget.withBorder
                ? Border.all(
                    color: _errorText != null
                        ? Colors.red
                        : Colors.teal.shade600,
                    width: 1.2,
                  )
                : null,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.teal.withOpacity(0.12),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: widget.controller,
            maxLines: widget.maxLines,
            obscureText: widget.isPassword ? _hidePassword : false,
            keyboardType: widget.keyboardType,
            onChanged: _validate,
            decoration: InputDecoration(
              labelText: widget.label,
              border: InputBorder.none,
              prefixIcon: Icon(
                widget.icon,
                color: _errorText != null ? Colors.red : Colors.teal,
              ),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _hidePassword ? Icons.visibility_off : Icons.visibility,
                        color: _errorText != null ? Colors.red : Colors.teal,
                      ),
                      onPressed: () =>
                          setState(() => _hidePassword = !_hidePassword),
                    )
                  : null,
              labelStyle: TextStyle(
                color: _errorText != null ? Colors.red : Colors.grey.shade600,
              ),
            ),
          ),
        ),
        if (_errorText != null) ...{
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              _errorText!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        },
      ],
    );
  }
}
