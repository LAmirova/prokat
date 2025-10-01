// lib/app/main_layout.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prokat_app/app/providers.dart';

class MainLayout extends ConsumerStatefulWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout>
    with TickerProviderStateMixin {
  int _currentIndex = 0;

  // анимация «пружинка» для центральной кнопки
  late final AnimationController _addCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 140),
    lowerBound: 0.0,
    upperBound: 0.08,
  );

  @override
  void dispose() {
    _addCtrl.dispose();
    super.dispose();
  }

  Future<bool> _ensureAuth({String? intentLabel}) async {
    // true -> пользователь авторизован
    final loggedIn = await ref.read(authRepoProvider).isLoggedIn();
    if (loggedIn) return true;

    if (!mounted) return false;

    // Показать современный bottom sheet с предложением войти/зарегистрироваться
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: false,
      backgroundColor: Colors.white.withOpacity(0.92),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 40, color: Colors.black54),
              const SizedBox(height: 8),
              Text(
                'Войдите, чтобы продолжить',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                intentLabel == null
                    ? 'Авторизация откроет доступ к профилю и личным данным.'
                    : 'Для действия «$intentLabel» нужна авторизация.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        if (mounted) context.push('/register');
                      },
                      child: const Text('Зарегистрироваться'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        if (mounted) context.push('/login');
                      },
                      child: const Text('Войти'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Отмена'),
              ),
            ],
          ),
        );
      },
    );

    return false;
  }

  Future<void> _onTab(int index) async {
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        context.go('/listings'); // Поиск
        break;
      case 1:
        // Избранное часто приватное — по желанию включи проверку:
        // if (!await _ensureAuth(intentLabel: 'Избранное')) return;
        context.go('/favorites');
        break;
      case 2:
        // Добавить объявление — обычно тоже доступно только авторизованным
        if (!await _ensureAuth(intentLabel: 'Добавить объявление')) return;
        context.push('/listings/create');
        break;
      case 3:
        // Сообщения — скорее всего приватно
        if (!await _ensureAuth(intentLabel: 'Сообщения')) return;
        context.go('/messages');
        break;
      case 4:
        // Профиль — точно приватно
        if (!await _ensureAuth(intentLabel: 'Профиль')) return;
        context.go('/account');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF6A5AE0);

    return Scaffold(
      body: widget.child,

      // Фрост-панель навигации с блюром, тенью и «плюсом» по центру
      bottomNavigationBar: Material(
        elevation: 12,
        shadowColor: Colors.black26,
        color: Colors.transparent,
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                border: Border(
                  top: BorderSide(color: Colors.black12.withOpacity(0.06)),
                ),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 72,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _NavItem(
                        label: "Поиск",
                        icon: Icons.search,
                        selected: _currentIndex == 0,
                        onTap: () => _onTab(0),
                      ),
                      _NavItem(
                        label: "Избранное",
                        icon: Icons.favorite_border,
                        selected: _currentIndex == 1,
                        onTap: () => _onTab(1),
                      ),

                      // Центральный "+" с анимацией
                      _AddItem(
                        selected: _currentIndex == 2,
                        onTap: () => _onTab(2),
                        controller: _addCtrl,
                      ),

                      _NavItem(
                        label: "Сообщения",
                        icon: Icons.chat_bubble_outline,
                        selected: _currentIndex == 3,
                        onTap: () => _onTab(3),
                      ),
                      _NavItem(
                        label: "Профиль",
                        icon: Icons.person_outline,
                        selected: _currentIndex == 4,
                        onTap: () => _onTab(4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = const Color(0xFF6A5AE0);
    final color = selected ? active : Colors.grey;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 170),
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddItem extends StatefulWidget {
  final bool selected;
  final VoidCallback onTap;
  final AnimationController controller;

  const _AddItem({
    required this.selected,
    required this.onTap,
    required this.controller,
  });

  @override
  State<_AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<_AddItem> {
  bool _pressed = false;

  void _pressDown() {
    setState(() => _pressed = true);
    widget.controller.forward();
  }

  void _pressUp() async {
    await widget.controller.reverse();
    if (mounted) {
      setState(() => _pressed = false);
      widget.onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF6A5AE0);

    return GestureDetector(
      onTapDown: (_) => _pressDown(),
      onTapCancel: () => widget.controller.reverse().then((_) {
        if (mounted) setState(() => _pressed = false);
      }),
      onTapUp: (_) => _pressUp(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: 1 - widget.controller.value,
              duration: const Duration(milliseconds: 100),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                  boxShadow: _pressed
                      ? [
                          BoxShadow(
                            color: accent.withOpacity(0.35),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ]
                      : [
                          const BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 26),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 170),
              style: TextStyle(
                color: widget.selected ? accent : Colors.grey,
                fontSize: 0,
                fontWeight: FontWeight.w700,
              ),
              child: const Text("Добавить"),
            ),
          ],
        ),
      ),
    );
  }
}
