import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/finni_button.dart';
import '../../../core/widgets/finni_card.dart';
import '../../../core/widgets/finni_preview.dart';
import '../../game/application/game_state_provider.dart';
import '../../profile/application/draft_profile_provider.dart';
import '../../profile/application/local_profile_provider.dart';

class PetCreationScreen extends ConsumerStatefulWidget {
  const PetCreationScreen({super.key});

  @override
  ConsumerState<PetCreationScreen> createState() => _PetCreationScreenState();
}

class _PetCreationScreenState extends ConsumerState<PetCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _petNameController;

  int _colorIndex = 0;
  int _earsIndex = 0;
  int _patternIndex = 0;
  bool _isSaving = false;

  static const _colors = ['Бирюзовый', 'Песочный', 'Лавандовый'];
  static const _ears = ['Заострённые', 'Округлые', 'Висячие'];
  static const _patterns = ['Без узора', 'Пятна', 'Полосы'];
  static const _colorAssets = [
    'assets/images/finni/traits/colors/turquoise.png',
    'assets/images/finni/traits/colors/sand.png',
    'assets/images/finni/traits/colors/lavender.png',
  ];
  static const _earAssets = [
    'assets/images/finni/traits/ears/pointed.png',
    'assets/images/finni/traits/ears/rounded.png',
    'assets/images/finni/traits/ears/floppy.png',
  ];
  static const _patternAssets = [
    'assets/images/finni/traits/patterns/plain.png',
    'assets/images/finni/traits/patterns/spots.png',
    'assets/images/finni/traits/patterns/stripes.png',
  ];

  @override
  void initState() {
    super.initState();
    final draft = ref.read(draftProfileProvider);
    _petNameController = TextEditingController(text: draft.petName);
    _colorIndex = draft.colorIndex;
    _earsIndex = draft.earsIndex;
    _patternIndex = draft.patternIndex;
  }

  @override
  void dispose() {
    _petNameController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (_isSaving || !(_formKey.currentState?.validate() ?? false)) return;

    ref
        .read(draftProfileProvider.notifier)
        .setPet(
          name: _petNameController.text,
          colorIndex: _colorIndex,
          earsIndex: _earsIndex,
          patternIndex: _patternIndex,
        );

    setState(() => _isSaving = true);

    try {
      final draft = ref.read(draftProfileProvider);
      await ref.read(localProfileProvider.notifier).createFromDraft(draft);
      await ref
          .read(gameStateProvider.notifier)
          .createForProfile(demoMode: draft.demoMode);

      if (!mounted) return;
      context.go(AppRoutes.home);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Не удалось сохранить профиль. Попробуй ещё раз.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
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
                    onPressed: _isSaving ? null : () => context.pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Собери своего Финни',
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Выбери внешний вид и дай питомцу игровое имя.',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                Center(
                  child: FinniPreview(
                    colorIndex: _colorIndex,
                    earsIndex: _earsIndex,
                    patternIndex: _patternIndex,
                    label: _petNameController.text.trim().isEmpty
                        ? 'Финни'
                        : _petNameController.text.trim(),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _ChoiceSection(
                  title: 'Окрас',
                  labels: _colors,
                  assetPaths: _colorAssets,
                  selected: _colorIndex,
                  onSelected: (index) {
                    setState(() => _colorIndex = index);
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                _ChoiceSection(
                  title: 'Ушки',
                  labels: _ears,
                  assetPaths: _earAssets,
                  selected: _earsIndex,
                  onSelected: (index) {
                    setState(() => _earsIndex = index);
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                _ChoiceSection(
                  title: 'Узор',
                  labels: _patterns,
                  assetPaths: _patternAssets,
                  selected: _patternIndex,
                  onSelected: (index) {
                    setState(() => _patternIndex = index);
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Имя питомца',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _petNameController,
                  enabled: !_isSaving,
                  maxLength: 16,
                  decoration: const InputDecoration(
                    hintText: 'Финни',
                    counterText: '',
                    prefixIcon: Icon(Icons.edit_outlined),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Введи имя питомца';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                const FinniCard(
                  color: AppColors.surfaceSecondary,
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: AppColors.purple),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'Окрас, форма ушей и узор сохраняются отдельно: '
                          'доступно 27 комбинаций внешности.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                FinniButton(
                  text: _isSaving ? 'Сохраняем…' : 'Готово',
                  icon: _isSaving ? null : Icons.check_rounded,
                  onPressed: _isSaving ? null : _finish,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChoiceSection extends StatelessWidget {
  const _ChoiceSection({
    required this.title,
    required this.labels,
    required this.assetPaths,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final List<String> labels;
  final List<String> assetPaths;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (var i = 0; i < labels.length; i++)
              ChoiceChip(
                avatar: ClipOval(
                  child: Image.asset(
                    assetPaths[i],
                    width: 28,
                    height: 28,
                    fit: BoxFit.cover,
                  ),
                ),
                label: Text(labels[i]),
                selected: selected == i,
                selectedColor: AppColors.purple.withValues(alpha: 0.16),
                side: BorderSide(
                  color: selected == i ? AppColors.purple : AppColors.divider,
                ),
                onSelected: (_) => onSelected(i),
              ),
          ],
        ),
      ],
    );
  }
}
