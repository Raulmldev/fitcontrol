import 'package:flutter/material.dart';
import 'View/login.dart';
import 'View/dashboard_screen.dart';
import 'View/ai_chat_screen.dart';
import 'View/ai_expert_team_screen.dart';
import 'Model/user.dart';

void main() {
  runApp(const MyApp());
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
        switch (settings.name) {
          case '/dashboard':
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

          case '/ai_chat':
            final args = settings.arguments as Map<String, dynamic>?;
            if (args != null && args['user'] != null) {
              return MaterialPageRoute(
                builder: (context) => AIChatScreen(user: args['user'] as User),
              );
            }
            // Si no hay args, redirigir al login
            return MaterialPageRoute(builder: (context) => const LoginScreen());

          default:
            return null;
        }
      },
    );
  }
}
