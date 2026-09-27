import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/settings/application/app_settings_provider.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class FinniApp extends ConsumerStatefulWidget {
  const FinniApp({super.key, this.hasLocalProfile = false});

  final bool hasLocalProfile;

  @override
  ConsumerState<FinniApp> createState() => _FinniAppState();
}

class _FinniAppState extends ConsumerState<FinniApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createAppRouter(hasLocalProfile: widget.hasLocalProfile);
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Питомец Финни',
      theme: AppTheme.light(
        soundEnabled: settings.soundEnabled,
        animationsEnabled: settings.animationsEnabled,
      ),
      routerConfig: _router,
    );
  }
}
