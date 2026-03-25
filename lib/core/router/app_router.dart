import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/setup_wizard_screen.dart';
import '../../features/auth/presentation/screens/pin_screen.dart';
import '../../features/products/presentation/screens/products_list_screen.dart';
import '../../features/products/presentation/screens/product_form_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // Splash
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Login
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Register
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Setup Wizard
      GoRoute(
        path: '/setup',
        builder: (context, state) => const SetupWizardScreen(),
      ),

      // PIN Screen
      GoRoute(
        path: '/pin',
        builder: (context, state) => const PinScreen(),
      ),

      // POS (Caisse principale) - TODO: Implémenter l'écran
      GoRoute(
        path: '/pos',
        builder: (context, state) => const Placeholder(), // TODO
      ),

      // Products - Liste des produits
      GoRoute(
        path: '/products',
        builder: (context, state) => const ProductsListScreen(),
      ),

      // Products - Créer un nouveau produit
      GoRoute(
        path: '/products/new',
        builder: (context, state) => const ProductFormScreen(),
      ),

      // Products - Éditer un produit
      GoRoute(
        path: '/products/:id/edit',
        builder: (context, state) {
          final itemId = state.pathParameters['id']!;
          return ProductFormScreen(itemId: itemId);
        },
      ),

      // Customers - TODO: Implémenter les écrans
      GoRoute(
        path: '/customers',
        builder: (context, state) => const Placeholder(), // TODO
      ),

      // Reports - TODO: Implémenter les écrans
      GoRoute(
        path: '/reports',
        builder: (context, state) => const Placeholder(), // TODO
      ),

      // Settings - TODO: Implémenter les écrans
      GoRoute(
        path: '/settings',
        builder: (context, state) => const Placeholder(), // TODO
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page non trouvée: ${state.uri}'),
      ),
    ),
  );
}
