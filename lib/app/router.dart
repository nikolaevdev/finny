import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../core/audio/finni_audio.dart';
import '../features/adult/presentation/adult_access_screen.dart';
import '../features/adult/presentation/adult_screen.dart';
import '../features/budget/presentation/budget_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/pet/presentation/pet_creation_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/progress/presentation/glossary_screen.dart';
import '../features/progress/presentation/progress_screen.dart';
import '../features/period/presentation/period_summary_screen.dart';
import '../features/savings/presentation/savings_screen.dart';
import '../features/shop/presentation/shop_screen.dart';
import '../features/settings/presentation/how_to_play_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/tasks/presentation/financial_task_screen.dart';
import '../features/tasks/presentation/tasks_screen.dart';

abstract final class AppRoutes {
  static const onboarding = '/onboarding';
  static const adultAccess = '/adult-access';
  static const adult = '/adult';
  static const profile = '/profile';
  static const pet = '/pet';
  static const home = '/home';
  static const budget = '/budget';
  static const shop = '/shop';
  static const savings = '/savings';
  static const tasks = '/tasks';
  static const periodSummary = '/period-summary';
  static const progress = '/progress';
  static const glossary = '/progress/glossary';
  static const settings = '/settings';
  static const howToPlay = '/settings/how-to-play';
  static const taskDetails = '/tasks/:taskId';

  static String task(String taskId) => '/tasks/$taskId';
}

abstract final class AppRouteNames {
  static const onboarding = 'onboarding';
  static const adultAccess = 'adultAccess';
  static const adult = 'adult';
  static const profile = 'profile';
  static const pet = 'pet';
  static const home = 'home';
  static const budget = 'budget';
  static const shop = 'shop';
  static const savings = 'savings';
  static const tasks = 'tasks';
  static const periodSummary = 'periodSummary';
  static const progress = 'progress';
  static const glossary = 'glossary';
  static const settings = 'settings';
  static const howToPlay = 'howToPlay';
  static const taskDetails = 'taskDetails';
}

MusicScene musicSceneForRoute(String? routeName) {
  final route = (routeName ?? '').split('?').first;

  switch (route) {
    case AppRouteNames.shop:
    case AppRoutes.shop:
    case AppRouteNames.periodSummary:
    case AppRoutes.periodSummary:
      return MusicScene.shop;

    case AppRouteNames.budget:
    case AppRoutes.budget:
    case AppRouteNames.savings:
    case AppRoutes.savings:
    case AppRouteNames.tasks:
    case AppRoutes.tasks:
    case AppRouteNames.taskDetails:
    case AppRouteNames.progress:
    case AppRoutes.progress:
    case AppRouteNames.glossary:
    case AppRoutes.glossary:
    case AppRouteNames.settings:
    case AppRoutes.settings:
    case AppRouteNames.howToPlay:
    case AppRoutes.howToPlay:
    case AppRouteNames.adultAccess:
    case AppRoutes.adultAccess:
    case AppRouteNames.adult:
    case AppRoutes.adult:
      return MusicScene.calm;

    default:
      if (route.startsWith('/tasks/')) return MusicScene.calm;
      return MusicScene.main;
  }
}

class _MusicRouteObserver extends NavigatorObserver {
  void _sync(Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name == null) return;
    unawaited(FinniAudio.instance.setMusicScene(musicSceneForRoute(name)));
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _sync(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _sync(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _sync(newRoute);
  }
}

GoRouter createAppRouter({required bool hasLocalProfile}) {
  return GoRouter(
    initialLocation: hasLocalProfile ? AppRoutes.home : AppRoutes.onboarding,
    observers: [_MusicRouteObserver()],
    routes: [
      GoRoute(
        name: AppRouteNames.onboarding,
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        name: AppRouteNames.adultAccess,
        path: AppRoutes.adultAccess,
        builder: (context, state) => const AdultAccessScreen(),
      ),
      GoRoute(
        name: AppRouteNames.adult,
        path: AppRoutes.adult,
        builder: (context, state) => const AdultScreen(),
      ),
      GoRoute(
        name: AppRouteNames.profile,
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        name: AppRouteNames.pet,
        path: AppRoutes.pet,
        builder: (context, state) => const PetCreationScreen(),
      ),
      GoRoute(
        name: AppRouteNames.home,
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        name: AppRouteNames.budget,
        path: AppRoutes.budget,
        builder: (context, state) => const BudgetScreen(),
      ),
      GoRoute(
        name: AppRouteNames.shop,
        path: AppRoutes.shop,
        builder: (context, state) => const ShopScreen(),
      ),
      GoRoute(
        name: AppRouteNames.savings,
        path: AppRoutes.savings,
        builder: (context, state) => const SavingsScreen(),
      ),
      GoRoute(
        name: AppRouteNames.periodSummary,
        path: AppRoutes.periodSummary,
        builder: (context, state) => const PeriodSummaryScreen(),
      ),
      GoRoute(
        name: AppRouteNames.progress,
        path: AppRoutes.progress,
        builder: (context, state) => const ProgressScreen(),
      ),
      GoRoute(
        name: AppRouteNames.glossary,
        path: AppRoutes.glossary,
        builder: (context, state) => const GlossaryScreen(),
      ),
      GoRoute(
        name: AppRouteNames.settings,
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        name: AppRouteNames.howToPlay,
        path: AppRoutes.howToPlay,
        builder: (context, state) => const HowToPlayScreen(),
      ),
      GoRoute(
        name: AppRouteNames.tasks,
        path: AppRoutes.tasks,
        builder: (context, state) => const TasksScreen(),
      ),
      GoRoute(
        name: AppRouteNames.taskDetails,
        path: AppRoutes.taskDetails,
        builder: (context, state) => FinancialTaskScreen(
          taskId: state.pathParameters['taskId'] ?? '',
        ),
      ),
    ],
  );
}
