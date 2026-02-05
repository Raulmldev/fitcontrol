import '../Config/app_logger.dart';
import 'food_scraping_service.dart';

/// Servicio de API que sincroniza datos de scraping con almacenamiento
/// y proporciona endpoints para la app
class FoodAPIService {
  static final FoodAPIService _instance = FoodAPIService._internal();
  factory FoodAPIService() => _instance;
  FoodAPIService._internal();

  final FoodScrapingService _scrapingService = FoodScrapingService();
  
  // URLs de API (en producción usarían endpoints reales)
  // static const String _baseUrl = 'https://api.fitcontrol.app/v1';
  // static const String _foodEndpoint = '$_baseUrl/foods';
  // static const String _searchEndpoint = '$_baseUrl/search';
  // static const String _syncEndpoint = '$_baseUrl/sync';

  // Cache local para offline
  final Map<String, dynamic> _localCache = {};

  /// Busca alimento usando múltiples fuentes
  Future<FoodNutritionData?> searchFood(String foodName, {bool forceRefresh = false}) async {
    try {
      // 1. Buscar en cache local primero
      if (!forceRefresh && _localCache.containsKey(foodName.toLowerCase())) {
        final cachedData = _localCache[foodName.toLowerCase()];
        if (cachedData is FoodNutritionData) {
          AppLogger.food('Found in local cache: $foodName');
          return cachedData;
        }
      }

      // 2. Intentar buscar en API remota
      try {
        final remoteData = await _searchRemoteAPI(foodName);
        if (remoteData != null) {
          _localCache[foodName.toLowerCase()] = remoteData;
          return remoteData;
        }
      } catch (e) {
        AppLogger.error('Remote search failed', error: e, tag: 'API');
      }

      // 3. Usar web scraping
      final scrapedData = await _scrapingService.searchFood(foodName);
      if (scrapedData != null) {
        // Guardar en cache local
        _localCache[foodName.toLowerCase()] = scrapedData;
        
        // Sincronizar con API remota async
        _syncToRemoteAPI(scrapedData).catchError((e) {
          AppLogger.error('Sync failed', error: e, tag: 'API');
          return false;
        });
        
        return scrapedData;
      }

      return null;
    } catch (e) {
      AppLogger.error('Error searching', error: e, tag: 'API');
      return null;
    }
  }

  /// Busca en API remota (simulada para demo)
  Future<FoodNutritionData?> _searchRemoteAPI(String foodName) async {
    try {
      // Simular búsqueda en API real
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock response - en producción sería request real
      final mockResponse = _getMockRemoteResponse(foodName);
      if (mockResponse != null) {
        AppLogger.food('Remote API found: $foodName');
        return mockResponse;
      }
    } catch (e) {
      AppLogger.error('Remote API error', error: e, tag: 'API');
    }
    return null;
  }

  /// Sincroniza datos con API remota
  Future<bool> _syncToRemoteAPI(FoodNutritionData foodData) async {
    try {
      // En producción haría POST real a API
      await Future.delayed(const Duration(milliseconds: 300));
      
      AppLogger.api('Synced ${foodData.name} to remote API');
      return true;
    } catch (e) {
      AppLogger.error('Sync error', error: e, tag: 'API');
      return false;
    }
  }

  /// Obtendr batch de alimentos para sincronización masiva
  Future<List<FoodNutritionData>> syncFoodDatabase({int limit = 100}) async {
    try {
      AppLogger.api('Starting database sync (limit: $limit)');
      
      // Lista de alimentos comunes para sincronizar
      final commonFoods = [
        'pollo', 'arroz', 'manzana', 'broccoli', 'huevo',
        'banana', 'leche', 'pan', 'pasta', 'salmón',
        'aguacate', 'yogurt', 'queso', 'tomate', 'zanahoria',
        'carne de res', 'pescado', 'lentejas', 'frijoles', 'patatas',
        'cebolla', 'ajo', 'espinacas', 'lechuga', 'pimientos',
        'naranja', 'limón', 'uvas', 'fresas', 'arándanos',
        'almendras', 'nueces', 'avena', 'quinoa', 'cereal',
        'café', 'té', 'agua', 'jugo', 'refresco',
        'chocolate', 'helado', 'galletas', 'pastel', 'croissant',
      ];

      final results = <FoodNutritionData>[];
      int syncedCount = 0;

      for (final food in commonFoods.take(limit)) {
        final foodData = await _scrapingService.searchFood(food);
        if (foodData != null) {
          results.add(foodData);
          
          // Sincronizar con API remota
          await _syncToRemoteAPI(foodData);
          syncedCount++;
          
          AppLogger.api('Synced ($syncedCount/$limit): ${foodData.name}');
        }
        
        // Pequeña pausa para no sobrecargar
        await Future.delayed(const Duration(milliseconds: 100));
      }

      AppLogger.api('Sync completed. Total synced: $syncedCount');
      return results;
    } catch (e) {
      AppLogger.error('Sync error', error: e, tag: 'API');
      return [];
    }
  }

