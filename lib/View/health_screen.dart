import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../Model/user.dart';
import '../Model/health_metrics.dart';
import '../Control/database_service.dart';
import 'log_vitals_screen.dart';

class HealthScreen extends StatefulWidget {
  final User user;

  const HealthScreen({super.key, required this.user});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  HealthMetrics? _latestMetrics;
  List<HealthMetrics> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final latest = await DatabaseService().getLatestHealthMetrics(widget.user.id);
    final history = await DatabaseService().getHealthHistory(widget.user.id);
    if (mounted) {
      setState(() {
        _latestMetrics = latest;
        _history = history.reversed.toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salud y Bienestar'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
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
                            '${_latestMetrics?.heartRate?.toInt() ?? "--"} BPM',
                            'Última medida',
                            Icons.favorite,
                            Colors.red,
                          ),
                          _buildMetricCard(
                            'Presión Arterial',
                            _latestMetrics?.bloodPressureSystolic != null
                                ? '${_latestMetrics!.bloodPressureSystolic!.toInt()}/${_latestMetrics!.bloodPressureDiastolic!.toInt()}'
                                : '--/--',
                            'mmHg',
                            Icons.monitor_heart,
                            Colors.purple,
                          ),
                          _buildMetricCard(
                            'Peso',
                            '${_latestMetrics?.weight ?? widget.user.weight} kg',
                            'Tendencia',
                            Icons.monitor_weight,
                            Colors.blue,
                          ),
                          _buildMetricCard(
                            'Sueño',
                            '${_latestMetrics?.sleepHours ?? "--"} hrs',
                            _latestMetrics?.sleepQuality != null
                                ? 'Calidad: ${_latestMetrics!.sleepQuality}/10'
                                : 'Sin datos',
                            Icons.bedtime,
                            Colors.indigo,
                          ),
                          _buildMetricCard(
                            'Estrés',
                            _latestMetrics?.stressLevel != null
                                ? (_latestMetrics!.stressLevel! < 4 ? "Bajo" : _latestMetrics!.stressLevel! < 7 ? "Medio" : "Alto")
                                : "N/A",
                            'Nivel: ${_latestMetrics?.stressLevel ?? "--"}/10',
                            Icons.spa,
                            Colors.green,
                          ),
                          _buildMetricCard(
                            'Ánimo',
                            'Nivel: ${_latestMetrics?.mood ?? "--"}/10',
                            'Estado emocional',
                            Icons.emoji_emotions,
                            Colors.orange,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (_history.isNotEmpty) _buildWeightChart(),
                      const SizedBox(height: 24),
                      _buildMedicalAnalysisCard(),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LogVitalsScreen(user: widget.user),
            ),
          );
          if (result != null) {
            _loadData();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Registrar Signos'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildWeightChart() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tendencia de Peso',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: SfCartesianChart(
                primaryXAxis: DateTimeAxis(),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries<HealthMetrics, DateTime>>[
                  LineSeries<HealthMetrics, DateTime>(
                    dataSource: _history,
                    xValueMapper: (HealthMetrics m, _) => m.date,
                    yValueMapper: (HealthMetrics m, _) => m.weight,
                    name: 'Peso (kg)',
                    markerSettings: const MarkerSettings(isVisible: true),
                    color: Colors.blue,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalAnalysisCard() {
    String analysis = "Registra tus primeros signos vitales para recibir un análisis detallado de tu equipo de salud.";
    if (_latestMetrics != null) {
      if ((_latestMetrics!.bloodPressureSystolic ?? 0) > 140) {
        analysis = "Tu presión arterial sistólica está elevada. Te recomendamos descansar y volver a medir en 1 hora. Si persiste, consulta a tu médico.";
      } else if ((_latestMetrics!.heartRate ?? 0) > 100) {
        analysis = "Tu ritmo cardíaco en reposo es algo elevado. Asegúrate de estar bien hidratado y haber descansado lo suficiente.";
      } else {
        analysis = "Tus parámetros actuales son excelentes. La consistencia en el monitoreo es clave para la prevención.";
      }
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Análisis del Dr. Vásquez',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              analysis,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/ai_chat', arguments: {'user': widget.user});
                },
                icon: const Icon(Icons.chat),
                label: const Text('Consultar ahora'),
              ),
            ),
          ],
        ),
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
