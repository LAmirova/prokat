import 'package:dio/dio.dart';

final dio = Dio(BaseOptions(
  baseUrl: 'https://laurink.ru.tuna.am', // твой бэкенд
  connectTimeout: const Duration(seconds: 10),
));

/// Пример перехватчика для токена, если позже подключишь хранение токена
class AuthInterceptor extends Interceptor {
  String? _token;
  void updateToken(String? t) => _token = t;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_token != null && _token!.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $_token';
    }
    super.onRequest(options, handler);
  }
}