  /// Realiza análisis de batch para múltiples alimentos
  Future<Map<String, dynamic>> analyzeBatchMeals(List<String> meals) async {
    try {
      final results = <String, dynamic>{
        'meals': <Map<String, dynamic>>[],
        'summary': <String, dynamic>{},
        'timestamp': DateTime.now().toIso8601String(),
      };

      double totalCalories = 0;
      double totalProtein = 0;
      double totalCarbs = 0;
      double totalFat = 0;
      double totalFiber = 0;

      for (final mealName in meals) {
        final foodData = await searchFood(mealName);
        
        final mealData = {
          'name': mealName,
          'nutrition': foodData?.toJson(),
          'found': foodData != null,
        };
        
        results['meals'].add(mealData);
        
        if (foodData != null) {
          totalCalories += foodData.calories;
          totalProtein += foodData.protein;
          totalCarbs += foodData.carbs;
          totalFat += foodData.fat;
          totalFiber += foodData.fiber;
        }
      }

      // Resumen nutricional
      results['summary'] = {
        'totalCalories': totalCalories,
        'totalProtein': totalProtein,
        'totalCarbs': totalCarbs,
        'totalFat': totalFat,
        'totalFiber': totalFiber,
        'mealCount': meals.length,
        'foundCount': results['meals'].where((m) => m['found']).length,
        'averageCaloriesPerMeal': totalCalories / meals.length,
      };

      return results;
    } catch (e) {
      AppLogger.error('Batch analysis error', error: e, tag: 'API');
      return {
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Obtiene estadísticas del sistema
  Future<Map<String, dynamic>> getSystemStats() async {
    try {
      final cacheStats = _scrapingService.getCacheStats();
      final localCacheSize = _localCache.length;
      
      return {
        'cacheStats': cacheStats.toString(),
        'localCacheSize': localCacheSize,
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'healthy',
        'version': '1.0.0',
      };
    } catch (e) {
      AppLogger.error('Stats error', error: e, tag: 'API');
      return {
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'error',
      };
    }
  }

  /// Limpia todos los caches
  void clearAllCaches() {
    _localCache.clear();
    _scrapingService.clearCache();
    AppLogger.api('All caches cleared');
  }

  /// Exporta datos para backup
  Map<String, dynamic> exportData() {
    return {
      'localCache': _localCache.map((k, v) => MapEntry(k, v.toJson())),
      'exportTimestamp': DateTime.now().toIso8601String(),
      'version': '1.0.0',
    };
  }

  /// Importa datos desde backup
  Future<bool> importData(Map<String, dynamic> data) async {
    try {
      final cacheData = data['localCache'] as Map<String, dynamic>?;
      if (cacheData != null) {
        for (final entry in cacheData.entries) {
          if (entry.value is Map<String, dynamic>) {
            final foodData = FoodNutritionData.fromJson(entry.value);
            _localCache[entry.key] = foodData;
          }
        }
        AppLogger.api('Imported ${cacheData.length} items');
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.error('Import error', error: e, tag: 'API');
      return false;
    }
  }

  // Mock responses para demostración
  FoodNutritionData? _getMockRemoteResponse(String foodName) {
    // En producción esto haría request HTTP real
    // Por ahora simula que la API tiene algunos datos extra
    final mockData = {
      'pizza': FoodNutritionData(
        name: 'Pizza',
        calories: 285,
        protein: 12,
        carbs: 36,
        fat: 10,
        fiber: 2,
        servingSize: '1 slice (107g)',
        source: 'Remote API',
        category: 'processed',
        confidence: 0.98,
        lastUpdated: DateTime.now(),
      ),
      'hamburguesa': FoodNutritionData(
        name: 'Hamburguesa',
        calories: 295,
        protein: 17,
        carbs: 30,
        fat: 12,
        fiber: 1,
        servingSize: '1 burger (113g)',
        source: 'Remote API',
        category: 'processed',
        confidence: 0.96,
        lastUpdated: DateTime.now(),
      ),
    };

    return mockData[foodName.toLowerCase()];
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
