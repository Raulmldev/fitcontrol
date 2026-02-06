import '../Config/app_logger.dart';

import '../Model/food_nutrition_data.dart';

/// Servicio de Web Scraping para obtener datos nutricionales reales
/// Extrae información de fuentes confiables como:
/// - USDA FoodData Central
/// - Nutritionix Database  
/// - MyFitnessPal
/// - Healthline Nutrition
class FoodScrapingService {
  static final FoodScrapingService _instance = FoodScrapingService._internal();
  factory FoodScrapingService() => _instance;
  FoodScrapingService._internal();

  // Cache para evitar requests repetitivos
  final Map<String, FoodNutritionData> _cache = {};
  
  // URLs de fuentes confiables
  // static const String _usdaBaseUrl = 'https://fdc.nal.usda.gov/fdc-app.html#/food-details/';
  // static const String _nutritionixBaseUrl = 'https://www.nutritionix.com/';
  // static const String _healthlineBaseUrl = 'https://www.healthline.com/nutrition/';

  /// Busca información nutricional de un alimento
  Future<FoodNutritionData?> searchFood(String foodName) async {
    try {
      // Verificar cache primero
      if (_cache.containsKey(foodName.toLowerCase())) {
        AppLogger.food('Found in cache: $foodName');
        return _cache[foodName.toLowerCase()];
      }
      
      // Intentar múltiples fuentes
      FoodNutritionData? result;
      
      result = await _searchUSDA(foodName);
      if (result != null) {
        _cache[foodName.toLowerCase()] = result;
        return result;
      }
      
      result = await _searchNutritionix(foodName);
      if (result != null) {
        _cache[foodName.toLowerCase()] = result;
        return result;
      }
      
      result = await _searchHealthline(foodName);
      if (result != null) {
        _cache[foodName.toLowerCase()] = result;
        return result;
      }
      
      AppLogger.warning('No data found', tag: 'FOOD');
      return null;
    } catch (e) {
      AppLogger.error('Error searching', error: e, tag: 'FOOD');
      return null;
    }
  }

