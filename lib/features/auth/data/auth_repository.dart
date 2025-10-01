import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_api.dart';

/// Высокоуровневый репозиторий: хранит токен и вызывает API.
class AuthRepository {
  final AuthApi _api = AuthApi();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// 📲 Шаг 1: отправить телефон (если используется в твоём флоу)
  Future<void> registerPhone(String phone) async {
    await _api.sendPhone(phone);
  }

  /// ✅ Шаг 2: проверить код
  Future<void> verify(String phone, String code) async {
    await _api.verifyCode(phone, code);
  }

  /// 🔐 Шаг 3: задать пароль
  Future<void> setPassword(String phone, String password) async {
    await _api.setPassword(phone, password);
  }

  /// 🔓 Вход: сохраняем уже готовую строку заголовка Authorization
  /// (например, "Bearer eyJ...") — так интерцептор просто подставит её как есть.
  Future<void> login(String username, String password) async {
    final fullAuthHeader = await _api.login(username, password);
    await _storage.write(key: 'access_token', value: fullAuthHeader);
  }

  /// 🧾 Получение сохранённого заголовка Authorization
  Future<String?> getToken() => _storage.read(key: 'access_token');

  /// 🚪 Выход — удаление токена
  Future<void> logout() => _storage.delete(key: 'access_token');

  /// 📡 Проверка авторизации
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
