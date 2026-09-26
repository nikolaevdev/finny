import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'router.dart';
import 'theme/app_theme.dart';

class FinniApp extends StatefulWidget {
  const FinniApp({
    super.key,
    this.hasLocalProfile = false,
  });

  final bool hasLocalProfile;

  @override
  State<FinniApp> createState() => _FinniAppState();
}

class _FinniAppState extends State<FinniApp> {
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
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Питомец Финни',
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}
