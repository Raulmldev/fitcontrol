import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Model/user.dart';
import '../Model/health_metrics.dart';
import '../Control/health_controller.dart';

class HealthScreen extends StatelessWidget {
  final User user;

  const HealthScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthController>(
      builder: (context, controller, child) {
        final metrics = controller.latestMetrics;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Salud y Bienestar'),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.chat),
                tooltip: 'Chat con Especialista en Salud',
                onPressed:
                    () => Navigator.pushNamed(
                      context,
                      '/ai_chat',
                      arguments: {'user': user, 'contextId': 'health'},
                    ),
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount =
                  constraints.maxWidth > 800
                      ? 3
                      : (constraints.maxWidth > 600 ? 2 : 1);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 24),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      children: [
                        _buildMetricCard(
                          'Ritmo Cardíaco',
                          metrics?.heartRate != null
                              ? '${metrics!.heartRate!.toInt()} BPM'
                              : '--',
                          'Reposo',
                          Icons.favorite,
                          Colors.red,
                        ),
                        _buildMetricCard(
                          'Presión Arterial',
                          metrics?.bloodPressure ?? '--/--',
                          'mmHg',
                          Icons.monitor_heart,
                          Colors.purple,
                        ),
                        _buildMetricCard(
                          'Peso',
                          metrics != null
                              ? '${metrics.weight} kg'
                              : '${user.weight} kg',
                          'Estable',
                          Icons.monitor_weight,
                          Colors.blue,
                        ),
                        _buildMetricCard(
                          'Sueño',
                          metrics?.sleepHours != null
                              ? '${metrics!.sleepHours} hrs'
                              : '--',
                          'Calidad Alta',
                          Icons.bedtime,
                          Colors.indigo,
                        ),
                        _buildMetricCard(
                          'Estrés',
                          metrics?.stressLevel != null
                              ? _getStressLabel(metrics!.stressLevel!)
                              : '--',
                          'Nivel ${metrics?.stressLevel ?? '-'}',
                          Icons.spa,
                          Colors.green,
                        ),
                        _buildMetricCard(
                          'Hidratación',
                          metrics?.waterPercentage != null
                              ? '${metrics!.waterPercentage}%'
                              : '--',
                          'Meta: 60%',
                          Icons.water_drop,
                          Colors.cyan,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildHistorySection(controller),
                  ],
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddVitalsDialog(context, controller),
            icon: const Icon(Icons.add),
            label: const Text('Registrar Signos'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  String _getStressLabel(int level) {
    if (level <= 3) return 'Bajo';
    if (level <= 7) return 'Moderado';
    return 'Alto';
  }

  Widget _buildHeader(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.red,
              radius: 30,
              child: Icon(
                Icons.medical_services,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monitoreo de Salud',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Bienestar General: Óptimo',
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

  Widget _buildMetricCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 30),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection(HealthController controller) {
    if (controller.history.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Historial Reciente',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.history.length,
              itemBuilder: (context, index) {
                final metric = controller.history[index];
                return ListTile(
                  leading: Text(
                    '${metric.date.day}/${metric.date.month}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  title: Text(
                    '${metric.heartRate?.toInt() ?? '-'} BPM | ${metric.bloodPressure}',
                  ),
                  subtitle: Text(
                    'Peso: ${metric.weight}kg | Sueño: ${metric.sleepHours ?? '-'}h',
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddVitalsDialog(BuildContext context, HealthController controller) {
    final heartRateController = TextEditingController();
    final sysController = TextEditingController();
    final diaController = TextEditingController();
    final weightController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Registrar Signos Vitales'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: heartRateController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Ritmo Cardíaco (BPM)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: sysController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Sistólica',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: diaController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Diastólica',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: weightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Peso (kg)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final heartRate = double.tryParse(heartRateController.text);
                final sys = double.tryParse(sysController.text);
                final dia = double.tryParse(diaController.text);
                final weight = double.tryParse(weightController.text);

                if (weight != null) {
                  final newMetrics = HealthMetrics(
                    userId: user.id,
                    date: DateTime.now(),
                    weight: weight,
                    heartRate: heartRate,
                    bloodPressureSystolic: sys,
                    bloodPressureDiastolic: dia,
                  );
                  controller.addMetrics(newMetrics);
                  Navigator.pop(context);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}
