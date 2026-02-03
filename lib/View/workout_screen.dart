import 'package:flutter/material.dart';
import '../Model/user.dart';
import 'ai_chat_screen.dart';
import 'log_workout_screen.dart';

class WorkoutScreen extends StatelessWidget {
  final User user;

  const WorkoutScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrenamiento'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildWeeklySchedule(context)),
                      const SizedBox(width: 24),
                      Expanded(flex: 3, child: _buildTodayWorkout(context)),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildTodayWorkout(context),
                      const SizedBox(height: 24),
                      _buildWeeklySchedule(context),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LogWorkoutScreen(user: user),
            ),
          );
        },
        icon: const Icon(Icons.play_arrow),
        label: const Text('Iniciar Rutina'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.blue,
              radius: 30,
              child: Icon(Icons.fitness_center, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Plan de Entrenamiento',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Objetivo: ${user.fitnessGoal}',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayWorkout(BuildContext context) {
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
                  'Rutina de Hoy: Full Body',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Builder(
                  builder: (BuildContext buttonContext) {
                    return TextButton.icon(
                      onPressed: () {
                        debugPrint('Botón Consultar Entrenador presionado');
                        Navigator.of(buttonContext).push(
                          MaterialPageRoute(
                            builder: (_) => AIChatScreen(
                              user: user,
                              initialAgentId: 'trainer_expert_001',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.chat, size: 18),
                      label: const Text('Consultar Entrenador'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildExerciseItem('Sentadillas', '4 series x 12 reps'),
                const Divider(),
                _buildExerciseItem('Flexiones', '4 series x 15 reps'),
                const Divider(),
                _buildExerciseItem('Remo con Mancuerna', '3 series x 12 reps'),
                const Divider(),
                _buildExerciseItem('Plancha Abdominal', '3 series x 45 seg'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseItem(String name, String details) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.fitness_center, color: Colors.blue),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(details),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // Show exercise details
      },
    );
  }

  Widget _buildWeeklySchedule(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Calendario Semanal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDayRow('Lunes', 'Full Body', true),
            _buildDayRow('Martes', 'Cardio + Abs', true),
            _buildDayRow('Miércoles', 'Descanso', false),
            _buildDayRow('Jueves', 'Tren Superior', false),
            _buildDayRow('Viernes', 'Tren Inferior', false),
            _buildDayRow('Sábado', 'Actividad Libre', false),
            _buildDayRow('Domingo', 'Descanso', false),
          ],
        ),
      ),
    );
  }

  Widget _buildDayRow(String day, String activity, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.circle_outlined,
            color: isCompleted ? Colors.blue : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(day, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(activity, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
