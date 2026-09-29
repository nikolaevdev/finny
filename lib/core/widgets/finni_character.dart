import 'dart:async';

import 'package:flutter/material.dart';

import '../../features/game/domain/pet_progress.dart';

/// Shared Finny artwork used throughout the app.
///
/// Each appearance and visual emotion is already composed in one sprite.
/// No facial masks, transforms or image processing run in a Flutter frame.
///
/// Character motion is intentionally code-driven: the same idle animation and
/// tap reaction work with every appearance without requiring extra sprite
/// sheets. Small catalogue previews can keep [animate] disabled to avoid
/// unnecessary work.
class FinniCharacter extends StatefulWidget {
  const FinniCharacter({
    super.key,
    required this.size,
    this.displaySizeHint,
    this.colorIndex = 0,
    this.earsIndex = 0,
    this.patternIndex = 0,
    this.developmentStage = 0,
    this.mood = 60,
    this.semanticLabel,
    this.animate = false,
    this.tapReaction = false,
  });

  final double size;
  final double? displaySizeHint;
  final int colorIndex;
  final int earsIndex;
  final int patternIndex;
  final int developmentStage;
  final int mood;
  final String? semanticLabel;

  /// Enables a subtle idle animation and smooth transitions between appearance
  /// states. It is opt-in so grids with several Finny thumbnails stay cheap.
  final bool animate;

  /// Makes Finny react with a short bounce when the character itself is tapped.
  /// The reaction also respects the platform "reduce motion" accessibility
  /// setting.
  final bool tapReaction;

  static const _stages = ['little', 'growing', 'confident'];
  static const _colors = ['turquoise', 'sand', 'lavender'];
  static const _ears = ['pointed', 'rounded', 'floppy'];
  static const _patterns = ['natural', 'spots', 'stripes'];

  static String appearanceAsset(
    int stageIndex,
    int colorIndex,
    int earsIndex,
    int patternIndex,
  ) {
    final stage = _stages[stageIndex.clamp(0, 2).toInt()];
    final color = _colors[colorIndex.clamp(0, 2).toInt()];
    final ears = _ears[earsIndex.clamp(0, 2).toInt()];
    final pattern = _patterns[patternIndex.clamp(0, 2).toInt()];
    return 'assets/images/finni/appearance/${stage}_${color}_${ears}_$pattern.webp';
  }

  static String moodSpriteAsset(
    int stageIndex,
    int colorIndex,
    int earsIndex,
    int patternIndex,
    int mood,
  ) {
    final stage = _stages[stageIndex.clamp(0, 2).toInt()];
    final color = _colors[colorIndex.clamp(0, 2).toInt()];
    final ears = _ears[earsIndex.clamp(0, 2).toInt()];
    final pattern = _patterns[patternIndex.clamp(0, 2).toInt()];
    final emotion = visualEmotionFor(moodLevelFor(mood.clamp(0, 100).toInt())).name;
    return 'assets/images/finni/mood_sprite/${stage}_${color}_${ears}_${pattern}_$emotion.webp';
  }

  static String moodAsset(int mood, int colorIndex) {
    final color = _colors[colorIndex.clamp(0, 2).toInt()];
    return 'assets/images/finni/mood_portrait/${color}_${moodLevelFor(mood.clamp(0, 100).toInt()).name}.webp';
  }

  @override
  State<FinniCharacter> createState() => _FinniCharacterState();
}

class _FinniCharacterState extends State<FinniCharacter> {
  Timer? _idleTimer;
  Timer? _reactionReturnTimer;
  Timer? _reactionFinishTimer;
  bool _idlePose = false;
  bool _reactionPeak = false;
  bool _reacting = false;

  bool get _reduceMotion =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  // Widget tests commonly use pumpAndSettle(). Do not leave an idle timer
  // running under a test binding; finite switch/tap animations are still
  // testable. Production bindings do not match this type name.
  bool get _runningInWidgetTest => WidgetsBinding.instance.runtimeType
      .toString()
      .contains('TestWidgetsFlutterBinding');

  bool get _idleEnabled =>
      widget.animate && !_reduceMotion && !_runningInWidgetTest;

  Duration get _idleTransitionDuration {
    final mood = widget.mood.clamp(0, 100);
    if (mood < 35) return const Duration(milliseconds: 2100);
    if (mood < 60) return const Duration(milliseconds: 1850);
    if (mood < 80) return const Duration(milliseconds: 1550);
    return const Duration(milliseconds: 1250);
  }

  Duration get _idlePause {
    final mood = widget.mood.clamp(0, 100);
    if (mood < 35) return const Duration(milliseconds: 2500);
    if (mood < 60) return const Duration(milliseconds: 2100);
    if (mood < 80) return const Duration(milliseconds: 1750);
    return const Duration(milliseconds: 1450);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncIdleTimer(initial: true);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncIdleTimer(initial: _idleTimer == null);
  }