   /// Busca en USDA FoodData Central (simulado)
  Future<FoodNutritionData?> _searchUSDA(String foodName) async {
    try {
      // Simular request HTTP real
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Normalizar nombre (español -> inglés)
      final normalizedName = _normalizeFoodName(foodName);
      
      // Mock response - en producción sería request a la API real
      final mockResponses = {
        'apple': FoodNutritionData(
          name: 'Manzana',
          calories: 52,
          protein: 0.3,
          carbs: 14,
          fat: 0.2,
          fiber: 2.4,
          servingSize: '1 medium (182g)',
          source: 'USDA',
          category: 'fruits',
          confidence: 0.95,
          lastUpdated: DateTime.now(),
        ),
        'chicken breast': FoodNutritionData(
          name: 'Pechuga de pollo',
          calories: 165,
          protein: 31,
          carbs: 0,
          fat: 3.6,
          fiber: 0,
          servingSize: '100g',
          source: 'USDA',
          category: 'meat',
          confidence: 0.94,
          lastUpdated: DateTime.now(),
        ),
        'broccoli': FoodNutritionData(
          name: 'Brócoli',
          calories: 34,
          protein: 2.8,
          carbs: 7,
          fat: 0.4,
          fiber: 2.6,
          servingSize: '1 cup (91g)',
          source: 'USDA',
          category: 'vegetables',
          confidence: 0.92,
          lastUpdated: DateTime.now(),
        ),
        'brown rice': FoodNutritionData(
          name: 'Arroz integral',
          calories: 111,
          protein: 2.6,
          carbs: 23,
          fat: 0.9,
          fiber: 1.8,
          servingSize: '1 cup (195g)',
          source: 'USDA',
          category: 'grains',
          confidence: 0.88,
          lastUpdated: DateTime.now(),
        ),
        'eggs': FoodNutritionData(
          name: 'Huevos',
          calories: 155,
          protein: 13,
          carbs: 1.1,
          fat: 11,
          fiber: 0,
          servingSize: '2 large eggs (100g)',
          source: 'USDA',
          category: 'dairy',
          confidence: 0.97,
          lastUpdated: DateTime.now(),
        ),
        'milk': FoodNutritionData(
          name: 'Leche descremada',
          calories: 61,
          protein: 3.2,
          carbs: 4.8,
          fat: 3.3,
          fiber: 0,
          servingSize: '1 cup (244ml)',
          source: 'USDA',
          category: 'dairy',
          confidence: 0.90,
          lastUpdated: DateTime.now(),
        ),
        'banana': FoodNutritionData(
          name: 'Plátano',
          calories: 89,
          protein: 1.1,
          carbs: 23,
          fat: 0.3,
          fiber: 2.6,
          servingSize: '1 medium (118g)',
          source: 'USDA',
          category: 'fruits',
          confidence: 0.93,
          lastUpdated: DateTime.now(),
        ),
        'salmon': FoodNutritionData(
          name: 'Salmón',
          calories: 208,
          protein: 20,
          carbs: 0,
          fat: 13,
          fiber: 0,
          servingSize: '100g',
          source: 'USDA',
          category: 'fish',
          confidence: 0.91,
          lastUpdated: DateTime.now(),
        ),
        'avocado': FoodNutritionData(
          name: 'Aguacate',
          calories: 160,
          protein: 2,
          carbs: 9,
          fat: 15,
          fiber: 7,
          servingSize: '1 medium (201g)',
          source: 'USDA',
          category: 'fruits',
          confidence: 0.89,
          lastUpdated: DateTime.now(),
        ),
        'almonds': FoodNutritionData(
          name: 'Almendras',
          calories: 579,
          protein: 21,
          carbs: 22,
          fat: 49,
          fiber: 13,
          servingSize: '1 oz (28g)',
          source: 'USDA',
          category: 'nuts',
          confidence: 0.93,
          lastUpdated: DateTime.now(),
        ),
        'quinoa': FoodNutritionData(
          name: 'Quinoa',
          calories: 120,
          protein: 4.4,
          carbs: 21,
          fat: 1.9,
          fiber: 2.8,
          servingSize: '1 cup cooked (185g)',
          source: 'USDA',
          category: 'grains',
          confidence: 0.87,
          lastUpdated: DateTime.now(),
        ),
        'sweet potato': FoodNutritionData(
          name: 'Batata dulce',
          calories: 86,
          protein: 1.6,
          carbs: 20,
          fat: 0.1,
          fiber: 2.2,
          servingSize: '1 medium (128g)',
          source: 'USDA',
          category: 'vegetables',
          confidence: 0.85,
          lastUpdated: DateTime.now(),
        ),
        'spinach': FoodNutritionData(
          name: 'Espinacas',
          calories: 23,
          protein: 2.9,
          carbs: 3.6,
          fat: 0.4,
          fiber: 2.2,
          servingSize: '1 cup (30g)',
          source: 'USDA',
          category: 'vegetables',
          confidence: 0.88,
          lastUpdated: DateTime.now(),
        ),
        'oats': FoodNutritionData(
          name: 'Avena',
          calories: 154,
          protein: 5.3,
          carbs: 27,
          fat: 2.8,
          fiber: 4,
          servingSize: '1 cup cooked (154g)',
          source: 'USDA',
          category: 'grains',
          confidence: 0.82,
          lastUpdated: DateTime.now(),
        ),
        'yogurt': FoodNutritionData(
          name: 'Yogur griego',
          calories: 59,
          protein: 10,
          carbs: 3.6,
          fat: 0.4,
          fiber: 0,
          servingSize: '100g',
          source: 'USDA',
          category: 'dairy',
          confidence: 0.90,
          lastUpdated: DateTime.now(),
        ),
        'beef': FoodNutritionData(
          name: 'Carne de res',
          calories: 250,
          protein: 26,
          carbs: 0,
          fat: 15,
          fiber: 0,
          servingSize: '100g',
          source: 'USDA',
          category: 'meat',
          confidence: 0.92,
          lastUpdated: DateTime.now(),
        ),
        'rice': FoodNutritionData(
          name: 'Arroz blanco',
          calories: 130,
          protein: 2.7,
          carbs: 28,
          fat: 0.3,
          fiber: 0.4,
          servingSize: '100g cocido',
          source: 'USDA',
          category: 'grains',
          confidence: 0.88,
          lastUpdated: DateTime.now(),
        ),
        'bread': FoodNutritionData(
          name: 'Pan integral',
          calories: 247,
          protein: 13,
          carbs: 41,
          fat: 3.4,
          fiber: 7,
          servingSize: '100g',
          source: 'USDA',
          category: 'grains',
          confidence: 0.85,
          lastUpdated: DateTime.now(),
        ),
        'pasta': FoodNutritionData(
          name: 'Pasta',
          calories: 131,
          protein: 5,
          carbs: 25,
          fat: 1.1,
          fiber: 1.8,
          servingSize: '100g cocida',
          source: 'USDA',
          category: 'grains',
          confidence: 0.86,
          lastUpdated: DateTime.now(),
        ),
        'tomato': FoodNutritionData(
          name: 'Tomate',
          calories: 18,
          protein: 0.9,
          carbs: 3.9,
          fat: 0.2,
          fiber: 1.2,
          servingSize: '1 medium (123g)',
          source: 'USDA',
          category: 'vegetables',
          confidence: 0.91,
          lastUpdated: DateTime.now(),
        ),
        'onion': FoodNutritionData(
          name: 'Cebolla',
          calories: 40,
          protein: 1.1,
          carbs: 9,
          fat: 0.1,
          fiber: 1.7,
          servingSize: '100g',
          source: 'USDA',
          category: 'vegetables',
          confidence: 0.89,
          lastUpdated: DateTime.now(),
        ),
        'garlic': FoodNutritionData(
          name: 'Ajo',
          calories: 149,
          protein: 6.4,
          carbs: 33,
          fat: 0.5,
          fiber: 2.1,
          servingSize: '100g',
          source: 'USDA',
          category: 'vegetables',
          confidence: 0.87,
          lastUpdated: DateTime.now(),
        ),
        'carrot': FoodNutritionData(
          name: 'Zanahoria',
          calories: 41,
          protein: 0.9,
          carbs: 10,
          fat: 0.2,
          fiber: 2.8,
          servingSize: '1 medium (61g)',
          source: 'USDA',
          category: 'vegetables',
          confidence: 0.94,
          lastUpdated: DateTime.now(),
        ),
        'potato': FoodNutritionData(
          name: 'Papas',
          calories: 77,
          protein: 2,
          carbs: 17,
          fat: 0.1,
          fiber: 2.2,
          servingSize: '1 medium (173g)',
          source: 'USDA',
          category: 'vegetables',
          confidence: 0.90,
          lastUpdated: DateTime.now(),
        ),
        'fish': FoodNutritionData(
          name: 'Pescado blanco',
          calories: 90,
          protein: 19,
          carbs: 0,
          fat: 1,
          fiber: 0,
          servingSize: '100g',
          source: 'USDA',
          category: 'fish',
          confidence: 0.88,
          lastUpdated: DateTime.now(),
        ),
        'lentils': FoodNutritionData(
          name: 'Lentejas',
          calories: 116,
          protein: 9,
          carbs: 20,
          fat: 0.4,
          fiber: 8,
          servingSize: '100g cocidas',
          source: 'USDA',
          category: 'legumes',
          confidence: 0.86,
          lastUpdated: DateTime.now(),
        ),
        'beans': FoodNutritionData(
          name: 'Frijoles',
          calories: 127,
          protein: 8.7,
          carbs: 23,
          fat: 0.5,
          fiber: 6.5,
          servingSize: '100g cocidos',
          source: 'USDA',
          category: 'legumes',
          confidence: 0.85,
          lastUpdated: DateTime.now(),
        ),
        'cheese': FoodNutritionData(
          name: 'Queso cheddar',
          calories: 402,
          protein: 23,
          carbs: 1.3,
          fat: 33,
          fiber: 0,
          servingSize: '100g',
          source: 'USDA',
          category: 'dairy',
          confidence: 0.91,
          lastUpdated: DateTime.now(),
        ),
        'orange': FoodNutritionData(
          name: 'Naranja',
          calories: 47,
          protein: 0.9,
          carbs: 12,
          fat: 0.1,
          fiber: 2.4,
          servingSize: '1 medium (131g)',
          source: 'USDA',
          category: 'fruits',
          confidence: 0.92,
          lastUpdated: DateTime.now(),
        ),
        'lemon': FoodNutritionData(
          name: 'Limón',
          calories: 29,
          protein: 1.1,
          carbs: 9,
          fat: 0.3,
          fiber: 2.8,
          servingSize: '1 fruit (58g)',
          source: 'USDA',
          category: 'fruits',
          confidence: 0.88,
          lastUpdated: DateTime.now(),
        ),
        'grapes': FoodNutritionData(
          name: 'Uvas',
          calories: 69,
          protein: 0.7,
          carbs: 18,
          fat: 0.2,
          fiber: 0.9,
          servingSize: '1 cup (151g)',
          source: 'USDA',
          category: 'fruits',
          confidence: 0.89,
          lastUpdated: DateTime.now(),
        ),
        'strawberries': FoodNutritionData(
          name: 'Fresas',
          calories: 32,
          protein: 0.7,
          carbs: 8,
          fat: 0.3,
          fiber: 2,
          servingSize: '1 cup (152g)',
          source: 'USDA',
          category: 'fruits',
          confidence: 0.94,
          lastUpdated: DateTime.now(),
        ),
        'blueberries': FoodNutritionData(
          name: 'Arándanos',
          calories: 57,
          protein: 0.7,
          carbs: 14,
          fat: 0.3,
          fiber: 2.4,
          servingSize: '1 cup (148g)',
          source: 'USDA',
          category: 'fruits',
          confidence: 0.93,
          lastUpdated: DateTime.now(),
        ),
        'walnuts': FoodNutritionData(
          name: 'Nueces',
          calories: 654,
          protein: 15,
          carbs: 14,
          fat: 65,
          fiber: 6.7,
          servingSize: '1 oz (28g)',
          source: 'USDA',
          category: 'nuts',
          confidence: 0.90,
          lastUpdated: DateTime.now(),
        ),
        'coffee': FoodNutritionData(
          name: 'Café',
          calories: 2,
          protein: 0.3,
          carbs: 0,
          fat: 0,
          fiber: 0,
          servingSize: '1 taza (240ml)',
          source: 'USDA',
          category: 'beverages',
          confidence: 0.95,
          lastUpdated: DateTime.now(),
        ),
        'tea': FoodNutritionData(
          name: 'Té verde',
          calories: 1,
          protein: 0,
          carbs: 0,
          fat: 0,
          fiber: 0,
          servingSize: '1 taza (240ml)',
          source: 'USDA',
          category: 'beverages',
          confidence: 0.92,
          lastUpdated: DateTime.now(),
        ),
        'chocolate': FoodNutritionData(
          name: 'Chocolate negro',
          calories: 546,
          protein: 5,
          carbs: 60,
          fat: 31,
          fiber: 7,
          servingSize: '100g',
          source: 'USDA',
          category: 'sweets',
          confidence: 0.85,
          lastUpdated: DateTime.now(),
        ),
      };
      
      final result = mockResponses[normalizedName];
      if (result != null) {
        AppLogger.food('USDA mock data for $foodName -> $normalizedName');
        return result;
      }
      
      AppLogger.error('USDA search failed for: $foodName', tag: 'FOOD');
      return null;
    } catch (e) {
      AppLogger.error('USDA search failed', error: e, tag: 'FOOD');
      return null;
    }
  }

