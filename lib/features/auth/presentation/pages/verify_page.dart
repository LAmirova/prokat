import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:prokat_app/app/providers.dart'; // authRepoProvider
import 'package:prokat_app/core/l10n/l10n.dart';

class VerifyPage extends ConsumerStatefulWidget {
  const VerifyPage({super.key});

  @override
  ConsumerState<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends ConsumerState<VerifyPage> {
  String _code = '';
  String? _phone; // из extra
  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra;
    if (extra is String) _phone ??= extra;
  }

  Future<void> _verify() async {
    final l10n = AppLocalizations.of(context);

    if ((_phone ?? '').isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.apiError('телефон не передан'))));
      return;
    }
    if (_code.length != 6) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.enter6Digits)));
      return;
    }

    setState(() => _loading = true);
    try {
      final repo = ref.read(authRepoProvider);
      await repo.verify(_phone!, _code);
      if (!mounted) return;
      // Успех: переходим к установке пароля
      context.push('/set-password', extra: _phone);
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
    final l10n = AppLocalizations.of(context);
    final phoneShown = _phone ?? '—';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.verifyTitle), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Text(l10n.weSentCodeTo, textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Text(
                phoneShown,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              PinCodeTextField(
                appContext: context,
                length: 6,
                onChanged: (v) => _code = v,
                autoFocus: true,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.underline,
                  fieldHeight: 48,
                  fieldWidth: 40,
                  inactiveColor: Colors.grey.shade400,
                  selectedColor: Theme.of(context).primaryColor,
                  activeColor: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _verify,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(l10n.confirm,
                          style: const TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
