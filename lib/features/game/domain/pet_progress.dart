import 'period_summary.dart';

enum PetMoodLevel { quiet, calm, happy, delighted }

enum PetDevelopmentStage { little, growing, confident }

extension PetMoodLevelText on PetMoodLevel {
  String get title => switch (this) {
        PetMoodLevel.quiet => 'Немного грустит',
        PetMoodLevel.calm => 'Спокоен',
        PetMoodLevel.happy => 'Доволен',
        PetMoodLevel.delighted => 'Очень рад',
      };
}

extension PetDevelopmentStageText on PetDevelopmentStage {
  String get title => switch (this) {
        PetDevelopmentStage.little => 'Малыш',
        PetDevelopmentStage.growing => 'Подрос',
        PetDevelopmentStage.confident => 'Уверенный Финни',
      };

  String get shortReason => switch (this) {
        PetDevelopmentStage.little =>
          'Финни только учится жить по плану и копить регулярно.',
        PetDevelopmentStage.growing =>
          'Финни подрос благодаря нескольким продуманным периодам.',
        PetDevelopmentStage.confident =>
          'Финни вырос благодаря заботе, планированию и регулярным накоплениям.',
      };
}

PetMoodLevel moodLevelFor(int mood) {
  if (mood < 35) return PetMoodLevel.quiet;
  if (mood < 60) return PetMoodLevel.calm;
  if (mood < 80) return PetMoodLevel.happy;
  return PetMoodLevel.delighted;
}

class PetDevelopmentProgress {
  const PetDevelopmentProgress({
    required this.stage,
    required this.completedPeriods,
    required this.developmentPoints,
    required this.needCoveredPeriods,
    required this.savingPeriods,
  });

  final PetDevelopmentStage stage;
  final int completedPeriods;
  final int developmentPoints;
  final int needCoveredPeriods;
  final int savingPeriods;

  static PetDevelopmentProgress fromHistory(List<PeriodSummary> history) {
    var points = 0;
    var needCovered = 0;
    var savingPeriods = 0;

    for (final summary in history) {
      final coveredNeed = summary.actuals.needSpent > 0;
      final followedPlan = summary.matchedDirections >= 2;
      final saved = summary.actuals.saved > 0;

      if (coveredNeed) {
        points += 1;
        needCovered += 1;
      }
      if (followedPlan) points += 1;
      if (saved) {
        points += 1;
        savingPeriods += 1;
      }
    }

    final completed = history.length;
    final stage = completed >= 4 &&
            points >= 8 &&
            needCovered >= 3 &&
            savingPeriods >= 3
        ? PetDevelopmentStage.confident
        : completed >= 2 && points >= 3
            ? PetDevelopmentStage.growing
            : PetDevelopmentStage.little;

    return PetDevelopmentProgress(
      stage: stage,
      completedPeriods: completed,
      developmentPoints: points,
      needCoveredPeriods: needCovered,
      savingPeriods: savingPeriods,
    );
  }
}