  /// Normaliza el nombre del alimento (español -> inglés)
  String _normalizeFoodName(String foodName) {
    final normalized = foodName.toLowerCase().trim();
    
    // Mapeo español -> inglés
    final Map<String, String> translationMap = {
      'manzana': 'apple',
      'pollo': 'chicken breast',
      'pechuga de pollo': 'chicken breast',
      'brocoli': 'broccoli',
      'brócoli': 'broccoli',
      'arroz integral': 'brown rice',
      'arroz': 'rice',
      'huevo': 'eggs',
      'huevos': 'eggs',
      'leche': 'milk',
      'platano': 'banana',
      'plátano': 'banana',
      'salmon': 'salmon',
      'salmón': 'salmon',
      'aguacate': 'avocado',
      'almendra': 'almonds',
      'almendras': 'almonds',
      'quinoa': 'quinoa',
      'batata': 'sweet potato',
      'batata dulce': 'sweet potato',
      'espinaca': 'spinach',
      'espinacas': 'spinach',
      'avena': 'oats',
      'yogur': 'yogurt',
      'yogur griego': 'yogurt',
      'carne': 'beef',
      'carne de res': 'beef',
      'pan': 'bread',
      'pan integral': 'bread',
      'pasta': 'pasta',
      'tomate': 'tomato',
      'cebolla': 'onion',
      'ajo': 'garlic',
      'zanahoria': 'carrot',
      'papa': 'potato',
      'papas': 'potato',
      'pescado': 'fish',
      'lenteja': 'lentils',
      'lentejas': 'lentils',
      'frijol': 'beans',
      'frijoles': 'beans',
      'queso': 'cheese',
      'naranja': 'orange',
      'limon': 'lemon',
      'limón': 'lemon',
      'uva': 'grapes',
      'uvas': 'grapes',
      'fresa': 'strawberries',
      'fresas': 'strawberries',
      'arandano': 'blueberries',
      'arándanos': 'blueberries',
      'nuez': 'walnuts',
      'nueces': 'walnuts',
      'cafe': 'coffee',
      'café': 'coffee',
      'te': 'tea',
      'té': 'tea',
      'chocolate': 'chocolate',
      'helado': 'ice cream',
      'galletas': 'cookies',
      'pastel': 'cake',
      'croissant': 'croissant',
      'pizza': 'pizza',
      'hamburguesa': 'hamburger',
      'ensalada': 'salad',
      'sushi': 'sushi',
      'agua': 'water',
    };
    
    return translationMap[normalized] ?? normalized;
  }

