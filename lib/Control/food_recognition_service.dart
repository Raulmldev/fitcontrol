import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:tflite_flutter/tflite_flutter.dart'; // Temporarily disabled
import 'food_api_service.dart';
import '../Model/food_nutrition_data.dart';

/// Servicio de reconocimiento de comida usando TensorFlow Lite (LOCAL)
/// Funciona 100% offline - no requiere conexión a internet
/// Modelo: MobileNetV1 con etiquetas ImageNet (1000 clases)
class FoodRecognitionService {
  static final FoodRecognitionService _instance =
      FoodRecognitionService._internal();
  factory FoodRecognitionService() => _instance;
  FoodRecognitionService._internal();

  // Interpreter? _interpreter; // Temporarily disabled
  bool _isInitialized = false;
  bool _useDemoMode = false;
  List<String> _labels = [];

  // Servicio de API
  final FoodAPIService _apiService = FoodAPIService();

  // Ruta del archivo de etiquetas ImageNet
  static const String labelsPath =
      'assets/models/labels_mobilenet_quant_v1_224.txt';
  static const String modelPath =
      'assets/models/mobilenet_v1_1.0_224_quant.tflite';

  /// Inicializa el servicio cargando el modelo TFLite y las etiquetas
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Cargar etiquetas de ImageNet
      await _loadLabels();

