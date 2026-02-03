import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Servicio de reconocimiento de comida usando TensorFlow Lite (LOCAL)
/// Funciona 100% offline - no requiere conexión a internet
/// Modelo: MobileNetV1 con etiquetas ImageNet (1000 clases)
class FoodRecognitionService {
  static final FoodRecognitionService _instance = FoodRecognitionService._internal();
  factory FoodRecognitionService() => _instance;
  FoodRecognitionService._internal();

  Interpreter? _interpreter;
  bool _isInitialized = false;
  bool _useDemoMode = false;
  List<String> _labels = [];

  // Ruta del archivo de etiquetas ImageNet
  static const String labelsPath = 'assets/models/labels_mobilenet_quant_v1_224.txt';
  static const String modelPath = 'assets/models/mobilenet_v1_1.0_224_quant.tflite';

  // Mapeo de clases de COMIDA de ImageNet a valores nutricionales
  // Solo incluye clases que son alimentos
  static const Map<String, Map<String, double>> _nutritionDatabase = {
    // Comidas rápidas y snacks
    'pizza': {'calories': 285, 'protein': 12, 'carbs': 36, 'fat': 10, 'fiber': 2},
    'hamburger': {'calories': 295, 'protein': 17, 'carbs': 30, 'fat': 12, 'fiber': 1},
    'hotdog': {'calories': 290, 'protein': 10, 'carbs': 25, 'fat': 17, 'fiber': 1},
    'cheeseburger': {'calories': 303, 'protein': 15, 'carbs': 30, 'fat': 14, 'fiber': 1},
    
    // Comida asiática
    'sushi': {'calories': 150, 'protein': 5, 'carbs': 28, 'fat': 1, 'fiber': 1},
    'potstickers': {'calories': 200, 'protein': 8, 'carbs': 28, 'fat': 6, 'fiber': 1},
    'ramen': {'calories': 440, 'protein': 16, 'carbs': 65, 'fat': 14, 'fiber': 2},
    
    // Postres
    'ice_cream': {'calories': 207, 'protein': 3.5, 'carbs': 24, 'fat': 11, 'fiber': 0.7},
    'chocolate_cake': {'calories': 370, 'protein': 4, 'carbs': 52, 'fat': 16, 'fiber': 2},
    'cheesecake': {'calories': 320, 'protein': 6, 'carbs': 32, 'fat': 19, 'fiber': 0.5},
    'carrot_cake': {'calories': 410, 'protein': 4, 'carbs': 55, 'fat': 20, 'fiber': 2},
    'cupcake': {'calories': 350, 'protein': 3, 'carbs': 52, 'fat': 14, 'fiber': 1},
    'doughnut': {'calories': 450, 'protein': 4, 'carbs': 55, 'fat': 23, 'fiber': 1},
    'croissant': {'calories': 406, 'protein': 8, 'carbs': 46, 'fat': 21, 'fiber': 2},
    'waffle': {'calories': 290, 'protein': 7, 'carbs': 45, 'fat': 9, 'fiber': 1},
    'pancake': {'calories': 250, 'protein': 6, 'carbs': 38, 'fat': 8, 'fiber': 1},
    'french_toast': {'calories': 320, 'protein': 10, 'carbs': 45, 'fat': 11, 'fiber': 2},
    
    // Bebidas y recipientes
    'coffee_mug': {'calories': 5, 'protein': 0.3, 'carbs': 0.9, 'fat': 0, 'fiber': 0},
    'cup': {'calories': 0, 'protein': 0, 'carbs': 0, 'fat': 0, 'fiber': 0},
    'wine_bottle': {'calories': 83, 'protein': 0.1, 'carbs': 2.6, 'fat': 0, 'fiber': 0},
    'beer_bottle': {'calories': 43, 'protein': 0.5, 'carbs': 3.6, 'fat': 0, 'fiber': 0},
    'beer_glass': {'calories': 43, 'protein': 0.5, 'carbs': 3.6, 'fat': 0, 'fiber': 0},
    'red_wine': {'calories': 85, 'protein': 0.1, 'carbs': 2.6, 'fat': 0, 'fiber': 0},
    'eggnog': {'calories': 130, 'protein': 4, 'carbs': 12, 'fat': 6, 'fiber': 0},
    
    // Frutas
    'orange': {'calories': 62, 'protein': 1.2, 'carbs': 15, 'fat': 0.2, 'fiber': 3.1},
    'lemon': {'calories': 29, 'protein': 1.1, 'carbs': 9, 'fat': 0.3, 'fiber': 2.8},
    'banana': {'calories': 89, 'protein': 1.1, 'carbs': 23, 'fat': 0.3, 'fiber': 2.6},
    'pineapple': {'calories': 50, 'protein': 0.5, 'carbs': 13, 'fat': 0.1, 'fiber': 1.4},
    'apple': {'calories': 52, 'protein': 0.3, 'carbs': 14, 'fat': 0.2, 'fiber': 2.4},
    'strawberry': {'calories': 32, 'protein': 0.7, 'carbs': 7.7, 'fat': 0.3, 'fiber': 2},
    'grapes': {'calories': 69, 'protein': 0.7, 'carbs': 18, 'fat': 0.2, 'fiber': 0.9},
    'watermelon': {'calories': 30, 'protein': 0.6, 'carbs': 8, 'fat': 0.2, 'fiber': 0.4},
    'peach': {'calories': 39, 'protein': 0.9, 'carbs': 10, 'fat': 0.3, 'fiber': 1.5},
    'pear': {'calories': 57, 'protein': 0.4, 'carbs': 15, 'fat': 0.1, 'fiber': 3.1},
    'mango': {'calories': 60, 'protein': 0.8, 'carbs': 15, 'fat': 0.4, 'fiber': 1.6},
    'pomegranate': {'calories': 83, 'protein': 1.7, 'carbs': 19, 'fat': 1.2, 'fiber': 4},
    
    // Verduras
    'broccoli': {'calories': 34, 'protein': 2.8, 'carbs': 7, 'fat': 0.4, 'fiber': 2.6},
    'cauliflower': {'calories': 25, 'protein': 1.9, 'carbs': 5, 'fat': 0.3, 'fiber': 2},
    'carrot': {'calories': 41, 'protein': 0.9, 'carbs': 10, 'fat': 0.2, 'fiber': 2.8},
    'cucumber': {'calories': 15, 'protein': 0.7, 'carbs': 3.6, 'fat': 0.1, 'fiber': 0.5},
    'bell_pepper': {'calories': 31, 'protein': 1, 'carbs': 6, 'fat': 0.3, 'fiber': 2.1},
    'mushroom': {'calories': 22, 'protein': 3.1, 'carbs': 3.3, 'fat': 0.3, 'fiber': 1},
    'corn': {'calories': 86, 'protein': 3.2, 'carbs': 19, 'fat': 1.2, 'fiber': 2.7},
    'potato': {'calories': 77, 'protein': 2, 'carbs': 17, 'fat': 0.1, 'fiber': 2.2},
    'sweet_potato': {'calories': 86, 'protein': 1.6, 'carbs': 20, 'fat': 0.1, 'fiber': 3},
    'onion': {'calories': 40, 'protein': 1.1, 'carbs': 9, 'fat': 0.1, 'fiber': 1.7},
    'garlic': {'calories': 149, 'protein': 6.4, 'carbs': 33, 'fat': 0.5, 'fiber': 2.1},
    'tomato': {'calories': 18, 'protein': 0.9, 'carbs': 3.9, 'fat': 0.2, 'fiber': 1.2},
    'cabbage': {'calories': 25, 'protein': 1.3, 'carbs': 6, 'fat': 0.1, 'fiber': 2.5},
    'lettuce': {'calories': 15, 'protein': 1.4, 'carbs': 2.9, 'fat': 0.2, 'fiber': 1.3},
    'spinach': {'calories': 23, 'protein': 2.9, 'carbs': 3.6, 'fat': 0.4, 'fiber': 2.2},
    'celery': {'calories': 14, 'protein': 0.7, 'carbs': 3, 'fat': 0.2, 'fiber': 1.6},
    'asparagus': {'calories': 20, 'protein': 2.2, 'carbs': 3.9, 'fat': 0.1, 'fiber': 2.1},
    'zucchini': {'calories': 17, 'protein': 1.2, 'carbs': 3.1, 'fat': 0.3, 'fiber': 1},
    'pumpkin': {'calories': 26, 'protein': 1, 'carbs': 6.5, 'fat': 0.1, 'fiber': 0.5},
    
    // Carnes y proteínas
    'steak': {'calories': 250, 'protein': 26, 'carbs': 0, 'fat': 17, 'fiber': 0},
    'meatloaf': {'calories': 240, 'protein': 18, 'carbs': 12, 'fat': 14, 'fiber': 1},
    'roast': {'calories': 280, 'protein': 26, 'carbs': 0, 'fat': 19, 'fiber': 0},
    'barbecue': {'calories': 290, 'protein': 23, 'carbs': 8, 'fat': 19, 'fiber': 0},
    'ham': {'calories': 145, 'protein': 21, 'carbs': 1.5, 'fat': 6, 'fiber': 0},
    'bacon': {'calories': 541, 'protein': 37, 'carbs': 1.4, 'fat': 42, 'fiber': 0},
    'sausage': {'calories': 301, 'protein': 12, 'carbs': 2, 'fat': 27, 'fiber': 0},
    'chicken': {'calories': 165, 'protein': 31, 'carbs': 0, 'fat': 3.6, 'fiber': 0},
    'chicken_wing': {'calories': 290, 'protein': 27, 'carbs': 0, 'fat': 19, 'fiber': 0},
    'turkey': {'calories': 189, 'protein': 29, 'carbs': 0, 'fat': 7, 'fiber': 0},
    'salmon': {'calories': 208, 'protein': 20, 'carbs': 0, 'fat': 13, 'fiber': 0},
    'tuna': {'calories': 132, 'protein': 28, 'carbs': 0, 'fat': 1, 'fiber': 0},
    'lobster': {'calories': 89, 'protein': 19, 'carbs': 0, 'fat': 0.9, 'fiber': 0},
    'crab': {'calories': 97, 'protein': 20, 'carbs': 0, 'fat': 1.5, 'fiber': 0},
    'shrimp': {'calories': 99, 'protein': 24, 'carbs': 0.2, 'fat': 0.3, 'fiber': 0},
    'oyster': {'calories': 81, 'protein': 9, 'carbs': 4.2, 'fat': 3, 'fiber': 0},
    'egg': {'calories': 155, 'protein': 13, 'carbs': 1.1, 'fat': 11, 'fiber': 0},
    
    // Pan y productos de panadería
    'bread': {'calories': 265, 'protein': 9, 'carbs': 49, 'fat': 3.2, 'fiber': 2.7},
    'bagel': {'calories': 250, 'protein': 10, 'carbs': 49, 'fat': 1.5, 'fiber': 2},
    'pretzel': {'calories': 380, 'protein': 10, 'carbs': 79, 'fat': 3, 'fiber': 3},
    'baguette': {'calories': 270, 'protein': 9, 'carbs': 52, 'fat': 1, 'fiber': 2},
    'muffin': {'calories': 375, 'protein': 6, 'carbs': 53, 'fat': 16, 'fiber': 2},
    
    // Lácteos
    'cheese': {'calories': 402, 'protein': 25, 'carbs': 1.3, 'fat': 33, 'fiber': 0},
    'milk': {'calories': 61, 'protein': 3.2, 'carbs': 4.8, 'fat': 3.3, 'fiber': 0},
    'yogurt': {'calories': 59, 'protein': 10, 'carbs': 3.6, 'fat': 0.4, 'fiber': 0},
    'icecream': {'calories': 207, 'protein': 3.5, 'carbs': 24, 'fat': 11, 'fiber': 0.7},
    'butter': {'calories': 717, 'protein': 0.9, 'carbs': 0.1, 'fat': 81, 'fiber': 0},
    'cream': {'calories': 340, 'protein': 2.1, 'carbs': 2.8, 'fat': 36, 'fiber': 0},
    
    // Pasta y granos
    'spaghetti': {'calories': 158, 'protein': 5.8, 'carbs': 31, 'fat': 0.9, 'fiber': 1.8},
    'macaroni': {'calories': 371, 'protein': 14, 'carbs': 45, 'fat': 15, 'fiber': 2},
    'noodle': {'calories': 138, 'protein': 4.5, 'carbs': 25, 'fat': 2.1, 'fiber': 1.2},
    'rice': {'calories': 130, 'protein': 2.7, 'carbs': 28, 'fat': 0.3, 'fiber': 0.4},
    'risotto': {'calories': 280, 'protein': 7, 'carbs': 45, 'fat': 8, 'fiber': 1},
    'burrito': {'calories': 290, 'protein': 12, 'carbs': 34, 'fat': 12, 'fiber': 5},
    'taco': {'calories': 210, 'protein': 10, 'carbs': 22, 'fat': 9, 'fiber': 3},
    'enchilada': {'calories': 220, 'protein': 9, 'carbs': 28, 'fat': 9, 'fiber': 4},
    'fajita': {'calories': 200, 'protein': 12, 'carbs': 22, 'fat': 8, 'fiber': 3},
    'quesadilla': {'calories': 380, 'protein': 24, 'carbs': 30, 'fat': 19, 'fiber': 2},
    
    // Sopas y ensaladas
    'soup': {'calories': 120, 'protein': 6, 'carbs': 15, 'fat': 4, 'fiber': 2},
    'stew': {'calories': 180, 'protein': 14, 'carbs': 18, 'fat': 6, 'fiber': 3},
    'salad': {'calories': 80, 'protein': 3, 'carbs': 12, 'fat': 3, 'fiber': 4},
    'coleslaw': {'calories': 152, 'protein': 1, 'carbs': 15, 'fat': 10, 'fiber': 2},
    
    // Snacks
    'french_fries': {'calories': 365, 'protein': 3.4, 'carbs': 48, 'fat': 17, 'fiber': 4},
    'potato_chips': {'calories': 536, 'protein': 7, 'carbs': 53, 'fat': 35, 'fiber': 4.8},
    'popcorn': {'calories': 387, 'protein': 13, 'carbs': 78, 'fat': 4.5, 'fiber': 15},
    'nachos': {'calories': 350, 'protein': 8, 'carbs': 38, 'fat': 19, 'fiber': 4},
    'guacamole': {'calories': 170, 'protein': 2, 'carbs': 8, 'fat': 15, 'fiber': 6},
    'salsa': {'calories': 36, 'protein': 1.5, 'carbs': 7, 'fat': 0.2, 'fiber': 1.4},
    
    // Dulces
    'chocolate': {'calories': 546, 'protein': 4.9, 'carbs': 61, 'fat': 31, 'fiber': 7},
    'candy': {'calories': 400, 'protein': 0, 'carbs': 100, 'fat': 0, 'fiber': 0},
    'cookie': {'calories': 502, 'protein': 7, 'carbs': 64, 'fat': 25, 'fiber': 2},
    'baklava': {'calories': 430, 'protein': 6, 'carbs': 52, 'fat': 23, 'fiber': 2},
  };

