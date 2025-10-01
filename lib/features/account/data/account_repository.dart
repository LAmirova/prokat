import 'package:prokat_app/features/account/data/account_api.dart';

class PassportData {
  final String? seriesNumber;
  final String? lastName;
  final String? firstName;
  final String? middleName;
  final String? birthDate;
  final String? birthPlace;
  final String? gender;
  final String? issueDate;
  final String? issueAuthority;
  final String? divisionCode;
  final String? extractedAt;

  const PassportData({
    this.seriesNumber,
    this.lastName,
    this.firstName,
    this.middleName,
    this.birthDate,
    this.birthPlace,
    this.gender,
    this.issueDate,
    this.issueAuthority,
    this.divisionCode,
    this.extractedAt,
  });

  factory PassportData.fromJson(Map<String, dynamic>? m) {
    if (m == null) return const PassportData();
    return PassportData(
      seriesNumber: m['series_number']?.toString(),
      lastName: m['last_name']?.toString(),
      firstName: m['first_name']?.toString(),
      middleName: m['middle_name']?.toString(),
      birthDate: m['birth_date']?.toString(),
      birthPlace: m['birth_place']?.toString(),
      gender: m['gender']?.toString(),
      issueDate: m['issue_date']?.toString(),
      issueAuthority: m['issue_authority']?.toString(),
      divisionCode: m['division_code']?.toString(),
      extractedAt: m['extracted_at']?.toString(),
    );
  }
}

class UserMe {
  final int id;
  final String phone;
  final bool isVerified;
  final bool isActive;
  final bool isAdmin;
  final String createdAt;
  final PassportData passport;

  const UserMe({
    required this.id,
    required this.phone,
    required this.isVerified,
    required this.isActive,
    required this.isAdmin,
    required this.createdAt,
    required this.passport,
  });

  factory UserMe.fromJson(Map<String, dynamic> m) => UserMe(
        id: (m['id'] as num?)?.toInt() ?? 0,
        phone: m['phone']?.toString() ?? '',
        isVerified: (m['is_verified'] as bool?) ?? false,
        isActive: (m['is_active'] as bool?) ?? true,
        isAdmin: (m['is_admin'] as bool?) ?? false,
        createdAt: m['created_at']?.toString() ?? '',
        passport:
            PassportData.fromJson(m['passport_data'] as Map<String, dynamic>?),
      );
}

class AccountRepository {
  final AccountApi api;
  AccountRepository(this.api);

  Future<UserMe> me() async => UserMe.fromJson(await api.getMe());

  /// Только загрузка фото паспорта (сервер сам привяжет к пользователю).
  Future<void> uploadPassportPhotos(List<String> filePaths) =>
      api.uploadPassportPhotos(filePaths);
}
