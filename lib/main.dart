import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/services/api_client.dart';
import 'data/services/auth_service.dart';
import 'data/services/grades_service.dart';
import 'data/services/planning_service.dart';
import 'data/services/token_storage.dart';
import 'providers/auth_provider.dart';
import 'providers/grades_provider.dart';
import 'providers/planning_provider.dart';
import 'providers/settings_provider.dart';
import 'ui/app_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
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
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: settings.strings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            home: const AppShell(),
          );
        },
      ),
    );
  }
}