  /// Busca en Nutritionix Database (simulado)
  Future<FoodNutritionData?> _searchNutritionix(String foodName) async {
    try {
      // Simular request HTTP real
      await Future.delayed(const Duration(milliseconds: 600));
      
      // Normalizar nombre (español -> inglés)
      final normalizedName = _normalizeFoodName(foodName);
      
      // Mock responses - en producción sería request a la API real
      final mockResponses = {
        'salmon': FoodNutritionData(
          name: 'Salmón salvaje',
          calories: 208,
          protein: 20,
          carbs: 0,
          fat: 13,
          fiber: 0,
          servingSize: '100g',
          source: 'Nutritionix',
          category: 'fish',
          confidence: 0.91,
          lastUpdated: DateTime.now(),
        ),
        'avocado': FoodNutritionData(
          name: 'Aguacate',
          calories: 160,
          protein: 2,
          carbs: 9,
          fat: 15,
          fiber: 7,
          servingSize: '1 medium (201g)',
          source: 'Nutritionix',
          category: 'fruits',
          confidence: 0.89,
          lastUpdated: DateTime.now(),
        ),
        'almonds': FoodNutritionData(
          name: 'Almendras',
          calories: 579,
          protein: 21,
          carbs: 22,
          fat: 49,
          fiber: 13,
          servingSize: '1 oz (28g)',
          source: 'Nutritionix',
          category: 'nuts',
          confidence: 0.93,
          lastUpdated: DateTime.now(),
        ),
        'quinoa': FoodNutritionData(
          name: 'Quinoa cocida',
          calories: 120,
          protein: 4.4,
          carbs: 21,
          fat: 1.9,
          fiber: 2.8,
          servingSize: '1 cup (185g)',
          source: 'Nutritionix',
          category: 'grains',
          confidence: 0.87,
          lastUpdated: DateTime.now(),
        ),
      };
      
      final result = mockResponses[normalizedName];
      if (result != null) {
        AppLogger.food('Nutritionix mock data for $foodName -> $normalizedName');
        return result;
      }
      
      AppLogger.error('Nutritionix search failed for: $foodName', tag: 'FOOD');
      return null;
    } catch (e) {
      AppLogger.error('Nutritionix search failed', error: e, tag: 'FOOD');
      return null;
    }
  }

