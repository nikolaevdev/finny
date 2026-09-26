import 'package:go_router/go_router.dart';

import '../features/budget/presentation/budget_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/pet/presentation/pet_creation_screen.dart';
import '../features/profile/presentation/profile_screen.dart';

abstract final class AppRoutes {
  static const onboarding = '/onboarding';
  static const profile = '/profile';
  static const pet = '/pet';
  static const home = '/home';
  static const budget = '/budget';
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
    ],
  );
}
