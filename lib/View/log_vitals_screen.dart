import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Model/user.dart';
import '../Model/health_metrics.dart';

/// Pantalla para registrar signos vitales y métricas de salud
class LogVitalsScreen extends StatefulWidget {
  final User user;

  const LogVitalsScreen({super.key, required this.user});

  @override
  State<LogVitalsScreen> createState() => _LogVitalsScreenState();
}

class _LogVitalsScreenState extends State<LogVitalsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores para campos de texto
  final _heartRateController = TextEditingController();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _weightController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _sleepHoursController = TextEditingController();
  final _sleepQualityController = TextEditingController();
  final _stressLevelController = TextEditingController();
  final _energyLevelController = TextEditingController();
  final _moodController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _heartRateController.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    _weightController.dispose();
    _bodyFatController.dispose();
    _sleepHoursController.dispose();
    _sleepQualityController.dispose();
    _stressLevelController.dispose();
    _energyLevelController.dispose();
    _moodController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveVitals() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Crear objeto HealthMetrics con los datos ingresados
      final metrics = HealthMetrics(
        userId: widget.user.id,
        date: DateTime.now(),
        heartRate: _heartRateController.text.isNotEmpty
            ? double.parse(_heartRateController.text)
            : null,
        bloodPressureSystolic: _systolicController.text.isNotEmpty
            ? double.parse(_systolicController.text)
            : null,
        bloodPressureDiastolic: _diastolicController.text.isNotEmpty
            ? double.parse(_diastolicController.text)
            : null,
        weight: _weightController.text.isNotEmpty
            ? double.parse(_weightController.text)
            : widget.user.weight,
        bodyFat: _bodyFatController.text.isNotEmpty
            ? double.parse(_bodyFatController.text)
            : null,
        sleepHours: _sleepHoursController.text.isNotEmpty
            ? int.parse(_sleepHoursController.text)
            : null,
        sleepQuality: _sleepQualityController.text.isNotEmpty
            ? int.parse(_sleepQualityController.text)
            : null,
        stressLevel: _stressLevelController.text.isNotEmpty
            ? int.parse(_stressLevelController.text)
            : null,
        energyLevel: _energyLevelController.text.isNotEmpty
            ? int.parse(_energyLevelController.text)
            : null,
        mood: _moodController.text.isNotEmpty
            ? int.parse(_moodController.text)
            : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      // Simular guardado (aquí iría la llamada a la base de datos)
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signos vitales registrados correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, metrics);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField(
    String label,
    TextEditingController controller, {
    String? suffix,
    String? hint,
    int? min,
    int? max,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final number = double.tryParse(value);
          if (number == null) return 'Ingresa un número válido';
          if (min != null && number < min) return 'Mínimo: $min';
          if (max != null && number > max) return 'Máximo: $max';
        }
        return null;
      },
    );
  }

  Widget _buildSliderField(
    String label,
    TextEditingController controller,
    int min,
    int max, {
    Color? color,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        final currentValue = int.tryParse(controller.text) ?? min;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$label: $currentValue', style: const TextStyle(fontWeight: FontWeight.w500)),
            Slider(
              value: currentValue.toDouble(),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: max - min,
              activeColor: color,
              onChanged: (value) {
                setState(() {
                  controller.text = value.toInt().toString();
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$min', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                Text('$max', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Signos Vitales'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: Colors.white),
            )
          else
            TextButton(
              onPressed: _saveVitals,
              child: const Text(
                'GUARDAR',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección: Parámetros Vitales
              _buildSectionTitle('Parámetros Vitales', Icons.favorite, Colors.red),
              const SizedBox(height: 16),
              _buildNumberField(
                'Ritmo Cardíaco',
                _heartRateController,
                suffix: 'BPM',
                hint: 'Ej: 72',
                min: 30,
                max: 220,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      'Presión Sistólica',
                      _systolicController,
                      suffix: 'mmHg',
                      hint: 'Ej: 120',
                      min: 70,
                      max: 250,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildNumberField(
                      'Presión Diastólica',
                      _diastolicController,
                      suffix: 'mmHg',
                      hint: 'Ej: 80',
                      min: 40,
                      max: 150,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Sección: Medidas Corporales
              _buildSectionTitle('Medidas Corporales', Icons.monitor_weight, Colors.blue),
              const SizedBox(height: 16),
              _buildNumberField(
                'Peso',
                _weightController,
                suffix: 'kg',
                hint: widget.user.weight.toString(),
              ),
              const SizedBox(height: 16),
              _buildNumberField(
                'Grasa Corporal',
                _bodyFatController,
                suffix: '%',
                hint: 'Ej: 18.5',
                min: 1,
                max: 60,
              ),
              const SizedBox(height: 24),

              // Sección: Sueño
              _buildSectionTitle('Descanso', Icons.bedtime, Colors.indigo),
              const SizedBox(height: 16),
              _buildNumberField(
                'Horas de Sueño',
                _sleepHoursController,
                suffix: 'hrs',
                hint: 'Ej: 7.5',
                min: 0,
                max: 24,
              ),
              const SizedBox(height: 24),
              _buildSliderField(
                'Calidad de Sueño',
                _sleepQualityController,
                1,
                10,
                color: Colors.indigo,
              ),
              const SizedBox(height: 24),

              // Sección: Bienestar
              _buildSectionTitle('Bienestar General', Icons.spa, Colors.green),
              const SizedBox(height: 16),
              _buildSliderField(
                'Nivel de Estrés',
                _stressLevelController,
                1,
                10,
                color: Colors.orange,
              ),
              const SizedBox(height: 24),
              _buildSliderField(
                'Nivel de Energía',
                _energyLevelController,
                1,
                10,
                color: Colors.yellow.shade700,
              ),
              const SizedBox(height: 24),
              _buildSliderField(
                'Estado de Ánimo',
                _moodController,
                1,
                10,
                color: Colors.purple,
              ),
              const SizedBox(height: 24),

              // Sección: Notas
              _buildSectionTitle('Notas Adicionales', Icons.note, Colors.grey),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  hintText: 'Añade cualquier observación relevante...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 32),

              // Botón Guardar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveVitals,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'GUARDAR REGISTRO',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
