import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Control/nutrition_controller.dart';
import '../Model/user.dart';
import '../Model/meal.dart';
import '../Control/food_search_service.dart';

class NutritionScreen extends StatelessWidget {
  final User user;

  const NutritionScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Responsive layout helper
    final isWide = MediaQuery.of(context).size.width > 600;

    return Consumer<NutritionController>(
      builder: (context, controller, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Nutrición'),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => controller.loadMockData(),
                tooltip: 'Cargar Datos de Prueba',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, controller),
                const SizedBox(height: 24),
                if (isWide)
                  _buildWideLayout(context, controller)
                else
                  _buildMobileLayout(context, controller),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddMealDialog(context, controller),
            icon: const Icon(Icons.add),
            label: const Text('Registrar Comida'),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, NutritionController controller) {
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
                    'Objetivo: ${user.targetCalories} kcal/día',
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

  Widget _buildWideLayout(
    BuildContext context,
    NutritionController controller,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildDailyProgress(context, controller)),
        const SizedBox(width: 24),
        Expanded(child: _buildMealList(context, controller)),
      ],
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    NutritionController controller,
  ) {
    return Column(
      children: [
        _buildDailyProgress(context, controller),
        const SizedBox(height: 24),
        _buildMealList(context, controller),
      ],
    );
  }

  Widget _buildDailyProgress(
    BuildContext context,
    NutritionController controller,
  ) {
    final daily = controller.dailyNutrition;
    final targetCalories =
        daily?.targetCalories ?? user.targetCalories.toDouble();
    final consumedCalories = controller.totalCalories;

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
              consumedCalories,
              targetCalories,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildMacroBar(
              'Proteínas',
              controller.totalProtein,
              daily?.targetProtein ?? 150,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildMacroBar(
              'Carbohidratos',
              controller.totalCarbs,
              daily?.targetCarbs ?? 200,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildMacroBar(
              'Grasas',
              controller.totalFat,
              daily?.targetFat ?? 70,
              Colors.red,
            ),
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
          value: target > 0 ? (current / target).clamp(0.0, 1.0) : 0,
          backgroundColor: color.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation(color),
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
        ),
      ],
    );
  }

  Widget _buildMealList(BuildContext context, NutritionController controller) {
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
                if (controller.todayMeals.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      // Future expanion: View Details
                    },
                    child: Text(
                      '${controller.totalCalories.toInt()} kcal total',
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (controller.todayMeals.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text('No hay comidas registradas hoy.')),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.todayMeals.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final meal = controller.todayMeals[index];
                  return _buildMealItem(meal, controller);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealItem(Meal meal, NutritionController controller) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.check_circle, color: Colors.green),
      title: Text(
        meal.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text('${meal.foods.length} alimentos'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${meal.totalCalories.toInt()} kcal'),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.grey, size: 20),
            onPressed: () => controller.deleteMeal(meal.id),
          ),
        ],
      ),
    );
  }

  void _showAddMealDialog(
    BuildContext context,
    NutritionController controller,
  ) {
    final nameController = TextEditingController();
    final caloriesController = TextEditingController();
    String selectedType = 'breakfast';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Registrar Comida'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre (ej. Almuerzo)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      tooltip: 'Buscar alimento (Web Scraping)',
                      onPressed: () async {
                        final result = await _showFoodSearchDialog(context);
                        if (result != null) {
                          nameController.text = result.name;
                          caloriesController.text =
                              result.calories.toInt().toString();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'breakfast',
                      child: Text('Desayuno'),
                    ),
                    DropdownMenuItem(value: 'lunch', child: Text('Almuerzo')),
                    DropdownMenuItem(value: 'dinner', child: Text('Cena')),
                    DropdownMenuItem(value: 'snack', child: Text('Merienda')),
                  ],
                  onChanged: (value) => selectedType = value!,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: caloriesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Calorías Totales',
                    border: OutlineInputBorder(),
                    suffixText: 'kcal',
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
                if (nameController.text.isNotEmpty &&
                    caloriesController.text.isNotEmpty) {
                  final calories =
                      double.tryParse(caloriesController.text) ?? 0;

                  final newMeal = Meal(
                    userId: user.id,
                    name: nameController.text,
                    mealType: selectedType,
                    date: DateTime.now(),
                    foods: [
                      FoodItem(
                        name: nameController.text,
                        quantity: 1,
                        unit: 'porcion',
                        calories: calories,
                        protein: 0,
                        carbs: 0,
                        fat: 0,
                      ),
                    ],
                  )..calculateTotals();

                  controller.addMeal(newMeal);
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

  Future<FoodItem?> _showFoodSearchDialog(BuildContext context) async {
    final searchController = TextEditingController();
    final foodService = FoodSearchService();
    List<FoodItem> searchResults = [];

    return showDialog<FoodItem>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Buscar Alimento (Web)'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: const InputDecoration(
                              labelText: 'Buscar (ej. Banana)',
                              hintText: 'Simulando scraping...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () async {
                            final results = await foodService.searchFood(
                              searchController.text,
                            );
                            setState(() {
                              searchResults = results;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (searchResults.isNotEmpty)
                      SizedBox(
                        height: 200,
                        width: double.maxFinite,
                        child: ListView.separated(
                          itemCount: searchResults.length,
                          separatorBuilder: (context, i) => const Divider(),
                          itemBuilder: (context, i) {
                            final item = searchResults[i];
                            return ListTile(
                              title: Text(item.name),
                              subtitle: Text(
                                '${item.calories.toInt()} kcal / ${item.quantity} ${item.unit}',
                              ),
                              onTap: () => Navigator.pop(context, item),
                            );
                          },
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
              ],
            );
          },
        );
      },
    );
  }
}
