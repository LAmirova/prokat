import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:prokat_app/app/providers.dart'; // authRepoProvider
import 'package:prokat_app/core/l10n/l10n.dart';
import 'package:prokat_app/features/auth/widgets/password_field.dart';

class SetPasswordPage extends ConsumerStatefulWidget {
  const SetPasswordPage({super.key});

  @override
  ConsumerState<SetPasswordPage> createState() => _SetPasswordPageState();
}

class _SetPasswordPageState extends ConsumerState<SetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  String? _phone; // из extra
  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra;
    if (extra is String) _phone ??= extra;
  }

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool _isStrong(String v) {
    if (v.length < 8) return false;
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(v);
    final hasDigit = RegExp(r'\d').hasMatch(v);
    return hasLetter && hasDigit;
  }

  String? _passwordValidator(String? v) {
    final l10n = AppLocalizations.of(context)!;
    final value = (v ?? '').trim();
    if (value.isEmpty) return l10n.enterPassword;
    if (!_isStrong(value)) return l10n.passwordWeak;
    return null;
  }

  String? _confirmValidator(String? v) {
    final l10n = AppLocalizations.of(context)!;
    final value = (v ?? '').trim();
    if (value.isEmpty) return l10n.confirmPassword;
    if (value != _password.text.trim()) return l10n.passwordsDontMatch;
    return null;
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null) return;

    final l10n = AppLocalizations.of(context)!;

    if ((_phone ?? '').isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.apiError('телефон не передан'))));
      return;
    }
    if (!form.validate()) return;

    setState(() => _loading = true);
    try {
      final repo = ref.read(authRepoProvider);
      await repo.setPassword(_phone!, _password.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.passwordSaved)));
      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.apiError(e.toString()))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newPasswordTitle), centerTitle: true),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                PasswordField(
                  controller: _password,
                  label: l10n.password,
                  isNewPassword: true,
                  validator: _passwordValidator,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                PasswordField(
                  controller: _confirm,
                  label: l10n.confirmPassword,
                  isNewPassword: true,
                  validator: _confirmValidator,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _save(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(l10n.confirm),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
