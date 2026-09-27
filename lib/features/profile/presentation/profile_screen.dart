import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/finni_button.dart';
import '../../../core/widgets/finni_card.dart';
import '../application/draft_profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  bool _demoMode = false;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(draftProfileProvider);
    _nameController = TextEditingController(text: draft.playerName);
    _demoMode = draft.demoMode;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _continue() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    ref
        .read(draftProfileProvider.notifier)
        .setPlayer(name: _nameController.text, demoMode: _demoMode);

    context.push(AppRoutes.pet);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton.filledTonal(
                    tooltip: 'Назад',
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Давай познакомимся',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Для игрового профиля достаточно имени. '
                  'Телефон, e-mail и регистрация не нужны.',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Твоё игровое имя',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _nameController,
                  maxLength: 20,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    hintText: 'Например, Миша',
                    counterText: '',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Введи игровое имя';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _continue(),
                ),
                const SizedBox(height: AppSpacing.lg),
                FinniCard(
                  color: AppColors.surfaceSecondary,
                  child: SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: _demoMode,
                    activeTrackColor: AppColors.purple,
                    title: const Text(
                      'Демо-профиль',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text(
                      'Заготовка для быстрого прохождения '
                      'экспертного сценария.',
                    ),
                    secondary: const Icon(
                      Icons.science_outlined,
                      color: AppColors.purple,
                    ),
                    onChanged: (value) {
                      setState(() => _demoMode = value);
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Профиль и выбранный Финни сохраняются локально '
                        'только на этом устройстве.',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
                FinniButton(
                  text: 'Продолжить',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: _continue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
