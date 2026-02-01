import 'package:flutter/material.dart';
import '../Control/ai_expert_team.dart';
import '../Model/user.dart';

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
            icon: const Icon(Icons.chat),
            onPressed: () => Navigator.pushNamed(context, '/ai_chat'),
            tooltip: 'Asistente IA',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: onLogout,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saludo personalizado
            _buildWelcomeSection(),
            const SizedBox(height: 24),

            // Resumen de estadísticas
            _buildStatsOverview(),
            const SizedBox(height: 24),

            // Grid de módulos principales
            _buildModulesGrid(context),
            const SizedBox(height: 24),

            // Sección del equipo de IA
            _buildAIExpertTeamSection(context),
            const SizedBox(height: 24),

            // Recomendaciones del día
            _buildDailyRecommendations(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                        'Tu equipo de 15 expertos IA está listo para ayudarte',
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
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickStat('Edad', '${user.age} años'),
                _buildQuickStat('IMC', user.bmi.toStringAsFixed(1)),
                _buildQuickStat('Peso', '${user.weight} kg'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildStatsOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumen de Hoy',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.restaurant,
                title: 'Calorías',
                value: '1,850 / ${user.targetCalories}',
                color: Colors.green,
                progress: 1850 / user.targetCalories,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.fitness_center,
                title: 'Ejercicio',
                value: '45 min',
                color: Colors.blue,
                progress: 0.75,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.favorite,
                title: 'Pasos',
                value: '6,240 / 10,000',
                color: Colors.red,
                progress: 0.62,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.water_drop,
                title: 'Agua',
                value: '1.5 / 2.5 L',
                color: Colors.cyan,
                progress: 0.60,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required double progress,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModulesGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Módulos',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            _buildModuleCard(
              context,
              icon: Icons.restaurant_menu,
              title: 'Nutrición',
              subtitle: 'Comidas y dieta',
              color: Colors.green,
              onTap: () {},
            ),
            _buildModuleCard(
              context,
              icon: Icons.fitness_center,
              title: 'Ejercicios',
              subtitle: 'Rutinas y plan',
              color: Colors.blue,
              onTap: () {},
            ),
            _buildModuleCard(
              context,
              icon: Icons.favorite,
              title: 'Salud',
              subtitle: 'Parámetros vitales',
              color: Colors.red,
              onTap: () {},
            ),
            _buildModuleCard(
              context,
              icon: Icons.shopping_cart,
              title: 'Compras',
              subtitle: 'Lista inteligente',
              color: Colors.orange,
              onTap: () {},
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
              const SizedBox(height: 8),
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
        backgroundColor: color.withValues(alpha: 0.2),
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
            backgroundColor: color.withValues(alpha: 0.2),
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
