import 'package:flutter/material.dart';

/// Modal que explica cómo funciona FitControl de forma clara y atractiva
class HowAIWorksModal extends StatelessWidget {
  const HowAIWorksModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const HowAIWorksModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF6A11CB),
                Color(0xFF2575FC),
              ],
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Scaffold(
              backgroundColor: Colors.white,
              body: Column(
                children: [
                  // Barra superior con indicador
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  // Título
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.psychology,
                          color: Color(0xFF6A11CB),
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Cómo Funciona FitControl',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  
                  const Divider(height: 32),
                  
                  // Contenido scrollable
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSection(
                            icon: Icons.camera_alt,
                            title: '📸 Reconocimiento de Alimentos',
                            description: 'Toma una foto de tu comida y nuestra IA analizará instantáneamente los ingredientes, calorías y valor nutricional usando visión por computadora avanzada.',
                            color: Colors.green,
                            steps: [
                              '1. Abre la cámara',
                              '2. Fotografía tu comida',
                              '3. Recibe análisis nutricional',
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          _buildSection(
                            icon: Icons.fitness_center,
                            title: '💪 Entrenamiento Personalizado',
                            description: 'Nuestra IA crea rutinas adaptadas a tus objetivos, nivel de condición física y preferencias, ajustándose automáticamente a tu progreso.',
                            color: Colors.blue,
                            steps: [
                              '1. Define tus metas',
                              '2. Recibe rutina personalizada',
                              '3. La IA ajusta según tu progreso',
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          _buildSection(
                            icon: Icons.chat,
                            title: '🤖 Chat con Entrenador IA',
                            description: 'Habla con Carlos, tu entrenador virtual certificado, alimentado por Gemini AI para darte consejos instantáneos y motivación.',
                            color: Colors.deepPurple,
                            steps: [
                              '1. Presiona "Consultar Entrenador"',
                              '2. Escribe tu pregunta',
                              '3. Recibe respuesta experta',
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          _buildSection(
                            icon: Icons.analytics,
                            title: '📊 Seguimiento Inteligente',
                            description: 'Monitorea tu progreso con análisis detallados, predicciones y recomendaciones personalizadas basadas en tus datos.',
                            color: Colors.orange,
                            steps: [
                              '1. Registra tu actividad diaria',
                              '2. La IA analiza patrones',
                              '3. Recibe insights personalizados',
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          _buildSection(
                            icon: Icons.people,
                            title: '👥 Equipo Multidisciplinario',
                            description: 'Accede a un equipo completo de expertos: nutricionistas, entrenadores, médicos y psicólogos deportivos, todos disponibles 24/7.',
                            color: Colors.red,
                            steps: [
                              '1. Explora el equipo',
                              '2. Contacta al especialista',
                              '3. Recibe consejo experto',
                            ],
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Botón de acción
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.check_circle, size: 22),
                              label: const Text(
                                '¡Entendido!',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6A11CB),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required List<String> steps,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
                      color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color.withValues(alpha: 0.2)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                   color: color.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: steps.map((step) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Text(
                          step,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                             color: color.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}