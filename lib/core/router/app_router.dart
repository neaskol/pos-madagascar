import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/setup_wizard_screen.dart';
import '../../features/auth/presentation/screens/pin_screen.dart';
import '../../features/products/presentation/screens/products_list_screen.dart';
import '../../features/products/presentation/screens/product_form_screen.dart';
import '../../features/pos/presentation/screens/pos_screen.dart';
import '../../features/customers/presentation/screens/customer_list_screen.dart';
import '../../features/customers/presentation/screens/customer_form_screen.dart';
import '../../features/customers/presentation/screens/customer_detail_screen.dart';
import '../../features/store/presentation/screens/payment_settings_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',

    // Route guards — redirige selon l'état d'authentification
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
      final currentPath = state.matchedLocation;

      // Routes publiques (pas de guard nécessaire)
      const publicRoutes = [
        '/splash',
        '/onboarding',
        '/login',
        '/register',
        '/forgot-password',
      ];
      if (publicRoutes.contains(currentPath)) return null;

      // Si l'état est initial ou en chargement, laisser passer (splash gère)
      if (authState is AuthInitial || authState is AuthLoading) return null;

      // Non authentifié → login
      if (authState is AuthUnauthenticated) return '/login';

      // Authentifié sans magasin → setup
      if (authState is AuthAuthenticatedNoStore) {
        if (currentPath == '/setup') return null;
        return '/setup';
      }

      // Authentifié avec magasin mais pas de session PIN → pin
      if (authState is AuthAuthenticatedWithStore ||
          authState is AuthStoreEmployeesLoaded) {
        if (currentPath == '/pin') return null;
        return '/pin';
      }

      // Session PIN active → accès complet
      if (authState is AuthPinSessionActive) {
        if (currentPath == '/pin') return '/pos';
        return null;
      }

      return null;
    },

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

      // Forgot Password
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
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

      // POS (Caisse principale)
      GoRoute(
        path: '/pos',
        builder: (context, state) => const PosScreen(),
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

      // Customers - Liste des clients
      GoRoute(
        path: '/customers',
        builder: (context, state) => const CustomerListScreen(),
      ),

      // Customers - Nouveau client
      GoRoute(
        path: '/customers/new',
        builder: (context, state) => const CustomerFormScreen(),
      ),

      // Customers - Détail client
      GoRoute(
        path: '/customers/:id',
        builder: (context, state) {
          final customerId = state.pathParameters['id']!;
          return CustomerDetailScreen(customerId: customerId);
        },
      ),

      // Customers - Éditer client
      GoRoute(
        path: '/customers/:id/edit',
        builder: (context, state) {
          final customerId = state.pathParameters['id']!;
          return CustomerFormScreen(customerId: customerId);
        },
      ),

      // Reports - TODO: Sprint 5
      GoRoute(
        path: '/reports',
        builder: (context, state) => const Placeholder(),
      ),

      // Settings - Payment Types (Mobile Money)
      GoRoute(
        path: '/settings/payment-types',
        builder: (context, state) => const PaymentSettingsScreen(),
      ),

      // Settings - TODO: Sprint 6
      GoRoute(
        path: '/settings',
        builder: (context, state) => const Placeholder(),
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
