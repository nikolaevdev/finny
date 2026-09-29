import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/finni_card.dart';
import '../../../core/widgets/adventure_banner.dart';
import '../application/app_settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _setSound(
    BuildContext context,
    WidgetRef ref,
    bool value,
  ) async {
    try {
      await ref.read(appSettingsProvider.notifier).setSoundEnabled(value);
    } catch (_) {
      if (context.mounted) {
        _showMessage(context, 'Не удалось сохранить настройку.');
      }
    }
  }

  Future<void> _setAnimations(
    BuildContext context,
    WidgetRef ref,
    bool value,
  ) async {
    try {
      await ref.read(appSettingsProvider.notifier).setAnimationsEnabled(value);
    } catch (_) {
      if (context.mounted) {
        _showMessage(context, 'Не удалось сохранить настройку.');
      }
    }
  }

  Future<void> _setMusic(
    BuildContext context,
    WidgetRef ref,
    bool value,
  ) async {
    try {
      await ref.read(appSettingsProvider.notifier).setMusicEnabled(value);
    } catch (_) {
      if (context.mounted) {
        _showMessage(context, 'Не удалось сохранить настройку.');
      }
    }
  }

  void _showMessage(BuildContext context, String message) {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Назад',
          onPressed: () => context.pop(),
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
          const AdventureBanner(
            title: 'Уютная настройка',
            icon: Icons.tune_rounded,
            imageAsset: 'assets/images/shop/shop_counter_story.webp',
          ),
          const SizedBox(height: AppSpacing.md),
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
                  title: const Text('Звуки действий'),
                  subtitle: const Text(
                    'Нажатия, покупки и результаты заданий.',
                  ),
                  onChanged: (value) => _setSound(context, ref, value),
                ),
                const Divider(),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: settings.musicEnabled,
                  activeTrackColor: AppColors.purple,
                  secondary: const Icon(
                    Icons.music_note_rounded,
                    color: AppColors.purple,
                  ),
                  title: const Text('Фоновая музыка'),
                  subtitle: const Text(
                    'Спокойная мелодия во время игры.',
                  ),
                  onChanged: (value) => _setMusic(context, ref, value),
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
                  onChanged: (value) => _setAnimations(context, ref, value),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Помощь', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          FinniCard(
            onTap: () => context.push(AppRoutes.howToPlay),
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
          const FinniCard(
            color: AppColors.surfaceSecondary,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_outline_rounded, color: AppColors.purple),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Сброс и удаление профиля доступны в защищённом разделе «Для взрослого».',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
