import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Базовый экземпляр Dio для всего приложения.
/// — подставь свой baseUrl при необходимости.
final Dio dio = Dio(
  BaseOptions(
    baseUrl: 'https://laurink.ru.tuna.am',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    // Если сервер иногда отдаёт 4xx/5xx, а ты хочешь читать тело —
    // оставь обработку ошибок на try/catch, а здесь не меняй validateStatus.
  ),
);

/// Интерцептор, который добавляет заголовок Authorization для всех запросов.
/// В сторидже лежит уже готовая строка вида "Bearer <token>" —
/// поэтому подставляем её «как есть», без префиксов.
class AuthTokenInterceptor extends Interceptor {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: 'access_token');
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = token; // <-- как есть
    }
    handler.next(options);
  }
}

/// (Опционально) простой логгер запросов/ответов
class SimpleLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // print('[DIO] => ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // print('[DIO] <= ERROR ${err.response?.statusCode} ${err.requestOptions.uri}');
    handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // print('[DIO] <= ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }
}

/// Подключаем интерцепторы один раз при старте приложения.
void initDio() {
  // чтобы не добавлять повторно при hot-reload
  final hasAuth = dio.interceptors.any((i) => i is AuthTokenInterceptor);
  if (!hasAuth) {
    dio.interceptors.add(AuthTokenInterceptor());
  }

  final hasLogger = dio.interceptors.any((i) => i is SimpleLogInterceptor);
  if (!hasLogger) {
    dio.interceptors.add(SimpleLogInterceptor());
  }
}
