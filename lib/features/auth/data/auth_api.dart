import 'package:dio/dio.dart';
import 'package:prokat_app/core/network/dio_client.dart';

/// Низкоуровневый слой авторизации.
/// ВАЖНО: /login — form-urlencoded с grant_type=password.
/// Остальные эндпоинты подстрой под свои (я оставил очевидные пути).
class AuthApi {
  final Dio _dio = dio;

  /// 📲 Отправка номера (если используется пошаговая регистрация)
  Future<void> sendPhone(String phone) async {
    // TODO: замени путь при необходимости
    await _dio.post('/auth/send-phone', data: {'phone': phone});
  }

  /// ✅ Проверка кода из СМС/телеграма
  Future<void> verifyCode(String phone, String code) async {
    // TODO: замени путь при необходимости
    await _dio.post('/auth/verify', data: {'phone': phone, 'code': code});
  }

  /// 🔐 Установка/сброс пароля для номера
  Future<void> setPassword(String phone, String password) async {
    // TODO: замени путь при необходимости
    await _dio.post('/auth/set-password', data: {
      'phone': phone,
      'password': password,
    });
  }

  /// 🔓 Логин по паролю (OAuth2 Password Grant).
  /// Возвращает строку заголовка `Authorization`, например: "Bearer eyJ...".
  Future<String> login(String username, String password) async {
    final res = await _dio.post(
      '/login',
      data: {
        'grant_type': 'password',
        'username': username,
        'password': password,
        'scope': '',
        'client_id': '',
        'client_secret': '',
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    final data = res.data as Map<String, dynamic>;
    final token = data['access_token']?.toString();
    var type = (data['token_type']?.toString() ?? 'Bearer');
    // нормализуем тип, если сервер прислал "bearer"
    if (type.toLowerCase() == 'bearer') type = 'Bearer';

    if (token == null || token.isEmpty) {
      throw Exception('Не удалось получить access_token');
    }
    return '$type $token';
  }
}
