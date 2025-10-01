import 'package:dio/dio.dart';
import 'package:prokat_app/core/network/dio_client.dart';

class AccountApi {
  final Dio _dio = dio;

  /// Текущий пользователь
  Future<Map<String, dynamic>> getMe() async {
    final r = await _dio.get('/users/me');
    return (r.data as Map<String, dynamic>);
  }

  /// Загрузка фото паспорта (1..N изображений)
  Future<void> uploadPassportPhotos(List<String> filePaths) async {
    final form = FormData();
    for (final p in filePaths) {
      form.files.add(MapEntry(
        'files',
        await MultipartFile.fromFile(p, filename: p.split('/').last),
      ));
    }
    await _dio.post(
      '/users/me/upload_passport',
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );
  }
}
