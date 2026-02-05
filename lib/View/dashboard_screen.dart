import 'package:flutter/material.dart';
import '../Control/ai_expert_team.dart';
import '../Model/user.dart';
import '../Widgets/how_ai_works_modal.dart';
import 'recommendations_screen.dart';

/// Vista del Dashboard Principal de FitControl
///
/// Muestra un resumen de todos los módulos y acceso rápido a funciones
class DashboardScreen extends StatelessWidget {
  final User user;
  final VoidCallback onLogout;

  const DashboardScreen({
    super.key,
    required this.user,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FitControl'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: onLogout,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;
          final isMedium = constraints.maxWidth > 600;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 // Saludo personalizado
                 _buildWelcomeSection(context),
                 const SizedBox(height: 24),
                 
                 // Botones de acción principales
                 _buildActionButtons(context),
                 const SizedBox(height: 24),
                 
                 // Demo de Web Scraping
                 _buildWebScrapingDemo(context),
                 const SizedBox(height: 24),

                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _buildTodoSection(context),
                            const SizedBox(height: 24),
                            _buildUpcomingSection(context),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            _buildModulesGrid(context, 2),
                            const SizedBox(height: 24),
                            _buildAnalysisSection(context),
                            const SizedBox(height: 24),
                            _buildAIExpertTeamSection(context),
                            const SizedBox(height: 24),
                            _buildDailyRecommendations(),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTodoSection(context),
                      const SizedBox(height: 24),
                      _buildUpcomingSection(context),
                      const SizedBox(height: 24),
                      _buildModulesGrid(context, isMedium ? 2 : 2),
                      const SizedBox(height: 24),
                      _buildAnalysisSection(context),
                      const SizedBox(height: 24),
                      _buildAIExpertTeamSection(context),
                      const SizedBox(height: 24),
                      _buildDailyRecommendations(),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:
            () => Navigator.pushNamed(
              context,
              '/ai_chat',
              arguments: {'user': user},
            ),
        icon: const Icon(Icons.chat),
        label: const Text('Hablar con IA'),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.deepPurple,
              child: Text(
                user.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Hola, ${user.name.split(' ')[0]}!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Tu equipo de expertos está listo.',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
   );
 }

   Widget _buildActionButtons(BuildContext context) {
     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         const Text(
           'Acciones Rápidas',
           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
         ),
         const SizedBox(height: 12),
         Row(
           children: [
             Expanded(
               child: _buildActionButton(
                 context,
                 icon: Icons.psychology,
                 label: 'Explicar IA',
                 color: const Color(0xFF6A11CB),
                 onTap: () => HowAIWorksModal.show(context),
               ),
             ),
             const SizedBox(width: 12),
             Expanded(
               child: _buildActionButton(
                 context,
                 icon: Icons.lightbulb,
                 label: 'Recomendaciones',
                 color: Colors.orange,
                 onTap: () => Navigator.push(
                   context,
                   MaterialPageRoute(
                     builder: (context) => RecommendationsScreen(user: user),
                   ),
                 ),
               ),
             ),
           ],
         ),
       ],
     );
   }

   Widget _buildActionButton(
     BuildContext context, {
     required IconData icon,
     required String label,
     required Color color,
     required VoidCallback onTap,
   }) {
     return Card(
       elevation: 4,
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
       child: InkWell(
         onTap: onTap,
         borderRadius: BorderRadius.circular(12),
         child: Container(
           padding: const EdgeInsets.all(16),
           decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(12),
             gradient: LinearGradient(
               begin: Alignment.topLeft,
               end: Alignment.bottomRight,
               colors: [color.withValues(alpha: 0.9), color],
             ),
           ),
           child: Column(
             children: [
               Icon(icon, color: Colors.white, size: 32),
               const SizedBox(height: 8),
               Text(
                 label,
                 style: const TextStyle(
                   color: Colors.white,
                   fontWeight: FontWeight.bold,
                   fontSize: 14,
                 ),
                 textAlign: TextAlign.center,
               ),
             ],
           ),
         ),
       ),
     );
   }

   Widget _buildWebScrapingDemo(BuildContext context) {
     return Card(
       elevation: 4,
       child: Padding(
         padding: const EdgeInsets.all(20),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Row(
               children: [
                 Container(
                   padding: const EdgeInsets.all(8),
                   decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.1),
                     borderRadius: BorderRadius.circular(8),
                   ),
                   child: Icon(
                     Icons.language,
                     color: Colors.teal,
                     size: 24,
                   ),
                 ),
                 const SizedBox(width: 12),
                 Expanded(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       const Text(
                         'Web Scraping Demo',
                         style: TextStyle(
                           fontSize: 18,
                           fontWeight: FontWeight.bold,
                           color: Color(0xFF333333),
                         ),
                       ),
                       Text(
                         'Prueba el sistema de scraping de alimentos',
                         style: TextStyle(
                           fontSize: 14,
                           color: Colors.grey.shade600,
                         ),
                       ),
                     ],
                   ),
                 ),
               ],
             ),
             const SizedBox(height: 16),
             SizedBox(
               width: double.infinity,
               child: ElevatedButton.icon(
                 onPressed: () => Navigator.pushNamed(context, '/food_scraping_demo'),
                 icon: const Icon(Icons.explore),
                 label: const Text('Explorar Demo'),
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.teal,
                   foregroundColor: Colors.white,
                   padding: const EdgeInsets.symmetric(vertical: 16),
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(12),
                   ),
                 ),
               ),
             ),
           ],
         ),
       ),
     );
   }

   Widget _buildTodoSection(BuildContext context) {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.today, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Para Hoy',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildCheckItem('Entrenamiento: Pierna y Glúteo', false),
            _buildCheckItem('Comida: Pollo con vegetales', true),
            _buildCheckItem('Medir presión arterial', false),
            _buildCheckItem('Beber 2.5L de agua', false),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(String title, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                color: isCompleted ? Colors.grey : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.calendar_month, color: Colors.blueGrey),
                SizedBox(width: 8),
                Text(
                  'Próximos Días',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildUpcomingItem('Mañana', 'Cardio ligero + Yoga'),
            const Divider(),
            _buildUpcomingItem('Miércoles', 'Descanso activo'),
            const Divider(),
            _buildUpcomingItem('Jueves', 'Torso / Brazo'),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingItem(String day, String activity) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(activity, style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _buildModulesGrid(BuildContext context, int crossAxisCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seguimiento por Áreas',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildModuleCard(
              context,
              icon: Icons.restaurant_menu,
              title: 'Nutrición',
              subtitle: 'Plan de comidas',
              color: Colors.green,
              onTap:
                  () => Navigator.pushNamed(
                    context,
                    '/nutrition',
                    arguments: {'user': user},
                  ),
            ),
            _buildModuleCard(
              context,
              icon: Icons.fitness_center,
              title: 'Ejercicios',
              subtitle: 'Rutinas',
              color: Colors.blue,
              onTap:
                  () => Navigator.pushNamed(
                    context,
                    '/workout',
                    arguments: {'user': user},
                  ),
            ),
            _buildModuleCard(
              context,
              icon: Icons.favorite,
              title: 'Salud',
              subtitle: 'Signos vitales',
              color: Colors.red,
              onTap:
                  () => Navigator.pushNamed(
                    context,
                    '/health',
                    arguments: {'user': user},
                  ),
            ),
            _buildModuleCard(
              context,
              icon: Icons.people,
              title: 'Equipo IA',
              subtitle: 'Tus expertos',
              color: Colors.deepPurple,
              onTap: () => Navigator.pushNamed(context, '/ai_team'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withValues(alpha: 0.8), color],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisSection(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed:
            () => Navigator.pushNamed(
              context,
              '/conclusion',
              arguments: {'user': user},
            ),
        icon: const Icon(Icons.assessment),
        label: const Text('VER CONCLUSIÓN Y REPORTE INTEGRAL'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildAIExpertTeamSection(BuildContext context) {
    final mainAgents = AIExpertTeam.getMainAgents();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tu Equipo de Expertos IA',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text(
                    '${AIExpertTeam.experts.length} expertos',
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.deepPurple.shade100,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${AIExpertTeam.getTotalExperience()} años de experiencia combinada a tu servicio',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ...mainAgents.map((agent) => _buildAgentTile(agent)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/ai_team'),
                icon: const Icon(Icons.people),
                label: const Text('Ver Equipo Completo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentTile(AIExpertDefinition agent) {
    final (icon, color) = switch (agent.id) {
      'nutrition_expert_001' => (Icons.restaurant, Colors.green),
      'trainer_expert_001' => (Icons.fitness_center, Colors.blue),
      'health_expert_001' => (Icons.favorite, Colors.red),
      _ => (Icons.person, Colors.grey),
    };

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(
          alpha: 0.2,
        ), // Fixed deprecated withValues
        child: Icon(icon, color: color),
      ),
      title: Text(agent.name),
      subtitle: Text(agent.specialization),
      trailing: Text('${agent.experience} años'),
    );
  }

  Widget _buildDailyRecommendations() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recomendaciones del Día',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildRecommendationItem(
              icon: Icons.restaurant,
              color: Colors.green,
              title: 'Dra. Elena Martínez',
              content:
                  'No olvides incluir proteína en tu desayuno para mantener energía estable.',
            ),
            const Divider(),
            _buildRecommendationItem(
              icon: Icons.fitness_center,
              color: Colors.blue,
              title: 'Carlos Rodríguez',
              content:
                  'Hoy es día de piernas. Recuerda calentar adecuadamente antes de sentadillas.',
            ),
            const Divider(),
            _buildRecommendationItem(
              icon: Icons.favorite,
              color: Colors.red,
              title: 'Dr. Antonio Vásquez',
              content:
                  'Tu presión arterial ha estado excelente esta semana. ¡Sigue así!',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem({
    required IconData icon,
    required Color color,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withValues(
              alpha: 0.2,
            ), // Fixed deprecated withValues
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
