import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'core/theme/app_theme.dart';
import 'core/data/remote/supabase_client.dart';
import 'core/data/remote/sync_service.dart';
import 'core/data/local/app_database.dart';
import 'core/router/app_router.dart';
import 'core/services/storage_service.dart';
import 'dart:developer' as developer;
import 'l10n/app_localizations.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/products/data/repositories/category_repository.dart';
import 'features/products/data/repositories/item_repository.dart';
import 'features/products/data/repositories/item_import_repository.dart';
import 'features/products/presentation/bloc/category_bloc.dart';
import 'features/products/presentation/bloc/item_bloc.dart';
import 'features/products/presentation/bloc/item_import_bloc.dart';
import 'features/pos/data/repositories/sale_repository.dart';
import 'features/pos/data/repositories/refund_repository.dart';
import 'features/pos/data/repositories/custom_page_repository_impl.dart';
import 'features/pos/presentation/bloc/sale_bloc.dart';
import 'features/pos/presentation/bloc/refund_bloc.dart';
import 'features/pos/presentation/bloc/custom_page_bloc.dart';
import 'features/pos/presentation/bloc/custom_page_event.dart';
import 'features/customers/data/repositories/customer_repository.dart';
import 'features/customers/data/repositories/credit_repository.dart';
import 'features/customers/presentation/bloc/customer_bloc.dart';
import 'features/customers/presentation/bloc/credit_bloc.dart';
import 'features/store/data/repositories/store_settings_repository.dart';
import 'features/store/presentation/bloc/store_settings_bloc.dart';
import 'features/products/data/repositories/inventory_export_repository.dart';
import 'features/products/presentation/bloc/inventory_export_bloc.dart';
import 'features/inventory/data/repositories/stock_adjustment_repository.dart';
import 'features/inventory/presentation/bloc/stock_adjustment_bloc.dart';
import 'features/inventory/data/repositories/inventory_count_repository.dart';
import 'features/inventory/presentation/bloc/inventory_count_bloc.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Charger les variables d'environnement depuis .env.local
  await dotenv.load(fileName: '.env.local');

  // Initialiser Supabase
  await SupabaseService.initialize();

  // Initialiser la base de données locale (Drift)
  final database = AppDatabase();

  // Initialiser le service de storage et s'assurer que les buckets existent
  final storageService = StorageService(supabase.Supabase.instance.client);
  await storageService.ensureBucketsExist();

  // Initialiser le service de synchronisation
  final syncService = SyncService(database, supabase.Supabase.instance.client);

  // Précharger la police Sora pour éviter le flash au premier lancement
  await GoogleFonts.pendingFonts([GoogleFonts.sora()]);

  runApp(MyApp(
    database: database,
    storageService: storageService,
    syncService: syncService,
  ));
}

class MyApp extends StatefulWidget {
  final AppDatabase database;
  final StorageService storageService;
  final SyncService syncService;