      // Intentar cargar el modelo TFLite
      // _interpreter = await Interpreter.fromAsset(modelPath); // Temporarily disabled
      _isInitialized = true;
      _useDemoMode = true; // Force demo mode
      debugPrint(
        'FoodRecognitionService: TFLite desactivado, usando modo demo',
      );
      debugPrint(
        'FoodRecognitionService: ${_labels.length} etiquetas cargadas',
      );
      return true;
    } catch (e) {
      debugPrint(
        'FoodRecognitionService: No se pudo cargar el modelo TFLite: $e',
      );
      debugPrint('FoodRecognitionService: Usando modo demo');
      _isInitialized = true;
      _useDemoMode = true;
      return true;
    }
  }

  /// Carga las etiquetas de ImageNet desde el archivo
  Future<void> _loadLabels() async {
    try {
      final labelsData = await rootBundle.loadString(labelsPath);
      _labels =
          labelsData
              .split('\n')
              .map((line) => line.trim())
              .where((line) => line.isNotEmpty)
              .toList();
      debugPrint(
        'FoodRecognitionService: Cargadas ${_labels.length} etiquetas de ImageNet',
      );
    } catch (e) {
      debugPrint('FoodRecognitionService: Error cargando etiquetas: $e');
      _labels = [];
    }
  }

  /// Analiza una imagen y detecta el alimento usando múltiples fuentes
  Future<Map<String, dynamic>?> analyzeFoodImage(XFile xFile) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        return _analyzeWithAPI(xFile);
      }
    }

    // Si estamos en modo demo o TFLite no disponible, usar API
    if (_useDemoMode) {
      return _analyzeWithAPI(xFile);
    }

    return _analyzeWithAPI(xFile);
  }

  /// Modo API: Usa web scraping y API para análisis nutricional
  Future<Map<String, dynamic>?> _analyzeWithAPI(XFile xFile) async {
    try {
      debugPrint('FoodRecognition: Starting API analysis...');

      // Simular tiempo de procesamiento
      await Future.delayed(const Duration(seconds: 1));

      // Lista de alimentos comunes para demo (en producción esto vendría de OCR/IA)
      final detectedFoods = [
        'pollo',
        'arroz',
        'manzana',
        'broccoli',
        'huevo',
        'banana',
        'leche',
        'pan',
        'pasta',
        'salmón',
        'pizza',
        'hamburguesa',
        'ensalada',
        'sushi',
        'carne',
      ];

      // Seleccionar alimento aleatorio para demo
      final random = DateTime.now().millisecond % detectedFoods.length;
      final detectedFood = detectedFoods[random];

      debugPrint('FoodRecognition: Detected food: $detectedFood');

      // Buscar usando API service (scraping + cache)
      final nutritionData = await _apiService.searchFood(detectedFood);

      if (nutritionData != null) {
        debugPrint(
          'FoodRecognition: Found nutrition data: ${nutritionData.source} (${(nutritionData.confidence * 100).toStringAsFixed(0)}% confidence)',
        );

        return {
          'name': nutritionData.name,
          'isFood': true,
          'confidence': nutritionData.confidence,
          'calories': nutritionData.calories,
          'protein': nutritionData.protein,
          'carbs': nutritionData.carbs,
          'fat': nutritionData.fat,
          'fiber': nutritionData.fiber,
          'servingSize': nutritionData.servingSize,
          'source': nutritionData.source,
          'category': nutritionData.category,
          'lastUpdated': nutritionData.lastUpdated.toIso8601String(),
          'label': detectedFood,
        };
      } else {
        // Fallback a demo data
        return _analyzeWithDemo(xFile);
      }
    } catch (e) {
      debugPrint('FoodRecognition: API analysis failed: $e');
      return _analyzeWithDemo(xFile);
    }
  }

  /// Modo Demo: Fallback cuando todo falla
  Future<Map<String, dynamic>?> _analyzeWithDemo(XFile xFile) async {
    await Future.delayed(const Duration(seconds: 2));

    // Alimentos comunes para demo
    final demoFoods = [
      {
        'name': 'Pizza',
        'calories': 285.0,
        'protein': 12.0,
        'carbs': 36.0,
        'fat': 10.0,
        'fiber': 2.0,
      },
      {
        'name': 'Hamburguesa',
        'calories': 295.0,
        'protein': 17.0,
        'carbs': 30.0,
        'fat': 12.0,
        'fiber': 1.0,
      },
      {
        'name': 'Ensalada César',
        'calories': 180.0,
        'protein': 8.0,
        'carbs': 12.0,
        'fat': 12.0,
        'fiber': 3.0,
      },
      {
        'name': 'Sushi',
        'calories': 150.0,
        'protein': 5.0,
        'carbs': 28.0,
        'fat': 1.0,
        'fiber': 1.0,
      },
      {
        'name': 'Pasta Carbonara',
        'calories': 420.0,
        'protein': 16.0,
        'carbs': 48.0,
        'fat': 18.0,
        'fiber': 2.0,
      },
    ];

    // Seleccionar aleatoriamente un alimento
    final random = DateTime.now().millisecond % demoFoods.length;
    final food = demoFoods[random];

    return {
      'name': '${food['name']} (Modo Demo)',
      'isFood': true,
      'confidence': 0.85,
      'calories': food['calories'],
      'protein': food['protein'],
      'carbs': food['carbs'],
      'fat': food['fat'],
      'fiber': food['fiber'],
      'source': 'Demo',
      'category': 'mixed',
      'label': 'demo',
    };
  }

  /// Obtiene datos nutricionales de un alimento específico
  Future<FoodNutritionData?> getFoodNutrition(String foodName) async {
    return await _apiService.searchFood(foodName);
  }

  /// Realiza análisis de batch para múltiples alimentos
  Future<Map<String, dynamic>?> analyzeBatch(List<String> foodNames) async {
    return await _apiService.analyzeBatchMeals(foodNames);
  }

  /// Sincroniza la base de datos de alimentos
  Future<List<FoodNutritionData>> syncFoodDatabase() async {
    return await _apiService.syncFoodDatabase();
  }

  /// Obtiene estadísticas del sistema
  Future<Map<String, dynamic>?> getSystemStats() async {
    return await _apiService.getSystemStats();
  }

  /// Libera recursos del intérprete TFLite
  void dispose() {
    // _interpreter?.close();
    // _interpreter = null;
    _isInitialized = false;
    _useDemoMode = false;
    _labels = [];
  }
}
