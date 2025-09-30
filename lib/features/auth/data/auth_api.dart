import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:prokat_app/core/network/dio_client.dart';
import 'package:prokat_app/core/network/api_exception.dart';

class AuthApi {
  /// Отправка номера телефона
  Future<void> sendPhone(String phone) async {
    debugPrint('➡️ Отправляем номер: $phone');
    try {
      final res = await dio.post(
        '/register',
        data: {'phone': phone},
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {'Accept': 'application/json'},
        ),
      );
      debugPrint('✅ Код отправлен: ${res.data}');
    } on DioException catch (e) {
      final msg = _extractErrorMessage(e) ?? 'Ошибка отправки номера';
      throw ApiException(msg, statusCode: e.response?.statusCode);
    }
  }

  /// Подтверждение кода
  Future<void> verifyCode(String phone, String code) async {
    debugPrint('➡️ Верифицируем: $phone, code=$code');
    try {
      final res = await dio.post(
        '/verify',
        data: {'phone': phone, 'code': code},
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {'Accept': 'application/json'},
        ),
      );
      debugPrint('✅ Код подтверждён: ${res.data}');
    } on DioException catch (e) {
      final msg = _extractErrorMessage(e) ?? 'Ошибка подтверждения кода';
      throw ApiException(msg, statusCode: e.response?.statusCode);
    }
  }

  /// Установка нового пароля
  Future<void> setPassword(String phone, String password) async {
    debugPrint('➡️ Устанавливаем пароль для $phone');
    try {
      final res = await dio.post(
        '/set-password',
        data: {'phone': phone, 'password': password},
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {'Accept': 'application/json'},
        ),
      );
      debugPrint('🔒 Пароль установлен: ${res.data}');
    } on DioException catch (e) {
      final msg = _extractErrorMessage(e) ?? 'Ошибка установки пароля';
      throw ApiException(msg, statusCode: e.response?.statusCode);
    }
  }

  /// Вход (password grant)
  Future<String> login(String phone, String password) async {
    debugPrint('➡️ Логинимся: $phone');
    try {
      final res = await dio.post(
        '/login',
        data: {
          'grant_type': 'password',
          'username': phone,
          'password': password,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {'Accept': 'application/json'},
        ),
      );
      final token = res.data['access_token']?.toString();
      if (token == null || token.isEmpty) {
        throw ApiException('Пустой токен');
      }
      // Не логируем токен!
      return token;
    } on DioException catch (e) {
      final msg = _extractErrorMessage(e) ?? 'Ошибка входа';
      throw ApiException(msg, statusCode: e.response?.statusCode);
    }
  }

  String? _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data == null) return null;

    if (data is Map && data['detail'] != null) {
      final detail = data['detail'];
      if (detail is String) return detail;
      if (detail is List && detail.isNotEmpty && detail.first is Map) {
        return detail.first['msg']?.toString();
      }
    }
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return data.toString();
  }
}
