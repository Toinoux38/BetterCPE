import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/services/api_client.dart';
import 'data/services/auth_service.dart';
import 'data/services/grades_service.dart';
import 'data/services/planning_service.dart';
import 'data/services/absences_service.dart';
import 'data/services/token_storage.dart';
import 'providers/auth_provider.dart';
import 'providers/grades_provider.dart';
import 'providers/planning_provider.dart';
import 'providers/absences_provider.dart';
import 'providers/settings_provider.dart';
import 'ui/app_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Make Flutter draw behind the system navigation bar
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Set transparent system bars
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  runApp(const StudentApp());
}

/// Main application widget
class StudentApp extends StatefulWidget {
  const StudentApp({super.key});

  @override
  State<StudentApp> createState() => _StudentAppState();
}

class _StudentAppState extends State<StudentApp> {
  // Services - created once and shared across providers
  late final ApiClient _apiClient;
  late final TokenStorage _tokenStorage;
  late final AuthService _authService;
  late final PlanningService _planningService;
  late final GradesService _gradesService;
  late final AbsencesService _absencesService;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  void _initializeServices() {
    _apiClient = ApiClient();
    _tokenStorage = TokenStorage();
    _authService = AuthService(
      apiClient: _apiClient,
      tokenStorage: _tokenStorage,
    );
    _planningService = PlanningService(apiClient: _apiClient);
    _gradesService = GradesService(apiClient: _apiClient);
    _absencesService = AbsencesService(apiClient: _apiClient);
  }

  @override
  void dispose() {
    _apiClient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()..initialize()),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService: _authService),
        ),
        ChangeNotifierProvider(
          create: (_) => PlanningProvider(planningService: _planningService),
        ),
        ChangeNotifierProvider(
          create: (_) => GradesProvider(gradesService: _gradesService),
        ),
        ChangeNotifierProvider(
          create: (_) => AbsencesProvider(absencesService: _absencesService),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          // Wait for settings to be initialized
          if (!settings.isInitialized) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(body: Center(child: CircularProgressIndicator())),
            );
          }

          // Determine if dark mode is active
          final isDark =
              settings.themeMode == ThemeMode.dark ||
              (settings.themeMode == ThemeMode.system &&
                  WidgetsBinding
                          .instance
                          .platformDispatcher
                          .platformBrightness ==
                      Brightness.dark);

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: isDark
                  ? Brightness.light
                  : Brightness.dark,
              systemNavigationBarColor: Colors.transparent,
              systemNavigationBarIconBrightness: isDark
                  ? Brightness.light
                  : Brightness.dark,
            ),
            child: MaterialApp(
              title: settings.strings.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: settings.themeMode,
              home: const AppShell(),
            ),
          );
        },
      ),
    );
  }
}
