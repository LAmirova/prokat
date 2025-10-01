import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prokat_app/app/providers.dart';
import 'package:prokat_app/core/l10n/l10n.dart';
import 'package:prokat_app/core/utils/formatters.dart';
import 'package:prokat_app/features/auth/widgets/phone_field.dart';
import 'package:prokat_app/features/auth/widgets/password_field.dart';
import 'package:prokat_app/features/auth/state/auth_notifier.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? _phoneValidator(String? v) {
    final l10n = AppLocalizations.of(context);
    final cleaned = getCleanPhone(v ?? '');
    if (!RegExp(r'^\+7\d{10}$').hasMatch(cleaned)) {
      return l10n.invalidPhone;
    }
    return null;
  }

  Future<void> _login() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final l10n = AppLocalizations.of(context);
    final cleanedPhone = getCleanPhone(phoneController.text);
    final password = passwordController.text.trim();

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.enterPassword)),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final repo = ref.read(authRepoProvider);
      await repo.login(cleanedPhone, password);

      // ✅ Обновляем состояние авторизации, чтобы GoRouter знал что мы вошли
      await ref.read(authNotifierProvider.notifier).check();

      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.apiError(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                Text(
                  l10n.loginTitle ?? 'Вход в систему',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Телефон
                PhoneField(
                  controller: phoneController,
                  validator: _phoneValidator,
                ),
                const SizedBox(height: 16),

                // Пароль
                PasswordField(controller: passwordController),

                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: Text(l10n.forgotPassword ?? 'Забыли пароль?'),
                  ),
                ),
                const SizedBox(height: 8),

                // Кнопка "Войти"
                ElevatedButton(
                  onPressed: isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.continueBtn ?? 'Войти'),
                ),

                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => context.push('/register'),
                    child: Text(
                      l10n.noAccountRegister ??
                          'Нет аккаунта? Зарегистрироваться',
                    ),
                  ),
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
