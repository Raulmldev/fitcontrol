import 'package:flutter/material.dart';
import '../Control/ai_expert_team.dart';

/// Vista del Equipo Completo de 15 Expertos de IA
///
/// Muestra detalles de cada uno de los 15 expertos con más de 30 años de experiencia
class AIExpertTeamScreen extends StatelessWidget {
  const AIExpertTeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mainAgents = AIExpertTeam.getMainAgents();
    final specialists = AIExpertTeam.getSpecialists();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipo de Expertos IA'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con estadísticas
            _buildTeamHeader(),
            const SizedBox(height: 24),

            // Agentes principales
            const Text(
              'Agentes Principales',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...mainAgents.map((agent) => _buildMainAgentCard(agent)),
            const SizedBox(height: 24),

            // Especialistas
            const Text(
              'Especialistas de Apoyo',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...specialists.map((agent) => _buildSpecialistCard(context, agent)),
            const SizedBox(height: 32),

            // Footer
            _buildTeamFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamHeader() {
    return Card(
      elevation: 8,
      color: Colors.deepPurple,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.people, size: 64, color: Colors.white),
            const SizedBox(height: 16),
            const Text(
              'EQUIPO DE EXPERTOS IA',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${AIExpertTeam.experts.length} Expertos • ${AIExpertTeam.getTotalExperience()} Años de Experiencia',
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn('${AIExpertTeam.experts.length}', 'Expertos'),
                _buildStatColumn(
                  '${AIExpertTeam.getTotalExperience()}',
                  'Años Exp.',
                ),
                _buildStatColumn(
                  AIExpertTeam.getAverageExperience().toStringAsFixed(1),
                  'Promedio',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildMainAgentCard(AIExpertDefinition agent) {
    Color color;
    IconData icon;

    switch (agent.id) {
      case 'nutrition_expert_001':
        color = Colors.green;
        icon = Icons.restaurant;
        break;
      case 'trainer_expert_001':
        color = Colors.blue;
        icon = Icons.fitness_center;
        break;
      case 'health_expert_001':
        color = Colors.red;
        icon = Icons.favorite;
        break;
      default:
        color = Colors.deepPurple;
        icon = Icons.person;
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, size: 30, color: color),
        ),
        title: Text(
          agent.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(agent.specialization),
            const SizedBox(height: 4),
            Chip(
              label: Text('${agent.experience} años exp.'),
              backgroundColor: color.withValues(alpha: 0.2),
              labelStyle: TextStyle(color: color, fontSize: 12),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Credenciales'),
                ...agent.credentials.map((cred) => _buildBulletPoint(cred)),
                const SizedBox(height: 16),
                _buildSectionTitle('Áreas de Experiencia'),
                ...agent.expertise.map((exp) => _buildBulletPoint(exp)),
                const SizedBox(height: 16),
                _buildSectionTitle('Responsabilidades'),
                ...agent.responsibilities.map(
                  (resp) => _buildBulletPoint(resp),
                ),
                const SizedBox(height: 16),
                _buildSectionTitle('Idiomas'),
                Text(agent.languages.join(', ')),
                const SizedBox(height: 8),
                _buildSectionTitle('Personalidad'),
                Text(agent.personality),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialistCard(BuildContext context, AIExpertDefinition agent) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple.withValues(alpha: 0.2),
          child: const Icon(Icons.psychology, color: Colors.deepPurple),
        ),
        title: Text(
          agent.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(agent.specialization),
            Text('${agent.experience} años de experiencia'),
          ],
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          _showSpecialistDetails(context, agent);
        },
      ),
    );
  }

  void _showSpecialistDetails(
    BuildContext parentContext,
    AIExpertDefinition agent,
  ) {
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      builder:
          (BuildContext modalContext) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            expand: false,
            builder: (BuildContext sheetContext, scrollController) {
              return Container(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.deepPurple.withValues(
                              alpha: 0.2,
                            ),
                            child: const Icon(
                              Icons.psychology,
                              size: 40,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  agent.name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  agent.specialization,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Chip(
                                  label: Text('${agent.experience} años exp.'),
                                  backgroundColor: Colors.deepPurple.shade100,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Credenciales'),
                      ...agent.credentials.map(
                        (cred) => _buildBulletPoint(cred),
                      ),
                      const SizedBox(height: 16),
                      _buildSectionTitle('Áreas de Experiencia'),
                      ...agent.expertise.map((exp) => _buildBulletPoint(exp)),
                      const SizedBox(height: 16),
                      _buildSectionTitle('Responsabilidades'),
                      ...agent.responsibilities.map(
                        (resp) => _buildBulletPoint(resp),
                      ),
                      const SizedBox(height: 16),
                      _buildSectionTitle('Rol de Coordinación'),
                      Text(agent.coordinationRole),
                      const SizedBox(height: 16),
                      _buildSectionTitle('Idiomas'),
                      Text(agent.languages.join(', ')),
                      const SizedBox(height: 16),
                      _buildSectionTitle('Personalidad'),
                      Text(agent.personality),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildTeamFooter() {
    return Card(
      elevation: 4,
      color: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.lightbulb, size: 40, color: Colors.deepPurple),
            const SizedBox(height: 12),
            const Text(
              '¿Cómo funciona el equipo?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Los 3 agentes principales (Nutricionista, Entrenador y Especialista en Salud) '
              'coordinan todas las recomendaciones. Cuando surge una necesidad específica, '
              'los 12 especialistas de apoyo entran en acción para proporcionar '
              'consejo experto en su área. Todos trabajan juntos 24/7 para tu éxito.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sync, color: Colors.deepPurple),
                SizedBox(width: 8),
                Text(
                  'Coordinación inteligente en tiempo real',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
