import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Model/user.dart';
import '../Model/workout.dart';
import '../Control/workout_controller.dart';

class WorkoutScreen extends StatelessWidget {
  final User user;

  const WorkoutScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutController>(
      builder: (context, controller, child) {
        final todayWorkout = controller.todayWorkout;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Entrenamiento'),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.chat),
                tooltip: 'Chat con Entrenador',
                onPressed:
                    () => Navigator.pushNamed(
                      context,
                      '/ai_chat',
                      arguments: {'user': user, 'contextId': 'workout'},
                    ),
              ),
            ],
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
                          Expanded(
                            flex: 2,
                            child: _buildWeeklySchedule(context, controller),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 3,
                            child: _buildTodayWorkout(
                              context,
                              controller,
                              todayWorkout,
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _buildTodayWorkout(context, controller, todayWorkout),
                          const SizedBox(height: 24),
                          _buildWeeklySchedule(context, controller),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _logWorkout(context, controller),
            icon: const Icon(Icons.check_circle),
            label: const Text('Registrar Rutina'),
            backgroundColor: Colors.blue,
          ),
        );
      },
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

  Widget _buildTodayWorkout(
    BuildContext context,
    WorkoutController controller,
    Workout? workout,
  ) {
    if (workout == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('No hay rutina asignada para hoy.')),
        ),
      );
    }

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
                Text(
                  'Rutina de Hoy: ${workout.name}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Chat with trainer
                  },
                  child: const Text('Consultar Entrenador'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: workout.exercises.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final exercise = workout.exercises[index];
                return _buildExerciseItem(exercise);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseItem(Exercise exercise) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.fitness_center, color: Colors.blue),
      ),
      title: Text(
        exercise.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(exercise.toString()),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // Show exercise details
      },
    );
  }

  Widget _buildWeeklySchedule(
    BuildContext context,
    WorkoutController controller,
  ) {
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
            ...controller.weeklySchedule.map((day) {
              // Mock completion logic: assume day 1 & 2 are completed
              final isCompleted = day.dayOfWeek <= 2;
              return _buildDayRow(
                controller.getDayName(day.dayOfWeek),
                day.focus,
                isCompleted,
              );
            }),
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

  void _logWorkout(BuildContext context, WorkoutController controller) {
    if (controller.todayWorkout != null) {
      controller.logWorkout(controller.todayWorkout!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Entrenamiento registrado! Buen trabajo.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
