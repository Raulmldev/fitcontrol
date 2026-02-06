import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Model/user.dart';
import '../Model/meal.dart';

import '../Model/food_nutrition_data.dart';
import '../Control/food_api_service.dart';

import '../Control/food_recognition_service.dart';
import '../Control/database_service.dart';
import '../Widgets/food_nutrition_card.dart';

class NutritionScreen extends StatefulWidget {
  final User user;

  const NutritionScreen({super.key, required this.user});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final FoodAPIService _apiService = FoodAPIService();
  final FoodRecognitionService _recognitionService = FoodRecognitionService();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(text: '100');
  
  FoodNutritionData? _selectedFood;
  bool _isLoading = false;
  final List<String> _searchHistory = [];
  int _selectedMealTypeIndex = 0; // Índice del tipo de comida seleccionado
  
  // Opciones de comida predeterminadas
  final List<Map<String, dynamic>> _mealTypes = [
    {'name': 'Desayuno', 'icon': Icons.wb_sunny, 'time': '07:00'},
    {'name': 'Almuerzo', 'icon': Icons.wb_cloudy, 'time': '13:00'},
    {'name': 'Merienda', 'icon': Icons.wb_twilight, 'time': '17:00'},
    {'name': 'Cena', 'icon': Icons.nightlight, 'time': '20:00'},
  ];

  Future<void> _searchFood(String foodName) async {
    if (foodName.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchController.text = foodName.trim();
      _selectedFood = null;
    });

