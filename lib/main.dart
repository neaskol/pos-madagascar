import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/data/remote/supabase_client.dart';
import 'core/data/local/app_database.dart';
import 'core/router/app_router.dart';
import 'core/services/storage_service.dart';
import 'l10n/app_localizations.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/products/data/repositories/category_repository.dart';
import 'features/products/data/repositories/item_repository.dart';
import 'features/products/presentation/bloc/category_bloc.dart';
import 'features/products/presentation/bloc/item_bloc.dart';
import 'features/pos/data/repositories/sale_repository.dart';
import 'features/pos/presentation/bloc/sale_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Charger les variables d'environnement depuis .env.local
  await dotenv.load(fileName: '.env.local');

  // Initialiser Supabase
  await SupabaseService.initialize();

  // Initialiser la base de données locale (Drift)
  final database = AppDatabase();

  // Initialiser le service de storage et s'assurer que les buckets existent
  final storageService = StorageService(Supabase.instance.client);
  await storageService.ensureBucketsExist();

  // Précharger la police Sora pour éviter le flash au premier lancement
  await GoogleFonts.pendingFonts([GoogleFonts.sora()]);

  runApp(MyApp(
    database: database,
    storageService: storageService,
  ));
}

class MyApp extends StatelessWidget {
  final AppDatabase database;
  final StorageService storageService;

  const MyApp({
    super.key,
    required this.database,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // Service pour le storage (upload de photos)
        RepositoryProvider<StorageService>(
          create: (context) => storageService,
        ),
        // Repository pour l'authentification
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(
            supabase: Supabase.instance.client,
            userDao: database.userDao,
            storeDao: database.storeDao,
          ),
        ),
        // Repository pour les catégories
        RepositoryProvider<CategoryRepository>(
          create: (context) => CategoryRepository(database),
        ),
        // Repository pour les items (produits)
        RepositoryProvider<ItemRepository>(
          create: (context) => ItemRepository(database),
        ),
        // Repository pour les ventes
        RepositoryProvider<SaleRepository>(
          create: (context) => SaleRepository(database),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // BLoC pour l'authentification
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            )..add(AuthCheckRequested()),
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
            ),
          ),
          // BLoC pour les ventes (paiement)
          BlocProvider<SaleBloc>(
            create: (context) => SaleBloc(
              context.read<SaleRepository>(),
            ),
          ),
        ],
        child: MaterialApp.router(
          title: 'POS Madagascar',
          debugShowCheckedModeBanner: false,

          // Thème
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,

          // Localisation
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
        ),
      ),
    );
  }
}
