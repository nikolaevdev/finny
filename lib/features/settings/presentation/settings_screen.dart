import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/finni_card.dart';
import '../../game/application/game_state_provider.dart';
import '../../profile/application/draft_profile_provider.dart';
import '../../profile/application/local_profile_provider.dart';
import '../application/app_settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isWorking = false;

  Future<void> _setSound(bool value) async {
    try {
      await ref.read(appSettingsProvider.notifier).setSoundEnabled(value);
    } catch (_) {
      if (mounted) _showMessage('Не удалось сохранить настройку.');
    }
  }

  Future<void> _setAnimations(bool value) async {
    try {
      await ref.read(appSettingsProvider.notifier).setAnimationsEnabled(value);
    } catch (_) {
      if (mounted) _showMessage('Не удалось сохранить настройку.');
    }
  }

  Future<void> _resetProgress() async {
    if (_isWorking) return;
    final profile = ref.read(localProfileProvider);
    if (profile == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Сбросить игровой прогресс?'),
        content: const Text(
          'Баланс, покупки, накопления, задания, цели и история периодов вернутся к исходному состоянию. Имя и внешний вид Финни сохранятся.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isWorking = true);
    try {
      await ref
          .read(gameStateProvider.notifier)
          .resetForProfile(demoMode: profile.demoMode);
      if (mounted) {
        _showMessage('Игровой прогресс сброшен.');
      }
    } catch (_) {
      if (mounted) _showMessage('Не удалось сбросить игровой прогресс.');
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  Future<void> _deleteProfile() async {
    if (_isWorking) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить профиль и прогресс?'),
        content: const Text(
          'Будут удалены локальный профиль Финни и весь игровой прогресс на этом устройстве. Это действие нельзя отменить.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isWorking = true);
    try {
      await ref.read(gameStateProvider.notifier).deleteGameState();
      await ref.read(localProfileProvider.notifier).deleteProfile();
      ref.read(draftProfileProvider.notifier).reset();
      if (!mounted) return;
      context.go(AppRoutes.onboarding);
    } catch (_) {
      if (mounted) {
        _showMessage('Не удалось удалить локальные данные. Попробуй ещё раз.');
        setState(() => _isWorking = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Назад',
          onPressed: _isWorking ? null : () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Настройки'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          Text('Комфорт', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          FinniCard(
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: settings.soundEnabled,
                  activeTrackColor: AppColors.purple,
                  secondary: const Icon(
                    Icons.volume_up_outlined,
                    color: AppColors.purple,
                  ),
                  title: const Text('Звуки интерфейса'),
                  subtitle: const Text(
                    'Звуковая обратная связь при нажатии на элементы управления.',
                  ),
                  onChanged: _isWorking ? null : _setSound,
                ),
                const Divider(),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: settings.animationsEnabled,
                  activeTrackColor: AppColors.purple,
                  secondary: const Icon(
                    Icons.animation_rounded,
                    color: AppColors.purple,
                  ),
                  title: const Text('Анимации'),
                  subtitle: const Text(
                    'Плавные переходы между экранами приложения.',
                  ),
                  onChanged: _isWorking ? null : _setAnimations,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Помощь', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          FinniCard(
            onTap: _isWorking ? null : () => context.push(AppRoutes.howToPlay),
            child: const Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.surfaceSecondary,
                  child: Icon(Icons.help_outline_rounded, color: AppColors.purple),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Как играть',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text('Повторить короткую подсказку по игровому циклу.'),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Данные', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          FinniCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.restart_alt_rounded,
                    color: AppColors.purple,
                  ),
                  title: const Text('Сбросить игровой прогресс'),
                  subtitle: const Text(
                    'Профиль и внешний вид Финни сохранятся.',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  enabled: !_isWorking,
                  onTap: _resetProgress,
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                  ),
                  title: const Text('Удалить профиль и данные'),
                  subtitle: const Text(
                    'Удалить локальный профиль и весь прогресс с устройства.',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  enabled: !_isWorking,
                  onTap: _deleteProfile,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Все данные приложения хранятся локально на этом устройстве.',
            style: TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
