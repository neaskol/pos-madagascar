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
import 'l10n/app_localizations.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Charger les variables d'environnement depuis .env.local
  await dotenv.load(fileName: '.env.local');

  // Initialiser Supabase
  await SupabaseService.initialize();

  // Initialiser la base de données locale (Drift)
  final database = AppDatabase();

  // Précharger la police Sora pour éviter le flash au premier lancement
  await GoogleFonts.pendingFonts([GoogleFonts.sora()]);

  runApp(MyApp(database: database));
}

class MyApp extends StatelessWidget {
  final AppDatabase database;

  const MyApp({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // Repository pour l'authentification
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(
            supabase: Supabase.instance.client,
            userDao: database.userDao,
            storeDao: database.storeDao,
          ),
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
