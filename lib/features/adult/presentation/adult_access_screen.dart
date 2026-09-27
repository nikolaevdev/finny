import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/finni_button.dart';
import '../../../core/widgets/finni_card.dart';

class AdultAccessScreen extends StatefulWidget {
  const AdultAccessScreen({super.key});

  @override
  State<AdultAccessScreen> createState() => _AdultAccessScreenState();
}

class _AdultAccessScreenState extends State<AdultAccessScreen> {
  static const _expectedAnswer = 15;

  final _answerController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _checkAnswer() {
    final answer = int.tryParse(_answerController.text.trim());
    if (answer == _expectedAnswer) {
      setState(() => _errorText = null);
      context.pushReplacement(AppRoutes.adult);
      return;
    }

    setState(() {
      _errorText = 'Проверь ответ и попробуй ещё раз.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Назад',
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Для взрослого'),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          children: [
            const Icon(
              Icons.supervisor_account_outlined,
              size: 64,
              color: AppColors.purple,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Небольшая проверка',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Этот раздел предназначен для взрослого. Решите простой пример, чтобы продолжить.',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            FinniCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '8 + 7 = ?',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: _answerController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'Введите ответ',
                      errorText: _errorText,
                    ),
                    onSubmitted: (_) => _checkAnswer(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FinniButton(
              text: 'Открыть раздел',
              icon: Icons.lock_open_rounded,
              onPressed: _checkAnswer,
            ),
          ],
        ),
      ),
    );
  }
}
