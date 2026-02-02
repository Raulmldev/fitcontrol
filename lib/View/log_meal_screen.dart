import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Model/user.dart';
import '../Model/meal.dart';

/// Pantalla para registrar comidas y alimentos
class LogMealScreen extends StatefulWidget {
  final User user;

  const LogMealScreen({super.key, required this.user});

  @override
  State<LogMealScreen> createState() => _LogMealScreenState();
}

class _LogMealScreenState extends State<LogMealScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores para la comida
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedMealType = 'breakfast';

  // Lista de alimentos agregados
  final List<FoodItem> _foods = [];

  // Controladores para agregar un nuevo alimento
  final _foodNameController = TextEditingController();
  final _quantityController = TextEditingController(text: '100');
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _fiberController = TextEditingController();

  final Map<String, String> _mealTypeLabels = {
    'breakfast': 'Desayuno',
    'lunch': 'Almuerzo',
    'dinner': 'Cena',
    'snack': 'Snack/Merienda',
  };

  final Map<String, IconData> _mealTypeIcons = {
    'breakfast': Icons.wb_sunny,
    'lunch': Icons.restaurant,
    'dinner': Icons.nightlight_round,
    'snack': Icons.local_cafe,
  };

  double get _totalCalories => _foods.fold(0, (sum, food) => sum + food.calories);
  double get _totalProtein => _foods.fold(0, (sum, food) => sum + food.protein);
  double get _totalCarbs => _foods.fold(0, (sum, food) => sum + food.carbs);
  double get _totalFat => _foods.fold(0, (sum, food) => sum + food.fat);
  double get _totalFiber => _foods.fold(0, (sum, food) => sum + food.fiber);

  void _addFood() {
    if (_foodNameController.text.isEmpty ||
        _caloriesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa al menos el nombre y las calorías'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final food = FoodItem(
      name: _foodNameController.text,
      quantity: double.tryParse(_quantityController.text) ?? 100,
      unit: 'g',
      calories: double.tryParse(_caloriesController.text) ?? 0,
      protein: double.tryParse(_proteinController.text) ?? 0,
      carbs: double.tryParse(_carbsController.text) ?? 0,
      fat: double.tryParse(_fatController.text) ?? 0,
      fiber: double.tryParse(_fiberController.text) ?? 0,
    );

    setState(() {
      _foods.add(food);
      _clearFoodInputs();
    });
  }

  void _clearFoodInputs() {
    _foodNameController.clear();
    _quantityController.text = '100';
    _caloriesController.clear();
    _proteinController.clear();
    _carbsController.clear();
    _fatController.clear();
    _fiberController.clear();
  }

  void _removeFood(int index) {
    setState(() {
      _foods.removeAt(index);
    });
  }

  Future<void> _saveMeal() async {
    if (_foods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agrega al menos un alimento'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final meal = Meal(
        userId: widget.user.id,
        name: _nameController.text.isNotEmpty
            ? _nameController.text
            : _mealTypeLabels[_selectedMealType]!,
        mealType: _selectedMealType,
        date: DateTime.now(),
        foods: List.from(_foods),
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      meal.calculateTotals();

      // Simular guardado
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comida registrada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, meal);
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

  Widget _buildMealTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Comida',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _mealTypeLabels.entries.map((entry) {
            final isSelected = _selectedMealType == entry.key;
            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _mealTypeIcons[entry.key],
                    size: 18,
                    color: isSelected ? Colors.white : Colors.green,
                  ),
                  const SizedBox(width: 4),
                  Text(entry.value),
                ],
              ),
              selected: isSelected,
              selectedColor: Colors.green,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedMealType = entry.key;
                  });
                }
              },
            );
          }).toList(),
        ),
      ],
    );
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

  Widget _buildFoodInputSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.add_circle, color: Colors.green.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Agregar Alimento',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _foodNameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del alimento *',
                hintText: 'Ej: Pollo a la plancha',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildNumberField(
                    'Cantidad',
                    _quantityController,
                    suffix: 'g',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: _buildNumberField(
                    'Calorías *',
                    _caloriesController,
                    suffix: 'kcal',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildNumberField(
                    'Proteínas',
                    _proteinController,
                    suffix: 'g',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNumberField(
                    'Carbs',
                    _carbsController,
                    suffix: 'g',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNumberField(
                    'Grasas',
                    _fatController,
                    suffix: 'g',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildNumberField(
              'Fibra (opcional)',
              _fiberController,
              suffix: 'g',
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addFood,
                icon: const Icon(Icons.add),
                label: const Text('AGREGAR ALIMENTO'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodsList() {
    if (_foods.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.restaurant_menu, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                'No has agregado alimentos',
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Alimentos Agregados (${_foods.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _foods.clear();
                });
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Limpiar todo'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._foods.asMap().entries.map((entry) {
          final index = entry.key;
          final food = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green.shade100,
                child: const Icon(Icons.restaurant, color: Colors.green),
              ),
              title: Text(food.name),
              subtitle: Text(
                '${food.quantity.toStringAsFixed(0)}${food.unit} • ${food.calories.toStringAsFixed(0)} kcal',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'P: ${food.protein.toStringAsFixed(1)}g • C: ${food.carbs.toStringAsFixed(1)}g • G: ${food.fat.toStringAsFixed(1)}g',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeFood(index),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTotalsSummary() {
    if (_foods.isEmpty) return const SizedBox.shrink();

    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Totales de la Comida',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMacroSummary('Calorías', _totalCalories, 'kcal', Colors.orange),
                _buildMacroSummary('Proteínas', _totalProtein, 'g', Colors.blue),
                _buildMacroSummary('Carbs', _totalCarbs, 'g', Colors.green),
                _buildMacroSummary('Grasas', _totalFat, 'g', Colors.red),
              ],
            ),
            if (_totalFiber > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Fibra: ${_totalFiber.toStringAsFixed(1)}g',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMacroSummary(String label, double value, String unit, Color color) {
    return Column(
      children: [
        Text(
          value.toStringAsFixed(0),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          unit,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Comida'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: Colors.white),
            )
          else
            TextButton(
              onPressed: _saveMeal,
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
              // Selector de tipo de comida
              _buildMealTypeSelector(),
              const SizedBox(height: 16),

              // Nombre opcional
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre de la comida (opcional)',
                  hintText: _mealTypeLabels[_selectedMealType],
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Formulario para agregar alimentos
              _buildFoodInputSection(),
              const SizedBox(height: 24),

              // Lista de alimentos agregados
              _buildFoodsList(),
              const SizedBox(height: 16),

              // Resumen de totales
              _buildTotalsSummary(),
              const SizedBox(height: 24),

              // Notas
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  hintText: 'Añade observaciones sobre esta comida...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Botón Guardar
              if (_foods.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveMeal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'GUARDAR COMIDA',
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
