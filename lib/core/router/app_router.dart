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
import '../../features/auth/presentation/screens/pin_setup_screen.dart';
import '../../features/auth/presentation/screens/pin_screen.dart';
import '../../features/products/presentation/screens/products_list_screen.dart';
import '../../features/products/presentation/screens/product_form_screen.dart';
import '../../features/products/presentation/screens/inventory_overview_screen.dart';
import '../../features/products/presentation/screens/import_items_screen.dart';
import '../../features/pos/presentation/screens/pos_screen.dart';
import '../../features/customers/presentation/screens/customer_list_screen.dart';
import '../../features/customers/presentation/screens/customer_form_screen.dart';
import '../../features/customers/presentation/screens/customer_detail_screen.dart';
import '../../features/customers/presentation/screens/credit_list_screen.dart';
import '../../features/store/presentation/screens/payment_settings_screen.dart';
import '../../features/pos/presentation/screens/sales_history_screen.dart';
import '../../features/pos/presentation/screens/receipt_detail_screen.dart';
import '../../features/pos/presentation/screens/refund_screen.dart';
import '../../features/inventory/presentation/screens/stock_adjustment_screen.dart';
import '../../features/inventory/presentation/screens/adjustment_list_screen.dart';
import '../../features/inventory/presentation/screens/inventory_counts_screen.dart';
import '../../features/inventory/presentation/screens/new_inventory_count_screen.dart';
import '../../features/inventory/presentation/screens/inventory_counting_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import 'main_shell.dart';

// Clés de navigation pour chaque branche
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _posNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'pos');
final _productsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'products');
final _customersNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'customers');
final _reportsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'reports');
final _settingsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'settings');

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
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

      // Magasin créé → autoriser pin-setup
      if (authState is AuthStoreCreated) {
        if (currentPath == '/pin-setup') return null;
        return '/pin-setup';
      }

      // Authentifié avec magasin mais pas de session PIN → pin ou pin-setup
      if (authState is AuthAuthenticatedWithStore ||
          authState is AuthStoreEmployeesLoaded) {
        if (currentPath == '/pin' || currentPath == '/pin-setup') return null;
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
      // ── Routes publiques (sans bottom nav) ──────────────────────────
      GoRoute(
        path: '/splash',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/setup',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SetupWizardScreen(),
      ),
      GoRoute(
        path: '/pin-setup',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PinSetupScreen(),
      ),
      GoRoute(
        path: '/pin',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PinScreen(),
      ),

      // ── Shell principal avec Bottom Navigation ──────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          // ── Branche 1 : Caisse (POS) ──
          StatefulShellBranch(
            navigatorKey: _posNavigatorKey,
            routes: [
              GoRoute(
                path: '/pos',
                builder: (context, state) => const PosScreen(),
                routes: [
                  GoRoute(
                    path: 'receipts',
                    builder: (context, state) => const SalesHistoryScreen(),
                    routes: [
                      GoRoute(
                        path: ':id',
                        builder: (context, state) {
                          final receiptId = state.pathParameters['id']!;
                          return ReceiptDetailScreen(receiptId: receiptId);
                        },
                        routes: [
                          GoRoute(
                            path: 'refund',
                            builder: (context, state) {
                              final receiptId = state.pathParameters['id']!;
                              return RefundScreen(receiptId: receiptId);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // ── Branche 2 : Produits ──
          StatefulShellBranch(
            navigatorKey: _productsNavigatorKey,
            routes: [
              GoRoute(
                path: '/products',
                builder: (context, state) => const ProductsListScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => const ProductFormScreen(),
                  ),
                  GoRoute(
                    path: 'import',
                    builder: (context, state) => const ImportItemsScreen(),
                  ),
                  GoRoute(
                    path: ':id/edit',
                    builder: (context, state) {
                      final itemId = state.pathParameters['id']!;
                      return ProductFormScreen(itemId: itemId);
                    },
                  ),
                ],
              ),
              // Inventory sous-section (accessible via Produits)
              GoRoute(
                path: '/inventory',
                builder: (context, state) => const InventoryOverviewScreen(),
                routes: [
                  GoRoute(
                    path: 'adjustments',
                    builder: (context, state) => const AdjustmentListScreen(),
                    routes: [
                      GoRoute(
                        path: 'new',
                        builder: (context, state) =>
                            const StockAdjustmentScreen(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'counts',
                    builder: (context, state) =>
                        const InventoryCountsScreen(),
                    routes: [
                      GoRoute(
                        path: 'new',
                        builder: (context, state) =>
                            const NewInventoryCountScreen(),
                      ),
                      GoRoute(
                        path: ':id',
                        builder: (context, state) {
                          final countId = state.pathParameters['id']!;
                          return InventoryCountingScreen(countId: countId);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // ── Branche 3 : Clients ──
          StatefulShellBranch(
            navigatorKey: _customersNavigatorKey,
            routes: [
              GoRoute(
                path: '/customers',
                builder: (context, state) => const CustomerListScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => const CustomerFormScreen(),
                  ),
                  GoRoute(
                    path: 'credits',
                    builder: (context, state) => const CreditListScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final customerId = state.pathParameters['id']!;
                      return CustomerDetailScreen(customerId: customerId);
                    },
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) {
                          final customerId = state.pathParameters['id']!;
                          return CustomerFormScreen(customerId: customerId);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // ── Branche 4 : Rapports (placeholder) ──
          StatefulShellBranch(
            navigatorKey: _reportsNavigatorKey,
            routes: [
              GoRoute(
                path: '/reports',
                builder: (context, state) => const _ReportsPlaceholder(),
              ),
            ],
          ),

          // ── Branche 5 : Réglages ──
          StatefulShellBranch(
            navigatorKey: _settingsNavigatorKey,
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'payment-types',
                    builder: (context, state) =>
                        const PaymentSettingsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
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

/// Placeholder pour les Rapports (Sprint 5)
class _ReportsPlaceholder extends StatelessWidget {
  const _ReportsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapports'),
      ),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Les rapports arrivent bientôt',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}