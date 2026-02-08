import '../Model/meal.dart';

/// Service to handle food search and data retrieval (simulating web scraping)
class FoodSearchService {
  // Mock database to simulate "web results"
  static final Map<String, FoodItem> _mockDatabase = {
    'banana': FoodItem(
      name: 'Banana',
      quantity: 1,
      unit: 'pieza',
      calories: 105,
      protein: 1.3,
      carbs: 27,
      fat: 0.4,
    ),
    'manzana': FoodItem(
      name: 'Manzana',
      quantity: 1,
      unit: 'pieza',
      calories: 95,
      protein: 0.5,
      carbs: 25,
      fat: 0.3,
    ),
    'pollo': FoodItem(
      name: 'Pechuga de Pollo',
      quantity: 100,
      unit: 'g',
      calories: 165,
      protein: 31,
      carbs: 0,
      fat: 3.6,
    ),
    'arroz': FoodItem(
      name: 'Arroz Blanco',
      quantity: 100,
      unit: 'g',
      calories: 130,
      protein: 2.7,
      carbs: 28,
      fat: 0.3,
    ),
    'huevo': FoodItem(
      name: 'Huevo',
      quantity: 1,
      unit: 'grande',
      calories: 78,
      protein: 6,
      carbs: 0.6,
      fat: 5,
    ),
    'avena': FoodItem(
      name: 'Avena',
      quantity: 100,
      unit: 'g',
      calories: 389,
      protein: 16.9,
      carbs: 66,
      fat: 6.9,
    ),
  };

  /// Searches for food items based on a query string.
  /// Simulates a web scraping delay and returns a list of matching FoodItems.
  Future<List<FoodItem>> searchFood(String query) async {
    // Simulate network delay for "scraping" feel
    await Future.delayed(const Duration(milliseconds: 1500));

    final normalizedQuery = query.toLowerCase().trim();

    if (normalizedQuery.isEmpty) return [];

    final results =
        _mockDatabase.entries
            .where((entry) => entry.key.contains(normalizedQuery))
            .map((entry) => entry.value)
            .toList();

    // If exact match not found, maybe return a generic "Web Result"
    if (results.isEmpty) {
      // Return a generic mock result to simulating finding something "new"
      return [
        FoodItem(
          name: '$query (Web Result)',
          quantity: 100,
          unit: 'g',
          calories: 100, // Placeholder
          protein: 5,
          carbs: 10,
          fat: 2,
        ),
      ];
    }

    return results;
  }
}
