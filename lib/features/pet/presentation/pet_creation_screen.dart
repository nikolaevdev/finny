import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/finni_button.dart';
import '../../../core/widgets/finni_preview.dart';
import '../../../core/widgets/finni_character.dart';
import '../../../core/widgets/finni_pressable.dart';
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
  static const _patterns = ['Природный', 'Пятна', 'Полосы'];

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

    ref.read(draftProfileProvider.notifier).setPet(
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
            content: Text(
              'Не удалось сохранить профиль. Попробуй ещё раз.',
            ),
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
                  'Твой спутник',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Выбери окрас, форму ушек и узор, затем дай Финни имя.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: FinniPreview(
                    size: 240,
                    animate: true,
                    colorIndex: _colorIndex,
                    earsIndex: _earsIndex,
                    patternIndex: _patternIndex,
                    label: _petNameController.text.trim().isEmpty
                        ? 'Финни'
                        : _petNameController.text.trim(),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _ChoiceSection(
                  title: 'Окрас',
                  labels: _colors,
                  trait: _Trait.color,
                  colorIndex: _colorIndex,
                  earsIndex: _earsIndex,
                  patternIndex: _patternIndex,
                  selected: _colorIndex,
                  onSelected: (index) {
                    setState(() => _colorIndex = index);
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                _ChoiceSection(
                  title: 'Ушки',
                  labels: _ears,
                  trait: _Trait.ears,
                  colorIndex: _colorIndex,
                  earsIndex: _earsIndex,
                  patternIndex: _patternIndex,
                  selected: _earsIndex,
                  onSelected: (index) {
                    setState(() => _earsIndex = index);
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                _ChoiceSection(
                  title: 'Узор',
                  labels: _patterns,
                  trait: _Trait.pattern,
                  colorIndex: _colorIndex,
                  earsIndex: _earsIndex,
                  patternIndex: _patternIndex,
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

enum _Trait { color, ears, pattern }

class _ChoiceSection extends StatelessWidget {
  const _ChoiceSection({
    required this.title,
    required this.labels,
    required this.trait,
    required this.colorIndex,
    required this.earsIndex,
    required this.patternIndex,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final List<String> labels;
  final _Trait trait;
  final int colorIndex;
  final int earsIndex;
  final int patternIndex;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            for (var i = 0; i < labels.length; i++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i == labels.length - 1 ? 0 : 8),
                  child: FinniPressable(
                    effect: FinniPressEffect.card,
                    borderRadius: BorderRadius.circular(20),
                    glowColor: selected == i ? AppColors.purple : null,
                    child: InkWell(
                      onTap: () => onSelected(i),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                      padding: const EdgeInsets.fromLTRB(5, 6, 5, 8),
                      decoration: BoxDecoration(
                        color: selected == i
                            ? AppColors.purple.withValues(alpha: 0.14)
                            : AppColors.surface.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected == i ? AppColors.purple : AppColors.divider,
                          width: selected == i ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 72,
                            width: double.infinity,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: FinniCharacter(
                                size: 92,
                                colorIndex: trait == _Trait.color ? i : colorIndex,
                                earsIndex: trait == _Trait.ears ? i : earsIndex,
                                patternIndex: trait == _Trait.pattern ? i : patternIndex,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            labels[i],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
