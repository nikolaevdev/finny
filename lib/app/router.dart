import 'package:go_router/go_router.dart';

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
import '../features/tasks/presentation/financial_task_screen.dart';
import '../features/tasks/presentation/tasks_screen.dart';

abstract final class AppRoutes {
  static const onboarding = '/onboarding';
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
  static const taskDetails = '/tasks/:taskId';

  static String task(String taskId) => '/tasks/$taskId';
}

GoRouter createAppRouter({required bool hasLocalProfile}) {
  return GoRouter(
    initialLocation:
        hasLocalProfile ? AppRoutes.home : AppRoutes.onboarding,
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.pet,
        builder: (context, state) => const PetCreationScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.budget,
        builder: (context, state) => const BudgetScreen(),
      ),
      GoRoute(
        path: AppRoutes.shop,
        builder: (context, state) => const ShopScreen(),
      ),
      GoRoute(
        path: AppRoutes.savings,
        builder: (context, state) => const SavingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.periodSummary,
        builder: (context, state) => const PeriodSummaryScreen(),
      ),
      GoRoute(
        path: AppRoutes.progress,
        builder: (context, state) => const ProgressScreen(),
      ),
      GoRoute(
        path: AppRoutes.glossary,
        builder: (context, state) => const GlossaryScreen(),
      ),
      GoRoute(
        path: AppRoutes.tasks,
        builder: (context, state) => const TasksScreen(),
      ),
      GoRoute(
        path: AppRoutes.taskDetails,
        builder: (context, state) => FinancialTaskScreen(
          taskId: state.pathParameters['taskId'] ?? '',
        ),
      ),
    ],
  );
}
