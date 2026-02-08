import 'package:flutter/material.dart';
import 'View/login.dart';
import 'View/dashboard_screen.dart';
import 'View/ai_chat_screen.dart';
import 'View/ai_expert_team_screen.dart';
import 'View/nutrition_screen.dart';
import 'View/workout_screen.dart';
import 'View/health_screen.dart';
import 'View/conclusion_screen.dart';
import 'package:provider/provider.dart';
import 'Control/nutrition_controller.dart';
import 'Control/health_controller.dart';
import 'Control/workout_controller.dart';
import 'Model/user.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NutritionController()),
        ChangeNotifierProvider(create: (_) => HealthController()),
        ChangeNotifierProvider(create: (_) => WorkoutController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitControl',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        cardTheme: const CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/ai_team': (context) => const AIExpertTeamScreen(),
      },
      onGenerateRoute: (settings) {
        // Rutas que requieren parámetros
        if (settings.name == '/dashboard') {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args != null && args['user'] != null) {
            return MaterialPageRoute(
              builder:
                  (context) => DashboardScreen(
                    user: args['user'] as User,
                    onLogout: args['onLogout'] as VoidCallback,
                  ),
            );
          }
          return null;
        }

        // Rutas que reciben al usuario como argumento
        final args = settings.arguments as Map<String, dynamic>?;
        final user = args?['user'] as User?;

        if (user != null) {
          switch (settings.name) {
            case '/ai_chat':
              return MaterialPageRoute(
                builder: (context) => AIChatScreen(user: user),
              );
            case '/nutrition':
              return MaterialPageRoute(
                builder: (context) => NutritionScreen(user: user),
              );
            case '/workout':
              return MaterialPageRoute(
                builder: (context) => WorkoutScreen(user: user),
              );
            case '/health':
              return MaterialPageRoute(
                builder: (context) => HealthScreen(user: user),
              );
            case '/conclusion':
              return MaterialPageRoute(
                builder: (context) => ConclusionScreen(user: user),
              );
          }
        }

        // Si es una ruta protegida y no hay usuario, redirigir al login
        if ([
          '/ai_chat',
          '/nutrition',
          '/workout',
          '/health',
          '/conclusion',
        ].contains(settings.name)) {
          return MaterialPageRoute(builder: (context) => const LoginScreen());
        }

        return null;
      },
    );
  }
}
