import 'package:flutter/services.dart';

/// Маска: +7 (XXX) XXX-XX-XX
/// Стартовое значение: "+7 "
/// Скобка появляется, когда введена хотя бы 1 цифра.
/// Удаление позволяет вернуться до "+7 ".
class PhoneInputFormatter extends TextInputFormatter {
  static const int _maxDigits = 10;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Все цифры из текста
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // В тексте всегда будет цифра "7" из "+7 ". Это НЕ часть номера.
    // Если текст начинается с "+7", выкидываем первую '7' из набора цифр.
    if (newValue.text.startsWith('+7') && digits.isNotEmpty) {
      digits = digits.substring(1);
    }

    // Обрезаем до 10 цифр (после кода страны)
    if (digits.length > _maxDigits) {
      digits = digits.substring(0, _maxDigits);
    }

    // Если пользователь всё стер — оставляем базовый префикс "+7 "
    if (digits.isEmpty) {
      const base = '+7 ';
      return const TextEditingValue(
        text: base,
        selection: TextSelection.collapsed(offset: base.length),
      );
    }

    // Собираем формат динамически:
    final buf = StringBuffer('+7 ');

    // Код города/оператора (до 3 цифр). Скобку добавляем, когда есть хотя бы 1 цифра
    buf.write('(');
    final a = digits.substring(0, digits.length.clamp(0, 3));
    buf.write(a);
    if (digits.length >= 3) {
      buf.write(') ');
    }

    // Следующие 3 цифры
    if (digits.length > 3) {
      final b = digits.substring(3, digits.length.clamp(3, 6));
      buf.write(b);
      if (digits.length >= 6) {
        buf.write('-');
      }
    }

    // Следующие 2 цифры
    if (digits.length > 6) {
      final c = digits.substring(6, digits.length.clamp(6, 8));
      buf.write(c);
      if (digits.length >= 8) {
        buf.write('-');
      }
    }

    // Последние 2 цифры
    if (digits.length > 8) {
      final d = digits.substring(8, digits.length.clamp(8, 10));
      buf.write(d);
    }

    final formatted = buf.toString();
    return TextEditingValue(
      text: formatted,
      // Ставим каретку в конец — простое и предсказуемое поведение
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
