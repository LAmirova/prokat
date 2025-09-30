import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prokat_app/core/utils/phone_input_formatter.dart';

class PhoneField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool autofocus;

  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;

  const PhoneField({
    super.key,
    required this.controller,
    this.label = 'Номер телефона',
    this.autofocus = false,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  State<PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<PhoneField> {
  @override
  void initState() {
    super.initState();
    if (widget.controller.text.isEmpty) {
      // Старт — именно "+7 ", без скобки
      widget.controller.text = '+7 ';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        try {
          widget.controller.selection =
              const TextSelection.collapsed(offset: 3);
        } catch (_) {}
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      autofocus: widget.autofocus,
      keyboardType: TextInputType.phone,
      // ВАЖНО: только наш форматтер, без digitsOnly
      inputFormatters: <TextInputFormatter>[
        PhoneInputFormatter(),
      ],
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: '+7 (___) ___-__-__',
        prefixIcon: const Icon(Icons.phone),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      autofillHints: const [AutofillHints.telephoneNumber],
      validator: widget.validator,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
    );
  }
}