  @override
  void didUpdateWidget(covariant FinniCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate || oldWidget.mood != widget.mood) {
      _idleTimer?.cancel();
      _idleTimer = null;
      if (!widget.animate && _idlePose) {
        _idlePose = false;
      }
      _syncIdleTimer(initial: true);
    }
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    _reactionReturnTimer?.cancel();
    _reactionFinishTimer?.cancel();
    super.dispose();
  }

  void _syncIdleTimer({bool initial = false}) {
    if (!mounted) return;
    if (!_idleEnabled) {
      _idleTimer?.cancel();
      _idleTimer = null;
      return;
    }
    if (_idleTimer != null) return;
    _scheduleIdle(initial: initial);
  }

  void _scheduleIdle({bool initial = false}) {
    _idleTimer?.cancel();
    _idleTimer = Timer(
      initial ? const Duration(milliseconds: 1350) : _idlePause,
      () {
        _idleTimer = null;
        if (!mounted || !_idleEnabled) return;
        if (!_reacting) {
          setState(() => _idlePose = !_idlePose);
        }
        _scheduleIdle();
      },
    );
  }

  void _reactToTap() {
    if (!widget.tapReaction || _reduceMotion || _reacting) return;

    _idleTimer?.cancel();
    _idleTimer = null;
    _reactionReturnTimer?.cancel();
    _reactionFinishTimer?.cancel();

    setState(() {
      _reacting = true;
      _reactionPeak = true;
    });

    _reactionReturnTimer = Timer(const Duration(milliseconds: 165), () {
      if (!mounted) return;
      setState(() => _reactionPeak = false);
    });

    _reactionFinishTimer = Timer(const Duration(milliseconds: 430), () {
      if (!mounted) return;
      setState(() => _reacting = false);
      _syncIdleTimer();
    });
  }

  Matrix4 _motionMatrix({
    required double translateY,
    required double rotation,
    required double scaleX,
    required double scaleY,
  }) {
    // Build the 2D T * R * S transform without the deprecated Matrix4
    // translate()/scale() convenience methods.
    final matrix = Matrix4.rotationZ(rotation);
    matrix.storage[0] *= scaleX;
    matrix.storage[1] *= scaleX;
    matrix.storage[4] *= scaleY;
    matrix.storage[5] *= scaleY;
    matrix.setTranslationRaw(0.0, translateY, 0.0);
    return matrix;
  }

  Matrix4 _motionTransform() {
    final mood = widget.mood.clamp(0, 100);

    if (_reactionPeak) {
      // A short squash-and-bounce response. The transform is intentionally
      // small enough to stay inside the character card on compact screens.
      return _motionMatrix(
        translateY: -widget.size * 0.032,
        rotation: -0.018,
        scaleX: 1.035,
        scaleY: 0.972,
      );
    }

    if (!_idlePose || !_idleEnabled) return Matrix4.identity();

    final liftRatio = mood < 35
        ? 0.0025
        : mood < 60
            ? 0.0035
            : mood < 80
                ? 0.0050
                : 0.0065;
    final rotation = mood < 60
        ? 0.003
        : mood < 80
            ? 0.005
            : 0.008;
    final breatheX = mood < 60 ? 0.997 : 0.995;
    final breatheY = mood < 60 ? 1.004 : 1.006;

    return _motionMatrix(
      translateY: -widget.size * liftRatio,
      rotation: rotation,
      scaleX: breatheX,
      scaleY: breatheY,
    );
  }

  @override
  Widget build(BuildContext context) {
    final stage = widget.developmentStage.clamp(0, 2).toInt();
    final ears = widget.earsIndex.clamp(0, 2).toInt();
    final pattern = widget.patternIndex.clamp(0, 2).toInt();
    final color = widget.colorIndex.clamp(0, 2).toInt();
    final safeMood = widget.mood.clamp(0, 100).toInt();
    final decodedWidth = ((widget.displaySizeHint ?? widget.size) *
            MediaQuery.devicePixelRatioOf(context))
        .ceil()
        .clamp(160, 1024)
        .toInt();

    Widget sprite(
      String source, {
      FilterQuality filterQuality = FilterQuality.medium,
      int? cacheWidth,
    }) =>
        Image.asset(
          source,
          fit: BoxFit.fill,
          filterQuality: filterQuality,
          cacheWidth: cacheWidth ?? decodedWidth,
          gaplessPlayback: true,
        );

    final artwork = RepaintBoundary(
      child: SizedBox.square(
        dimension: widget.size,
        child: ExcludeSemantics(
          child: sprite(
            FinniCharacter.moodSpriteAsset(
              stage, color, ears, pattern, safeMood,
            ),
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );

    final motionAllowed = !_reduceMotion;
    Widget character = AnimatedContainer(
      duration: _reacting
          ? const Duration(milliseconds: 175)
          : _idleTransitionDuration,
      curve: _reacting ? Curves.easeOutBack : Curves.easeInOutSine,
      transformAlignment: Alignment.bottomCenter,
      transform: motionAllowed ? _motionTransform() : Matrix4.identity(),
      child: artwork,
    );

    if (widget.tapReaction) {
      character = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _reactToTap,
        child: character,
      );
    }

    return Semantics(
      label: widget.semanticLabel,
      image: true,
      button: widget.tapReaction ? true : null,
      onTap: widget.tapReaction ? _reactToTap : null,
      child: character,
    );
  }
}