  const MyApp({
    super.key,
    required this.database,
    required this.storageService,
    required this.syncService,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();

    // Synchroniser immédiatement au démarrage
    _performSync();

    // Déclencher la synchronisation toutes les 30 secondes (protection contre perte de données)
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _performSync();
    });
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  Future<void> _performSync() async {
    try {
      final result = await widget.syncService.syncToRemote();
      if (result.isSuccess) {
        developer.log(
          'Background sync completed: ${result.summary}',
          name: 'MyApp',
        );
      } else if (result.hasErrors) {
        developer.log(
          'Background sync completed with errors: ${result.errors.join(", ")}',
          name: 'MyApp',
        );
      }
    } catch (e) {
      developer.log(
        'Background sync failed',
        name: 'MyApp',
        error: e,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // Service pour le storage (upload de photos)
        RepositoryProvider<StorageService>(
          create: (context) => widget.storageService,
        ),
        // Service pour la synchronisation Drift <-> Supabase
        RepositoryProvider<SyncService>(
          create: (context) => widget.syncService,
        ),
        // Repository pour l'authentification
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(
            supabase: supabase.Supabase.instance.client,
            userDao: widget.database.userDao,
            storeDao: widget.database.storeDao,
          ),
        ),
        // Repository pour les catégories
        RepositoryProvider<CategoryRepository>(
          create: (context) => CategoryRepository(widget.database),
        ),
        // Repository pour les items (produits)
        RepositoryProvider<ItemRepository>(
          create: (context) => ItemRepository(widget.database),
        ),
        // Repository pour l'import d'items
        RepositoryProvider<ItemImportRepository>(
          create: (context) => ItemImportRepository(
            context.read<ItemRepository>(),
            widget.database,
          ),
        ),
        // Repository pour les ventes
        RepositoryProvider<SaleRepository>(
          create: (context) => SaleRepository(
            widget.database,
            syncService: context.read<SyncService>(),
          ),
        ),
        // Repository pour les remboursements
        RepositoryProvider<RefundRepository>(
          create: (context) => RefundRepository(
            widget.database,
            syncService: context.read<SyncService>(),
          ),
        ),
        // Repository pour les pages personnalisées
        RepositoryProvider<CustomPageRepositoryImpl>(
          create: (context) => CustomPageRepositoryImpl(
            database: widget.database,
            supabase: supabase.Supabase.instance.client,
          ),
        ),
        // Repository pour les clients
        RepositoryProvider<CustomerRepository>(
          create: (context) => CustomerRepository(database: widget.database),
        ),
        // Repository pour les crédits
        RepositoryProvider<CreditRepository>(
          create: (context) => CreditRepository(
            database: widget.database,
            syncService: context.read<SyncService>(),
          ),
        ),
        // Repository pour les réglages magasin
        RepositoryProvider<StoreSettingsRepository>(
          create: (context) => StoreSettingsRepository(widget.database),
        ),
        // Repository pour les ajustements de stock
        RepositoryProvider<StockAdjustmentRepository>(
          create: (context) => StockAdjustmentRepository(widget.database),
        ),
        // Repository pour les comptages d'inventaire
        RepositoryProvider<InventoryCountRepository>(
          create: (context) => InventoryCountRepository(widget.database),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // BLoC pour l'authentification
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
              syncService: context.read<SyncService>(),
            )..add(AuthCheckRequested()),
          ),
          // BLoC pour les paramètres utilisateur
          BlocProvider<SettingsBloc>(
            create: (context) => SettingsBloc(
              preferencesDao: widget.database.userPreferencesDao,
              syncService: context.read<SyncService>(),
            ),
          ),
          // BLoC pour les catégories
          BlocProvider<CategoryBloc>(
            create: (context) => CategoryBloc(
              context.read<CategoryRepository>(),
            ),
          ),
          // BLoC pour les items (produits)
          BlocProvider<ItemBloc>(
            create: (context) => ItemBloc(
              context.read<ItemRepository>(),
              context.read<SyncService>(),
            ),
          ),
          // BLoC pour l'import d'items
          BlocProvider<ItemImportBloc>(
            create: (context) => ItemImportBloc(
              context.read<ItemImportRepository>(),
            ),
          ),
          // BLoC pour l'export d'inventaire
          BlocProvider<InventoryExportBloc>(
            create: (context) => InventoryExportBloc(
              InventoryExportRepository(widget.database),
            ),
          ),
          // BLoC pour les ventes (paiement)
          BlocProvider<SaleBloc>(
            create: (context) => SaleBloc(
              context.read<SaleRepository>(),
            ),
          ),
          // BLoC pour les remboursements
          BlocProvider<RefundBloc>(
            create: (context) => RefundBloc(
              repository: context.read<RefundRepository>(),
            ),
          ),
          // BLoC pour les clients
          BlocProvider<CustomerBloc>(
            create: (context) => CustomerBloc(
              context.read<CustomerRepository>(),
              context.read<SyncService>(),
            ),
          ),
          // BLoC pour les crédits
          BlocProvider<CreditBloc>(
            create: (context) => CreditBloc(
              context.read<CreditRepository>(),
            ),
          ),
          // BLoC pour les réglages magasin
          BlocProvider<StoreSettingsBloc>(
            create: (context) => StoreSettingsBloc(
              context.read<StoreSettingsRepository>(),
            ),
          ),
          // BLoC pour les ajustements de stock
          BlocProvider<StockAdjustmentBloc>(
            create: (context) => StockAdjustmentBloc(
              repository: context.read<StockAdjustmentRepository>(),
            ),
          ),
          // BLoC pour les comptages d'inventaire
          BlocProvider<InventoryCountBloc>(
            create: (context) => InventoryCountBloc(
              InventoryCountRepository(widget.database),
            ),
          ),
          // BLoC pour les pages personnalisées
          BlocProvider<CustomPageBloc>(
            create: (context) {
              final bloc = CustomPageBloc(
                repository: context.read<CustomPageRepositoryImpl>(),
              );
              // Charger les pages au démarrage si store disponible
              final authBloc = context.read<AuthBloc>();
              if (authBloc.state is AuthAuthenticatedWithStore) {
                final storeId = (authBloc.state as AuthAuthenticatedWithStore).storeId;
                bloc.add(LoadStorePages(storeId));
              }
              return bloc;
            },
          ),
        ],
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            // Charger les préférences utilisateur si authentifié avec magasin
            if (authState is AuthAuthenticatedWithStore) {
              final settingsBloc = context.read<SettingsBloc>();
              if (settingsBloc.state is SettingsInitial) {
                settingsBloc.add(LoadSettings(authState.user.id));
              }
            } else if (authState is AuthPinSessionActive) {
              final settingsBloc = context.read<SettingsBloc>();
              if (settingsBloc.state is SettingsInitial) {
                settingsBloc.add(LoadSettings(authState.user.id));
              }
            }

            return BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, settingsState) {
                // Déterminer le thème et la langue depuis les préférences
                ThemeMode themeMode = ThemeMode.system;
                Locale locale = const Locale('fr');

                if (settingsState is SettingsLoaded) {
                  // Appliquer le thème sélectionné
                  themeMode = settingsState.preferences.themeMode == 'light'
                      ? ThemeMode.light
                      : settingsState.preferences.themeMode == 'dark'
                          ? ThemeMode.dark
                          : ThemeMode.system;

                  // Appliquer la langue sélectionnée
                  locale = Locale(settingsState.preferences.locale);
                }

                return MaterialApp.router(
                  title: 'POS Madagascar',
                  debugShowCheckedModeBanner: false,

                  // Thème dynamique
                  theme: AppTheme.light,
                  darkTheme: AppTheme.dark,
                  themeMode: themeMode,

                  // Localisation dynamique
                  locale: locale,
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: const [
                    Locale('fr'), // Français
                    Locale('mg'), // Malagasy
                  ],

                  // Router
                  routerConfig: AppRouter.router,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
