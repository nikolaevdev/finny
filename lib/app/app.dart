import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../features/settings/application/app_settings_provider.dart';
import 'router.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import '../core/audio/finni_audio.dart';

class FinniApp extends ConsumerStatefulWidget {
  const FinniApp({
    super.key,
    this.hasLocalProfile = false,
    this.prewarmStoryAssets = true,
  });

  final bool hasLocalProfile;

  /// Disable only when testing startup routing without image decoding.
  final bool prewarmStoryAssets;

  @override
  ConsumerState<FinniApp> createState() => _FinniAppState();
}

class _FinniAppState extends ConsumerState<FinniApp> {
  late final GoRouter _router;
  bool _storyWarmupStarted = false;
  bool _storyAssetsReady = false;

  static const _storyAssets = <AssetImage>[
    AssetImage('assets/images/home/explorer_room_story.webp'),
    AssetImage('assets/images/shop/shop_counter_story.webp'),
    AssetImage('assets/images/goals/dream_cottage_story.webp'),
  ];

  @override
  void initState() {
    super.initState();
    _router = createAppRouter(hasLocalProfile: widget.hasLocalProfile);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_storyWarmupStarted) return;
    _storyWarmupStarted = true;
    if (!widget.prewarmStoryAssets) {
      _storyAssetsReady = true;
      return;
    }
    unawaited(_warmStoryAssets());
  }

  Future<void> _warmStoryAssets() async {
    try {
      await Future.wait(
        _storyAssets.map((image) => precacheImage(image, context)),
      );
    } catch (_) {
      // Do not block app startup if an image cannot be warmed. The normal
      // ImageProvider error path will still handle it on the target screen.
    } finally {
      if (mounted) {
        setState(() => _storyAssetsReady = true);
      }
    }
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(FinniAudio.instance.configure(
          effectsEnabled: settings.soundEnabled,
          musicEnabled: settings.musicEnabled,
        ));
      }
    });

    final theme = AppTheme.light(
      soundEnabled: settings.soundEnabled,
      animationsEnabled: settings.animationsEnabled,
    );

    if (!_storyAssetsReady) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Питомец Финни',
        theme: theme,
        home: const _StoryWarmupScreen(),
      );
    }

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Питомец Финни',
      theme: theme,
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Stack(
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/home/explorer_room_story.webp'),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.80),
                ),
                child: child ?? const SizedBox.shrink(),
              ),
            ),
            const _SystemStatusScrim(),
          ],
        ),
      ),
      routerConfig: _router,
    );
  }
}


class _StoryWarmupScreen extends StatelessWidget {
  const _StoryWarmupScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.pets_rounded,
              size: 42,
              color: AppColors.purple,
            ),
            const SizedBox(height: 10),
            Text(
              'Финни',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}


class _SystemStatusScrim extends StatelessWidget {
  const _SystemStatusScrim();

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    if (topInset <= 0) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          height: topInset + 16,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.82),
                Colors.white.withValues(alpha: 0.34),
                Colors.white.withValues(alpha: 0.0),
              ],
              stops: const [0, 0.56, 1],
            ),
          ),
        ),
      ),
    );
  }
}
