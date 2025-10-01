import 'package:prokat_app/features/account/data/account_api.dart';

class UserMe {
  final int id;
  final String phone;
  final String? name;
  final String? email;
  final String? avatarUrl;
  final bool isVerified;

  const UserMe({
    required this.id,
    required this.phone,
    this.name,
    this.email,
    this.avatarUrl,
    required this.isVerified,
  });

  factory UserMe.fromJson(Map<String, dynamic> m) => UserMe(
        id: (m['id'] as num).toInt(),
        phone: m['phone']?.toString() ?? '',
        name: m['name']?.toString(),
        email: m['email']?.toString(),
        avatarUrl: m['avatar']?.toString(),
        isVerified: (m['is_verified'] as bool?) ?? false,
      );
}

class AccountRepository {
  final AccountApi api;
  AccountRepository(this.api);

  Future<UserMe> me() async {
    final m = await api.getMe();
    return UserMe.fromJson(m);
  }

  Future<void> uploadPassport(List<String> files) => api.uploadPassport(files);
}
