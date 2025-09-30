import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_api.dart';

class AuthRepository {
  final AuthApi _api = AuthApi();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// 📲 Отправка номера телефона
  Future<void> registerPhone(String phone) async {
    await _api.sendPhone(phone);
  }

  /// ✅ Верификация кода
  Future<void> verify(String phone, String code) async {
    await _api.verifyCode(phone, code);
  }

  /// 🔐 Установка нового пароля
  Future<void> setPassword(String phone, String password) async {
    await _api.setPassword(phone, password);
  }

  /// 🔓 Вход, получение токена и его сохранение
  Future<void> login(String phone, String password) async {
    final token = await _api.login(phone, password);
    await _storage.write(key: 'access_token', value: token);
  }

  /// 🧾 Получение сохранённого токена
  Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }

  /// 🚪 Выход — удаление токена
  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
  }

  /// 📡 Проверка авторизации
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
