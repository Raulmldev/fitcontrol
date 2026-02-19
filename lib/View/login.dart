import 'package:flutter/material.dart';
import 'login_model.dart';
import '../Model/user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _loginModel = LoginModel();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _loginModel.login(
          _emailController.text,
          _passwordController.text,
        );

        if (mounted) {
          // Crear usuario de ejemplo para demostración
          final user = User(
            email: _emailController.text,
            name: 'Usuario Demo',
            birthDate: DateTime(1990, 5, 15),
            gender: 'Masculino',
            height: 175,
            weight: 75,
            activityLevel: 'moderado',
            fitnessGoal: 'Definición muscular',
            targetCalories: 2200,
          );

          // Navegar al dashboard
          Navigator.pushReplacementNamed(
            context,
            '/dashboard',
            arguments: {
              'user': user,
              'onLogout': () {
                Navigator.pushReplacementNamed(context, '/');
              },
            },
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _navigateToDemo() {
    // Crear usuario de ejemplo para demo
    final user = User(
      email: 'demo@fitcontrol.com',
      name: 'Usuario Demo',
      birthDate: DateTime(1990, 5, 15),
      gender: 'Masculino',
      height: 175,
      weight: 75,
      activityLevel: 'moderado',
      fitnessGoal: 'Definición muscular',
      targetCalories: 2200,
    );

    Navigator.pushReplacementNamed(
      context,
      '/dashboard',
      arguments: {
        'user': user,
        'onLogout': () {
          Navigator.pushReplacementNamed(context, '/');
        },
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo y título
                const Icon(
                  Icons.fitness_center,
                  size: 80,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 16),
                const Text(
                  'FitControl',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '15 Expertos IA • 450+ Años de Experiencia',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 48),

                // Campo de email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu email';
                    }
                    if (!value.contains('@')) {
                      return 'Por favor ingresa un email válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo de contraseña
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu contraseña';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Botón de login
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              'Iniciar Sesión',
                              style: TextStyle(fontSize: 16),
                            ),
                  ),
                ),
                const SizedBox(height: 16),

                // Botón de acceso rápido a Demo
                TextButton.icon(
                  onPressed: _navigateToDemo,
                  icon: const Icon(Icons.preview),
                  label: const Text('Probar App (Demo Completa)'),
                ),
                const SizedBox(height: 32),

                // Info del equipo
                Card(
                  color: Colors.deepPurple.shade50,
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people, color: Colors.deepPurple),
                            SizedBox(width: 8),
                            Text(
                              'Equipo de 15 Expertos IA',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Nutricionistas • Entrenadores • Especialistas en Salud',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
