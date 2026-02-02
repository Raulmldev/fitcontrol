import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Model/user.dart';
import '../Model/workout.dart';

/// Pantalla para registrar entrenamientos y ejercicios
class LogWorkoutScreen extends StatefulWidget {
  final User user;

  const LogWorkoutScreen({super.key, required this.user});

  @override
  State<LogWorkoutScreen> createState() => _LogWorkoutScreenState();
}

class _LogWorkoutScreenState extends State<LogWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores para el entrenamiento
  final _nameController = TextEditingController();
  final _durationController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedType = 'strength';
  int _intensity = 3;

  // Lista de ejercicios agregados
  final List<Exercise> _exercises = [];

  // Controladores para agregar un nuevo ejercicio
  final _exerciseNameController = TextEditingController();
  final _setsController = TextEditingController(text: '3');
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  final _durationExerciseController = TextEditingController();
  final _exerciseNotesController = TextEditingController();
  String _selectedCategory = 'chest';

  final Map<String, String> _workoutTypeLabels = {
    'strength': 'Fuerza',
    'cardio': 'Cardio',
    'flexibility': 'Flexibilidad',
    'sport': 'Deporte',
  };

  final Map<String, IconData> _workoutTypeIcons = {
    'strength': Icons.fitness_center,
    'cardio': Icons.directions_run,
    'flexibility': Icons.self_improvement,
    'sport': Icons.sports,
  };

  final Map<String, String> _categoryLabels = {
    'chest': 'Pecho',
    'back': 'Espalda',
    'shoulders': 'Hombros',
    'arms': 'Brazos',
    'legs': 'Piernas',
    'core': 'Core',
    'cardio': 'Cardio',
  };

  void _addExercise() {
    if (_exerciseNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa el nombre del ejercicio'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final exercise = Exercise(
      name: _exerciseNameController.text,
      category: _selectedCategory,
      sets: int.tryParse(_setsController.text) ?? 3,
      reps: int.tryParse(_repsController.text) ?? 0,
      weight: double.tryParse(_weightController.text) ?? 0,
      duration: int.tryParse(_durationExerciseController.text) != null
          ? int.parse(_durationExerciseController.text) * 60
          : null,
      notes: _exerciseNotesController.text.isNotEmpty
          ? _exerciseNotesController.text
          : null,
    );

    setState(() {
      _exercises.add(exercise);
      _clearExerciseInputs();
    });
  }

  void _clearExerciseInputs() {
    _exerciseNameController.clear();
    _setsController.text = '3';
    _repsController.clear();
    _weightController.clear();
    _durationExerciseController.clear();
    _exerciseNotesController.clear();
    _selectedCategory = 'chest';
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
  }

  Future<void> _saveWorkout() async {
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agrega al menos un ejercicio'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_durationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa la duración del entrenamiento'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final workout = Workout(
        userId: widget.user.id,
        name: _nameController.text.isNotEmpty
            ? _nameController.text
            : _getDefaultWorkoutName(),
        type: _selectedType,
        date: DateTime.now(),
        duration: int.parse(_durationController.text),
        caloriesBurned: int.tryParse(_caloriesController.text) ?? 0,
        intensity: _intensity,
        exercises: List.from(_exercises),
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      // Simular guardado
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entrenamiento registrado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, workout);
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

  String _getDefaultWorkoutName() {
    final typeLabels = {
      'strength': 'Entrenamiento de Fuerza',
      'cardio': 'Cardio',
      'flexibility': 'Flexibilidad',
      'sport': 'Deporte',
    };
    return typeLabels[_selectedType] ?? 'Entrenamiento';
  }

  Widget _buildWorkoutTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Entrenamiento',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _workoutTypeLabels.entries.map((entry) {
            final isSelected = _selectedType == entry.key;
            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _workoutTypeIcons[entry.key],
                    size: 18,
                    color: isSelected ? Colors.white : Colors.blue,
                  ),
                  const SizedBox(width: 4),
                  Text(entry.value),
                ],
              ),
              selected: isSelected,
              selectedColor: Colors.blue,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedType = entry.key;
                  });
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildIntensitySlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Intensidad',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Slider(
          value: _intensity.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          label: _intensity.toString(),
          activeColor: _getIntensityColor(),
          onChanged: (value) {
            setState(() {
              _intensity = value.toInt();
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Baja', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            Text(
              _getIntensityLabel(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getIntensityColor(),
              ),
            ),
            Text('Alta', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Color _getIntensityColor() {
    switch (_intensity) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.lightGreen;
      case 3:
        return Colors.yellow.shade700;
      case 4:
        return Colors.orange;
      case 5:
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _getIntensityLabel() {
    switch (_intensity) {
      case 1:
        return 'Muy Ligero';
      case 2:
        return 'Ligero';
      case 3:
        return 'Moderado';
      case 4:
        return 'Intenso';
      case 5:
        return 'Máximo';
      default:
        return 'Moderado';
    }
  }

  Widget _buildNumberField(
    String label,
    TextEditingController controller, {
    String? suffix,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
    );
  }

  Widget _buildExerciseInputSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.add_circle, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Agregar Ejercicio',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _exerciseNameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del ejercicio *',
                hintText: 'Ej: Sentadillas',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Grupo Muscular',
                border: OutlineInputBorder(),
              ),
              items: _categoryLabels.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildNumberField(
                    'Series',
                    _setsController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNumberField(
                    'Repeticiones',
                    _repsController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNumberField(
                    'Peso',
                    _weightController,
                    suffix: 'kg',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildNumberField(
              'Duración (opcional)',
              _durationExerciseController,
              suffix: 'min',
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _exerciseNotesController,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                hintText: 'Técnica especial, descanso, etc.',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addExercise,
                icon: const Icon(Icons.add),
                label: const Text('AGREGAR EJERCICIO'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExercisesList() {
    if (_exercises.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.fitness_center, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                'No has agregado ejercicios',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                'Usa el formulario de arriba para agregar',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ejercicios (${_exercises.length})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ..._exercises.asMap().entries.map((entry) {
          final index = entry.key;
          final exercise = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: const Icon(Icons.fitness_center, color: Colors.blue),
              ),
              title: Text(exercise.name),
              subtitle: Text(
                '${_categoryLabels[exercise.category]} • ${exercise.sets} series × ${exercise.reps} reps${exercise.weight != null && exercise.weight! > 0 ? ' @ ${exercise.weight}kg' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeExercise(index),
              ),
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Entrenamiento'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: Colors.white),
            )
          else
            TextButton(
              onPressed: _saveWorkout,
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
              // Selector de tipo de entrenamiento
              _buildWorkoutTypeSelector(),
              const SizedBox(height: 16),

              // Nombre opcional
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre del entrenamiento (opcional)',
                  hintText: _getDefaultWorkoutName(),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Intensidad
              _buildIntensitySlider(),
              const SizedBox(height: 16),

              // Duración y calorías
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      'Duración *',
                      _durationController,
                      suffix: 'min',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildNumberField(
                      'Calorías',
                      _caloriesController,
                      suffix: 'kcal',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Formulario para agregar ejercicios
              _buildExerciseInputSection(),
              const SizedBox(height: 24),

              // Lista de ejercicios agregados
              _buildExercisesList(),
              const SizedBox(height: 16),

              // Notas
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  hintText: 'Observaciones sobre el entrenamiento...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Botón Guardar
              if (_exercises.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveWorkout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'GUARDAR ENTRENAMIENTO',
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
