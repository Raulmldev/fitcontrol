import 'package:flutter/material.dart';
import '../Model/user.dart';
import 'log_vitals_screen.dart';

class HealthScreen extends StatelessWidget {
  final User user;

  const HealthScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salud y Bienestar'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
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
                      '62 BPM',
                      'Reposo',
                      Icons.favorite,
                      Colors.red,
                    ),
                    _buildMetricCard(
                      'Presión Arterial',
                      '118/76',
                      'mmHg',
                      Icons.monitor_heart,
                      Colors.purple,
                    ),
                    _buildMetricCard(
                      'Peso',
                      '${user.weight} kg',
                      'Estable',
                      Icons.monitor_weight,
                      Colors.blue,
                    ),
                    _buildMetricCard(
                      'Sueño',
                      '7.5 hrs',
                      'Calidad Alta',
                      Icons.bedtime,
                      Colors.indigo,
                    ),
                    _buildMetricCard(
                      'Estrés',
                      'Bajo',
                      'Nivel 2/10',
                      Icons.spa,
                      Colors.green,
                    ),
                    _buildMetricCard(
                      'Hidratación',
                      '1.8 L',
                      'Meta: 2.5 L',
                      Icons.water_drop,
                      Colors.cyan,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Análisis Médico',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tus signos vitales están dentro de los rangos normales. La tendencia de tu presión arterial ha mejorado en las últimas 2 semanas. Continúa monitoreando cada 3 días.',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text('Consultar Dr. Vásquez'),
                          ),
                        ),
                      ],
                    ),
                  ),
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
              builder: (context) => LogVitalsScreen(user: user),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Registrar Signos'),
        backgroundColor: Colors.red,
      ),
    );
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
}