    try {
      final nutritionData = await _apiService.searchFood(foodName);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _selectedFood = nutritionData;
          
          if (!_searchHistory.contains(foodName.trim())) {
            _searchHistory.add(foodName.trim());
            if (_searchHistory.length > 10) {
              _searchHistory.removeAt(0);
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al buscar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showRegisterFoodModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildRegisterFoodModal(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Responsive layout helper
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrición'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            
            // NUEVO: Buscador con Web Scraping
            _buildFoodSearchWithScraping(),
            const SizedBox(height: 24),
            
            if (isWide)
              _buildWideLayout(context)
            else
              _buildMobileLayout(context),
          ],
        ),
      ),
       floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRegisterFoodModal(context),
        icon: const Icon(Icons.add),
        label: const Text('Registrar Comida'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildFoodSearchWithScraping() {
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.search,
                  color: Colors.green,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Buscar Alimento con IA',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Chip(
                  label: const Text('Web Scraping'),
                  backgroundColor: Colors.green.withValues(alpha: 0.1),
                  labelStyle: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Campo de búsqueda
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Ej: pollo, arroz, manzana...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      prefixIcon: const Icon(Icons.restaurant),
                      suffixIcon: _isLoading 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _selectedFood = null;
                                });
                              },
                            ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (value) => _searchFood(value),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _isLoading 
                      ? null 
                      : () => _searchFood(_searchController.text),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.search),
                  label: const Text('Buscar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            
            // Historial de búsquedas
            if (_searchHistory.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Búsquedas recientes:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _searchHistory.map((food) => ActionChip(
                  label: Text(food),
                  onPressed: () {
                    _searchController.text = food;
                    _searchFood(food);
                  },
                  backgroundColor: Colors.green.withValues(alpha: 0.1),
                  labelStyle: const TextStyle(color: Colors.green),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterFoodModal(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                title: const Text('Registrar Comida'),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                elevation: 0,
                actions: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sección de búsqueda
                    Text(
                      '🔍 Buscar Alimento',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Campo de búsqueda en modal
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Busca un alimento...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.camera_alt),
                          onPressed: () => _takePhotoAndAnalyze(),
                        ),
                      ),
                      onSubmitted: (value) => _searchFood(value),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Resultado de la búsqueda
                    if (_selectedFood != null) ...[
                      Text(
                        '✅ Alimento Encontrado',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FoodNutritionCard(
                        foodName: _selectedFood!.name,
                        nutritionData: _selectedFood,
                        isLoading: false,
                      ),
                    ],
                    
                    const SizedBox(height: 20),
                    
                    // Personalización de cantidad
                    Text(
                      '📊 Personalizar Registro',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Cantidad
                    TextField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: 'Cantidad (gramos)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.scale),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Tipo de comida
                    Text(
                      '🍽️ Tipo de Comida',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _mealTypes.asMap().entries.map((entry) {
                        final index = entry.key;
                        final meal = entry.value;
                        return ChoiceChip(
                          label: Text(meal['name']),
                          avatar: Icon(meal['icon'], size: 18),
                          selected: _selectedMealTypeIndex == index,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedMealTypeIndex = index;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Botón de guardar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _selectedFood != null 
                            ? () => _saveMealRegistration()
                            : null,
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar Comida'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _takePhotoAndAnalyze() async {
    try {
      // Mostrar indicador de carga
      setState(() {
        _isLoading = true;
      });

      // Tomar foto con la cámara
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);

      if (photo == null) {
        // Usuario canceló
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Analizar la imagen usando el servicio de reconocimiento
      final result = await _recognitionService.analyzeFoodImage(photo);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result != null && result['isFood'] == true) {
          // El alimento fue reconocido, actualizar la UI
          final foodName = result['name'] as String;
          final confidence = result['confidence'] as double;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Alimento detectado: $foodName (${(confidence * 100).toStringAsFixed(0)}% confianza)'),
              backgroundColor: Colors.green,
            ),
          );

          // Buscar información nutricional del alimento detectado
          await _searchFood(foodName);
        } else {
          // No se pudo reconocer el alimento
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo identificar el alimento. Intenta con otra foto.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al analizar la foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveMealRegistration() async {
    if (_selectedFood == null) return;
    
    // Obtener el tipo de comida seleccionado
    final mealTypeMap = {
      0: 'breakfast',    // Desayuno
      1: 'lunch',        // Almuerzo
      2: 'snack',        // Merienda
      3: 'dinner',       // Cena
    };
    final selectedMealType = mealTypeMap[_selectedMealTypeIndex] ?? 'snack';
    final selectedMealName = _mealTypes[_selectedMealTypeIndex]['name'] as String;
    
    // Crear el alimento
    final quantity = double.tryParse(_quantityController.text) ?? 100;
    final multiplier = quantity / 100; // Asumiendo valores nutricionales por 100g
    
    final foodItem = FoodItem(
      name: _selectedFood!.name,
      quantity: quantity,
      unit: 'g',
      calories: (_selectedFood!.calories * multiplier).roundToDouble(),
      protein: (_selectedFood!.protein * multiplier).roundToDouble(),
      carbs: (_selectedFood!.carbs * multiplier).roundToDouble(),
      fat: (_selectedFood!.fat * multiplier).roundToDouble(),
      fiber: (_selectedFood!.fiber * multiplier).roundToDouble(),
      category: _selectedFood!.category,
    );
    
    // Crear la comida
    final meal = Meal(
      userId: widget.user.id,
      name: _selectedFood!.name,
      mealType: selectedMealType,
      date: DateTime.now(),
      foods: [foodItem],
      totalCalories: foodItem.calories,
      totalProtein: foodItem.protein,
      totalCarbs: foodItem.carbs,
      totalFat: foodItem.fat,
      totalFiber: foodItem.fiber,
    );
    
    // Guardar la comida en la base de datos
    try {
      await DatabaseService().saveMeal(meal);
      debugPrint('Comida guardada en BD: ${meal.name} (${meal.totalCalories} kcal)');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${_selectedFood!.name} registrado en $selectedMealName'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error al guardar comida: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
        return; // No cerrar el diálogo si hubo error
      }
    }
    
    if (!mounted) return;
    
    Navigator.pop(context);
    
    setState(() {
      _searchController.clear();
      _selectedFood = null;
      _quantityController.text = '100';
      _selectedMealTypeIndex = 0;
    });
  }

  Widget _buildHeader(BuildContext context) {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.green,
              radius: 30,
              child: Icon(Icons.restaurant, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Plan Nutricional',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                   Text(
                     'Objetivo: ${widget.user.targetCalories} kcal/día',
                     style: TextStyle(fontSize:16, color: Colors.grey.shade800),
                   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildDailyProgress(context)),
        const SizedBox(width: 24),
        Expanded(child: _buildMealList(context)),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _buildDailyProgress(context),
        const SizedBox(height: 24),
        _buildMealList(context),
      ],
    );
  }

  Widget _buildDailyProgress(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progreso Diario',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildMacroBar(
              'Calorías',
              1200.0,
              widget.user.targetCalories.toDouble(),
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildMacroBar('Proteínas', 80.0, (widget.user.targetCalories * 0.15), Colors.blue),
            const SizedBox(height: 12),
            _buildMacroBar('Carbohidratos', 150.0, (widget.user.targetCalories * 0.5), Colors.orange),
            const SizedBox(height: 12),
            _buildMacroBar('Grasas', 40.0, (widget.user.targetCalories * 0.25), Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroBar(
    String label,
    double current,
    double target,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text('${current.toInt()} / ${target.toInt()} g/kcal'),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: (current / target).clamp(0.0, 1.0),
          backgroundColor: color.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation(color),
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
        ),
      ],
    );
  }

  Widget _buildMealList(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Comidas de Hoy',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to chat with Nutritionist context
                  },
                  child: const Text('Consultar a Nutricionista'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildMealItem('Desayuno', 'Avena con frutas y nueces', 450),
            const Divider(),
            _buildMealItem('Almuerzo', 'Pechuga de pollo con ensalada', 650),
            const Divider(),
            _buildMealItem('Merienda', 'Yogurt griego', 150),
            const Divider(),
            _buildMealItem('Cena', 'Pendiente', 0, isPending: true),
          ],
        ),
      ),
    );
  }

  Widget _buildMealItem(
    String title,
    String description,
    int calories, {
    bool isPending = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        isPending ? Icons.radio_button_unchecked : Icons.check_circle,
        color: isPending ? Colors.grey : Colors.green,
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(description),
      trailing: Text('$calories kcal'),
    );
  }
}