  /// Inicializa el servicio cargando el modelo TFLite y las etiquetas
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Cargar etiquetas de ImageNet
      await _loadLabels();
      
      // Intentar cargar el modelo TFLite
      _interpreter = await Interpreter.fromAsset(modelPath);
      _isInitialized = true;
      _useDemoMode = false;
      debugPrint('FoodRecognitionService: Modelo MobileNetV1 cargado exitosamente');
      debugPrint('FoodRecognitionService: ${_labels.length} etiquetas cargadas');
      return true;
    } catch (e) {
      debugPrint('FoodRecognitionService: No se pudo cargar el modelo TFLite: $e');
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
      _labels = labelsData
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();
      debugPrint('FoodRecognitionService: Cargadas ${_labels.length} etiquetas de ImageNet');
    } catch (e) {
      debugPrint('FoodRecognitionService: Error cargando etiquetas: $e');
      _labels = [];
    }
  }

  /// Obtiene información nutricional para una clase de ImageNet
  Map<String, double>? _getNutritionInfo(String label) {
    final normalizedLabel = label.toLowerCase().replaceAll(' ', '_');
    
    // Buscar coincidencia exacta
    if (_nutritionDatabase.containsKey(normalizedLabel)) {
      return _nutritionDatabase[normalizedLabel];
    }
    
    // Buscar coincidencias parciales
    for (final entry in _nutritionDatabase.entries) {
      if (normalizedLabel.contains(entry.key) || entry.key.contains(normalizedLabel)) {
        return entry.value;
      }
    }
    
    return null;
  }

  /// Analiza una imagen y detecta el alimento usando TFLite local
  Future<Map<String, dynamic>?> analyzeFoodImage(XFile xFile) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        return _analyzeWithDemo(xFile);
      }
    }

    // Si estamos en modo demo, usar el fallback
    if (_useDemoMode || _interpreter == null) {
      return _analyzeWithDemo(xFile);
    }

    try {
      // Leer bytes de la imagen
      final bytes = await xFile.readAsBytes();
      
      // Decodificar imagen
      final img.Image? originalImage = img.decodeImage(bytes);
      if (originalImage == null) {
        debugPrint('FoodRecognitionService: No se pudo decodificar la imagen');
        return _analyzeWithDemo(xFile);
      }

      // Redimensionar a 224x224 (tamaño esperado por MobileNetV1)
      final img.Image resizedImage = img.copyResize(
        originalImage,
        width: 224,
        height: 224,
      );

      // Normalizar valores a [0, 1] y preparar input
      // MobileNetV1 espera: [1, 224, 224, 3] (batch, height, width, channels)
      final inputBuffer = Float32List(1 * 224 * 224 * 3);
      int bufferIndex = 0;

      // Obtener bytes de la imagen (formato RGBA)
      final pixelBytes = resizedImage.getBytes();
      
      for (int i = 0; i < pixelBytes.length; i += 4) {
        // RGBA format: R, G, B, A
        inputBuffer[bufferIndex++] = pixelBytes[i] / 255.0;     // R
        inputBuffer[bufferIndex++] = pixelBytes[i + 1] / 255.0; // G
        inputBuffer[bufferIndex++] = pixelBytes[i + 2] / 255.0; // B
        // Ignoramos el canal Alpha (i + 3)
      }

      // Reshape a [1, 224, 224, 3]
      final input = inputBuffer.reshape([1, 224, 224, 3]);

      // Output: [1, 1000] (probabilidades para cada clase de ImageNet)
      final outputBuffer = List.generate(1, (_) => List.filled(1000, 0.0));

      // Ejecutar inferencia
      _interpreter!.run(input, outputBuffer);

      // Obtener probabilidades
      final probabilities = outputBuffer[0];

      // Encontrar la clase con mayor probabilidad
      int maxIndex = 0;
      double maxProbability = probabilities[0];
      for (int i = 1; i < probabilities.length; i++) {
        if (probabilities[i] > maxProbability) {
          maxProbability = probabilities[i];
          maxIndex = i;
        }
      }

      // Obtener nombre del objeto detectado
      String detectedLabel = '';
      if (maxIndex < _labels.length) {
        detectedLabel = _labels[maxIndex];
      } else {
        detectedLabel = 'unknown';
      }

      // Limpiar el nombre (quitar número de clase si existe)
      final cleanLabel = detectedLabel.replaceAll(RegExp(r'^\d+:\s*'), '');
      final displayName = _formatFoodName(cleanLabel);

      // Verificar si es comida
      final nutrition = _getNutritionInfo(cleanLabel);
      
      if (nutrition == null) {
        // No es comida, retornar información indicando esto
        return {
          'name': displayName,
          'isFood': false,
          'confidence': maxProbability,
          'label': cleanLabel,
          'message': 'Se detectó $displayName. Por favor fotografía tu comida.',
        };
      }

      // Es comida, retornar con información nutricional
      return {
        'name': displayName,
        'isFood': true,
        'confidence': maxProbability,
        'calories': nutrition['calories']!.toDouble(),
        'protein': nutrition['protein']!.toDouble(),
        'carbs': nutrition['carbs']!.toDouble(),
        'fat': nutrition['fat']!.toDouble(),
        'fiber': nutrition['fiber']!.toDouble(),
        'label': cleanLabel,
      };

    } catch (e) {
        debugPrint('FoodRecognitionService: Error en análisis TFLite: $e');
      return _analyzeWithDemo(xFile);
    }
  }

  /// Formatea el nombre del alimento para mostrar
  String _formatFoodName(String label) {
    // Reemplazar guiones bajos por espacios y capitalizar
    return label.split('_').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  /// Modo Demo: Simula reconocimiento cuando no hay modelo
  Future<Map<String, dynamic>?> _analyzeWithDemo(XFile xFile) async {
    await Future.delayed(const Duration(seconds: 2));
    
    // Alimentos comunes para demo
    final demoFoods = [
      {'name': 'Pizza', 'calories': 285.0, 'protein': 12.0, 'carbs': 36.0, 'fat': 10.0, 'fiber': 2.0},
      {'name': 'Hamburguesa', 'calories': 295.0, 'protein': 17.0, 'carbs': 30.0, 'fat': 12.0, 'fiber': 1.0},
      {'name': 'Ensalada César', 'calories': 180.0, 'protein': 8.0, 'carbs': 12.0, 'fat': 12.0, 'fiber': 3.0},
      {'name': 'Sushi', 'calories': 150.0, 'protein': 5.0, 'carbs': 28.0, 'fat': 1.0, 'fiber': 1.0},
      {'name': 'Pasta Carbonara', 'calories': 420.0, 'protein': 16.0, 'carbs': 48.0, 'fat': 18.0, 'fiber': 2.0},
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
      'label': 'demo',
    };
  }

  /// Libera recursos del intérprete TFLite
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
    _useDemoMode = false;
    _labels = [];
  }
}