  /// Busca en Healthline Nutrition (simulado)
  Future<FoodNutritionData?> _searchHealthline(String foodName) async {
    try {
      // Simular request HTTP real
      await Future.delayed(const Duration(milliseconds: 700));
      
      // Normalizar nombre (español -> inglés)
      final normalizedName = _normalizeFoodName(foodName);
      
      // Mock responses - en producción sería request a la API real
      final mockResponses = {
        'sweet potato': FoodNutritionData(
          name: 'Batata dulce',
          calories: 86,
          protein: 1.6,
          carbs: 20,
          fat: 0.1,
          fiber: 2.2,
          servingSize: '1 medium (128g)',
          source: 'Healthline',
          category: 'vegetables',
          confidence: 0.85,
          lastUpdated: DateTime.now(),
        ),
        'spinach': FoodNutritionData(
          name: 'Espinacas',
          calories: 23,
          protein: 2.9,
          carbs: 3.6,
          fat: 0.4,
          fiber: 2.2,
          servingSize: '1 cup (30g)',
          source: 'Healthline',
          category: 'vegetables',
          confidence: 0.88,
          lastUpdated: DateTime.now(),
        ),
        'oats': FoodNutritionData(
          name: 'Avena cocida',
          calories: 154,
          protein: 5.3,
          carbs: 27,
          fat: 2.8,
          fiber: 4,
          servingSize: '1 cup cooked (154g)',
          source: 'Healthline',
          category: 'grains',
          confidence: 0.82,
          lastUpdated: DateTime.now(),
        ),
      };
      
      final result = mockResponses[normalizedName];
      if (result != null) {
        AppLogger.food('Healthline mock data for $foodName -> $normalizedName');
        return result;
      }
      
      AppLogger.error('Healthline search failed for: $foodName', tag: 'FOOD');
      return null;
    } catch (e) {
      AppLogger.error('Healthline search failed', error: e, tag: 'FOOD');
      return null;
    }
  }

  /// Obtiene estadísticas del cache
  Map<String, dynamic> getCacheStats() {
    return {
      'totalItems': _cache.length,
      'sizeInBytes': _cache.toString().length,
      'categories': _cache.values.map((data) => data.category).toSet().toList(),
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  /// Limpia el cache
  void clearCache() {
    _cache.clear();
    AppLogger.food('Cache cleared');
  }
}

/// Extensión para serialización
extension FoodNutritionDataExtension on FoodNutritionData {
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'servingSize': servingSize,
      'source': source,
      'category': category,
      'confidence': confidence,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}