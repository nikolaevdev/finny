import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class FinniPreview extends StatelessWidget {
  const FinniPreview({
    super.key,
    this.size = 170,
    this.label = 'Финни',
    this.colorIndex = 0,
    this.earsIndex = 0,
    this.patternIndex = 0,
    this.mood = 60,
    this.developmentStage = 0,
  });

  final double size;
  final String label;
  final int colorIndex;
  final int earsIndex;
  final int patternIndex;
  final int mood;
  final int developmentStage;

  static const _assetRoot = 'assets/images/finni';

  int get _safeColorIndex => colorIndex.clamp(0, 2).toInt();
  int get _safeEarsIndex => earsIndex.clamp(0, 2).toInt();
  int get _safePatternIndex => patternIndex.clamp(0, 2).toInt();
  int get _safeStage => developmentStage.clamp(0, 2).toInt();

  String get _colorName => switch (_safeColorIndex) {
    1 => 'sand',
    2 => 'lavender',
    _ => 'turquoise',
  };

  String get _stageName => switch (_safeStage) {
    1 => 'growing',
    2 => 'confident',
    _ => 'little',
  };

  String get _stageAsset => '$_assetRoot/stage/${_stageName}_$_colorName.png';

  String get _earAsset => switch (_safeEarsIndex) {
    1 => '$_assetRoot/traits/ears/rounded.png',
    2 => '$_assetRoot/traits/ears/floppy.png',
    _ => '$_assetRoot/traits/ears/pointed.png',
  };

  String get _patternAsset => switch (_safePatternIndex) {
    1 => '$_assetRoot/traits/patterns/spots.png',
    2 => '$_assetRoot/traits/patterns/stripes.png',
    _ => '$_assetRoot/traits/patterns/plain.png',
  };

  String get _moodAsset {
    if (mood < 35) return '$_assetRoot/mood/quiet.png';
    if (mood < 60) return '$_assetRoot/mood/calm.png';
    if (mood < 80) return '$_assetRoot/mood/happy.png';
    return '$_assetRoot/mood/delighted.png';
  }

  String get _colorLabel => switch (_safeColorIndex) {
    1 => 'песочный',
    2 => 'лавандовый',
    _ => 'бирюзовый',
  };

  String get _earsLabel => switch (_safeEarsIndex) {
    1 => 'округлые',
    2 => 'висячие',
    _ => 'заострённые',
  };

  String get _patternLabel => switch (_safePatternIndex) {
    1 => 'пятна',
    2 => 'полосы',
    _ => 'без дополнительного узора',
  };

  String get _stageLabel => switch (_safeStage) {
    1 => 'Подрос',
    2 => 'Взрослый',
    _ => 'Малыш',
  };

  Color get _accent => switch (_safeColorIndex) {
    1 => AppColors.save,
    2 => AppColors.purple,
    _ => AppColors.need,
  };

  @override
  Widget build(BuildContext context) {
    final badgeSize = size * 0.235;

    return Semantics(
      label:
          'Виртуальный питомец $label, $_colorLabel окрас, $_earsLabel уши, '
          'узор: $_patternLabel, стадия развития ${_safeStage + 1}, '
          'настроение $mood из 100',
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _accent.withValues(alpha: 0.22),
                    AppColors.purple.withValues(alpha: 0.12),
                  ],
                ),
                border: Border.all(
                  color: _accent.withValues(alpha: 0.36),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: EdgeInsets.all(size * 0.065),
              child: ClipOval(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      _stageAsset,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                    ),
                    if (_safePatternIndex != 0)
                      IgnorePointer(
                        child: CustomPaint(
                          painter: _FinniPatternPainter(
                            patternIndex: _safePatternIndex,
                            accent: _accent,
                          ),
                        ),
                      ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        margin: EdgeInsets.only(bottom: size * 0.045),
                        padding: EdgeInsets.symmetric(
                          horizontal: size * 0.075,
                          vertical: size * 0.018,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: AppColors.surface.withValues(alpha: 0.75),
                          ),
                        ),
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -size * 0.02,
              left: -size * 0.015,
              child: _ImageBadge(
                asset: _earAsset,
                semanticLabel: '$_earsLabel уши',
                size: badgeSize,
                borderColor: _accent,
              ),
            ),
            Positioned(
              top: -size * 0.02,
              right: -size * 0.015,
              child: _ImageBadge(
                asset: _patternAsset,
                semanticLabel: 'Узор: $_patternLabel',
                size: badgeSize,
                borderColor: _accent,
              ),
            ),
            Positioned(
              bottom: -size * 0.015,
              left: -size * 0.015,
              child: _ImageBadge(
                asset: _moodAsset,
                semanticLabel: 'Настроение $mood из 100',
                size: badgeSize,
                borderColor: _accent,
              ),
            ),
            Positioned(
              bottom: size * 0.005,
              right: size * 0.01,
              child: Container(
                constraints: BoxConstraints(minWidth: size * 0.20),
                padding: EdgeInsets.symmetric(
                  horizontal: size * 0.05,
                  vertical: size * 0.024,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: _accent.withValues(alpha: 0.38)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textPrimary.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  _stageLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: size * 0.065,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageBadge extends StatelessWidget {
  const _ImageBadge({
    required this.asset,
    required this.semanticLabel,
    required this.size,
    required this.borderColor,
  });

  final String asset;
  final String semanticLabel;
  final double size;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.10),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            asset,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
          ),
        ),
      ),
    );
  }
}

class _FinniPatternPainter extends CustomPainter {
  const _FinniPatternPainter({
    required this.patternIndex,
    required this.accent,
  });

  final int patternIndex;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accent.withValues(alpha: 0.30)
      ..style = PaintingStyle.fill;

    if (patternIndex == 1) {
      final spots = <Offset>[
        Offset(size.width * 0.60, size.height * 0.55),
        Offset(size.width * 0.69, size.height * 0.62),
        Offset(size.width * 0.57, size.height * 0.70),
        Offset(size.width * 0.76, size.height * 0.72),
      ];
      for (final spot in spots) {
        canvas.drawOval(
          Rect.fromCenter(
            center: spot,
            width: size.width * 0.075,
            height: size.height * 0.05,
          ),
          paint,
        );
      }
      return;
    }

    if (patternIndex == 2) {
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.022
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < 3; i++) {
        final y = size.height * (0.56 + i * 0.075);
        final path = Path()
          ..moveTo(size.width * 0.55, y)
          ..quadraticBezierTo(
            size.width * 0.67,
            y - size.height * 0.035,
            size.width * 0.80,
            y,
          );
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FinniPatternPainter oldDelegate) {
    return oldDelegate.patternIndex != patternIndex ||
        oldDelegate.accent != accent;
  }
}
