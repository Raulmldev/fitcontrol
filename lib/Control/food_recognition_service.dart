import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Servicio de reconocimiento de comida usando TensorFlow Lite (LOCAL)
/// Funciona 100% offline - no requiere conexión a internet
/// Modelo: Food-101 classifier procesa imágenes de 224x224 píxeles
class FoodRecognitionService {
  static final FoodRecognitionService _instance = FoodRecognitionService._internal();
  factory FoodRecognitionService() => _instance;
  FoodRecognitionService._internal();

  Interpreter? _interpreter;
  bool _isInitialized = false;
  bool _useDemoMode = false;

  // Lista de 101 alimentos del dataset Food-101
  static const List<String> _foodLabels = [
    'apple_pie', 'baby_back_ribs', 'baklava', 'beef_carpaccio', 'beef_tartare',
    'beet_salad', 'beignets', 'bibimbap', 'bread_pudding', 'breakfast_burrito',
    'bruschetta', 'caesar_salad', 'cannoli', 'caprese_salad', 'carrot_cake',
    'ceviche', 'cheese_plate', 'cheesecake', 'chicken_curry', 'chicken_quesadilla',
    'chicken_wings', 'chocolate_cake', 'chocolate_mousse', 'churros', 'clam_chowder',
    'club_sandwich', 'crab_cakes', 'creme_brulee', 'croque_madame', 'cup_cakes',
    'deviled_eggs', 'donuts', 'dumplings', 'edamame', 'eggs_benedict',
    'escargots', 'falafel', 'filet_mignon', 'fish_and_chips', 'foie_gras',
    'french_fries', 'french_onion_soup', 'french_toast', 'fried_calamari', 'fried_rice',
    'frozen_yogurt', 'garlic_bread', 'gnocchi', 'greek_salad', 'grilled_cheese_sandwich',
    'grilled_salmon', 'guacamole', 'gyoza', 'hamburger', 'hot_and_sour_soup',
    'hot_dog', 'huevos_rancheros', 'hummus', 'ice_cream', 'lasagna',
    'lobster_bisque', 'lobster_roll_sandwich', 'macaroni_and_cheese', 'macarons', 'miso_soup',
    'mussels', 'nachos', 'omelette', 'onion_rings', 'oysters',
    'pad_thai', 'paella', 'pancakes', 'panna_cotta', 'peking_duck',
    'pho', 'pizza', 'pork_chop', 'poutine', 'prime_rib',
    'pulled_pork_sandwich', 'ramen', 'ravioli', 'red_velvet_cake', 'risotto',
    'samosa', 'sashimi', 'scallops', 'seaweed_salad', 'shrimp_and_grits',
    'spaghetti_bolognese', 'spaghetti_carbonara', 'spring_rolls', 'steak', 'strawberry_shortcake',
    'sushi', 'tacos', 'takoyaki', 'tiramisu', 'tuna_tartare',
    'waffles', 'caesar_salad', 'pasta', 'salad', 'soup'
  ];

  // Base de datos nutricional aproximada (calorías por 100g)
  static const Map<String, Map<String, double>> _nutritionDatabase = {
    'apple_pie': {'calories': 265, 'protein': 2.1, 'carbs': 37, 'fat': 12, 'fiber': 1.8},
    'baby_back_ribs': {'calories': 290, 'protein': 23, 'carbs': 0, 'fat': 21, 'fiber': 0},
    'baklava': {'calories': 430, 'protein': 6, 'carbs': 52, 'fat': 23, 'fiber': 2},
    'beef_carpaccio': {'calories': 180, 'protein': 26, 'carbs': 0, 'fat': 8, 'fiber': 0},
    'beef_tartare': {'calories': 180, 'protein': 26, 'carbs': 0, 'fat': 8, 'fiber': 0},
    'beet_salad': {'calories': 85, 'protein': 2, 'carbs': 12, 'fat': 3.5, 'fiber': 3},
    'beignets': {'calories': 350, 'protein': 5, 'carbs': 45, 'fat': 16, 'fiber': 1},
    'bibimbap': {'calories': 490, 'protein': 16, 'carbs': 75, 'fat': 14, 'fiber': 5},
    'bread_pudding': {'calories': 280, 'protein': 7, 'carbs': 42, 'fat': 9, 'fiber': 1},
    'breakfast_burrito': {'calories': 450, 'protein': 18, 'carbs': 48, 'fat': 22, 'fiber': 4},
    'bruschetta': {'calories': 220, 'protein': 5, 'carbs': 28, 'fat': 10, 'fiber': 2},
    'caesar_salad': {'calories': 180, 'protein': 8, 'carbs': 12, 'fat': 12, 'fiber': 3},
    'cannoli': {'calories': 310, 'protein': 5, 'carbs': 38, 'fat': 15, 'fiber': 1},
    'caprese_salad': {'calories': 160, 'protein': 7, 'carbs': 5, 'fat': 13, 'fiber': 1},
    'carrot_cake': {'calories': 410, 'protein': 4, 'carbs': 55, 'fat': 20, 'fiber': 2},
    'ceviche': {'calories': 120, 'protein': 20, 'carbs': 8, 'fat': 2, 'fiber': 1},
    'cheese_plate': {'calories': 350, 'protein': 20, 'carbs': 2, 'fat': 28, 'fiber': 0},
    'cheesecake': {'calories': 320, 'protein': 6, 'carbs': 32, 'fat': 19, 'fiber': 0.5},
    'chicken_curry': {'calories': 290, 'protein': 22, 'carbs': 15, 'fat': 16, 'fiber': 3},
    'chicken_quesadilla': {'calories': 380, 'protein': 24, 'carbs': 30, 'fat': 19, 'fiber': 2},
    'chicken_wings': {'calories': 290, 'protein': 27, 'carbs': 0, 'fat': 19, 'fiber': 0},
    'chocolate_cake': {'calories': 370, 'protein': 4, 'carbs': 52, 'fat': 16, 'fiber': 2},
    'chocolate_mousse': {'calories': 280, 'protein': 5, 'carbs': 32, 'fat': 15, 'fiber': 2},
    'churros': {'calories': 400, 'protein': 4, 'carbs': 58, 'fat': 17, 'fiber': 2},
    'clam_chowder': {'calories': 200, 'protein': 9, 'carbs': 18, 'fat': 10, 'fiber': 1},
    'club_sandwich': {'calories': 340, 'protein': 18, 'carbs': 32, 'fat': 16, 'fiber': 2},
    'crab_cakes': {'calories': 260, 'protein': 16, 'carbs': 15, 'fat': 15, 'fiber': 1},
    'creme_brulee': {'calories': 340, 'protein': 4, 'carbs': 30, 'fat': 22, 'fiber': 0},
    'croque_madame': {'calories': 450, 'protein': 22, 'carbs': 28, 'fat': 28, 'fiber': 1},
    'cup_cakes': {'calories': 350, 'protein': 3, 'carbs': 52, 'fat': 14, 'fiber': 1},
    'deviled_eggs': {'calories': 160, 'protein': 8, 'carbs': 1, 'fat': 13, 'fiber': 0},
    'donuts': {'calories': 450, 'protein': 4, 'carbs': 55, 'fat': 23, 'fiber': 1},
    'dumplings': {'calories': 240, 'protein': 9, 'carbs': 32, 'fat': 8, 'fiber': 1},
    'edamame': {'calories': 120, 'protein': 11, 'carbs': 10, 'fat': 5, 'fiber': 5},
    'eggs_benedict': {'calories': 380, 'protein': 18, 'carbs': 16, 'fat': 27, 'fiber': 1},
    'escargots': {'calories': 90, 'protein': 16, 'carbs': 2, 'fat': 2, 'fiber': 0},
    'falafel': {'calories': 330, 'protein': 13, 'carbs': 32, 'fat': 18, 'fiber': 8},
    'filet_mignon': {'calories': 270, 'protein': 26, 'carbs': 0, 'fat': 18, 'fiber': 0},
    'fish_and_chips': {'calories': 420, 'protein': 16, 'carbs': 45, 'fat': 20, 'fiber': 3},
    'foie_gras': {'calories': 460, 'protein': 11, 'carbs': 4, 'fat': 43, 'fiber': 0},
    'french_fries': {'calories': 365, 'protein': 3.4, 'carbs': 48, 'fat': 17, 'fiber': 4},
    'french_onion_soup': {'calories': 170, 'protein': 9, 'carbs': 18, 'fat': 7, 'fiber': 2},
    'french_toast': {'calories': 320, 'protein': 10, 'carbs': 45, 'fat': 11, 'fiber': 2},
    'fried_calamari': {'calories': 280, 'protein': 18, 'carbs': 22, 'fat': 14, 'fiber': 1},
    'fried_rice': {'calories': 210, 'protein': 5, 'carbs': 32, 'fat': 7, 'fiber': 1},
    'frozen_yogurt': {'calories': 160, 'protein': 4, 'carbs': 30, 'fat': 2, 'fiber': 0},
    'garlic_bread': {'calories': 350, 'protein': 6, 'carbs': 48, 'fat': 15, 'fiber': 2},
    'gnocchi': {'calories': 220, 'protein': 5, 'carbs': 40, 'fat': 5, 'fiber': 2},
    'greek_salad': {'calories': 150, 'protein': 5, 'carbs': 8, 'fat': 12, 'fiber': 3},
    'grilled_cheese_sandwich': {'calories': 380, 'protein': 14, 'carbs': 35, 'fat': 21, 'fiber': 2},
    'grilled_salmon': {'calories': 210, 'protein': 22, 'carbs': 0, 'fat': 13, 'fiber': 0},
    'guacamole': {'calories': 170, 'protein': 2, 'carbs': 8, 'fat': 15, 'fiber': 6},
    'gyoza': {'calories': 200, 'protein': 8, 'carbs': 28, 'fat': 6, 'fiber': 1},
    'hamburger': {'calories': 295, 'protein': 17, 'carbs': 30, 'fat': 12, 'fiber': 1},
    'hot_and_sour_soup': {'calories': 120, 'protein': 6, 'carbs': 15, 'fat': 4, 'fiber': 1},
    'hot_dog': {'calories': 290, 'protein': 10, 'carbs': 25, 'fat': 17, 'fiber': 1},
    'huevos_rancheros': {'calories': 320, 'protein': 14, 'carbs': 35, 'fat': 14, 'fiber': 5},
    'hummus': {'calories': 170, 'protein': 8, 'carbs': 14, 'fat': 9, 'fiber': 6},
    'ice_cream': {'calories': 207, 'protein': 3.5, 'carbs': 24, 'fat': 11, 'fiber': 0.7},
    'lasagna': {'calories': 280, 'protein': 16, 'carbs': 26, 'fat': 12, 'fiber': 2},
    'lobster_bisque': {'calories': 190, 'protein': 9, 'carbs': 14, 'fat': 11, 'fiber': 0},
    'lobster_roll_sandwich': {'calories': 380, 'protein': 18, 'carbs': 32, 'fat': 20, 'fiber': 1},
    'macaroni_and_cheese': {'calories': 370, 'protein': 14, 'carbs': 45, 'fat': 15, 'fiber': 2},
    'macarons': {'calories': 450, 'protein': 7, 'carbs': 72, 'fat': 15, 'fiber': 3},
    'miso_soup': {'calories': 40, 'protein': 3, 'carbs': 5, 'fat': 1, 'fiber': 1},
    'mussels': {'calories': 170, 'protein': 24, 'carbs': 7, 'fat': 4, 'fiber': 0},
    'nachos': {'calories': 350, 'protein': 8, 'carbs': 38, 'fat': 19, 'fiber': 4},
    'omelette': {'calories': 150, 'protein': 12, 'carbs': 1, 'fat': 11, 'fiber': 0},
    'onion_rings': {'calories': 350, 'protein': 4, 'carbs': 45, 'fat': 18, 'fiber': 3},
    'oysters': {'calories': 80, 'protein': 9, 'carbs': 4, 'fat': 3, 'fiber': 0},
    'pad_thai': {'calories': 360, 'protein': 12, 'carbs': 50, 'fat': 12, 'fiber': 2},
    'paella': {'calories': 280, 'protein': 18, 'carbs': 35, 'fat': 8, 'fiber': 2},
    'pancakes': {'calories': 250, 'protein': 6, 'carbs': 38, 'fat': 8, 'fiber': 1},
    'panna_cotta': {'calories': 270, 'protein': 3, 'carbs': 24, 'fat': 18, 'fiber': 0},
    'peking_duck': {'calories': 350, 'protein': 20, 'carbs': 15, 'fat': 24, 'fiber': 0},
    'pho': {'calories': 430, 'protein': 24, 'carbs': 50, 'fat': 12, 'fiber': 2},
    'pizza': {'calories': 285, 'protein': 12, 'carbs': 36, 'fat': 10, 'fiber': 2},
    'pork_chop': {'calories': 250, 'protein': 25, 'carbs': 0, 'fat': 16, 'fiber': 0},
    'poutine': {'calories': 510, 'protein': 16, 'carbs': 55, 'fat': 26, 'fiber': 3},
    'prime_rib': {'calories': 320, 'protein': 26, 'carbs': 0, 'fat': 24, 'fiber': 0},
    'pulled_pork_sandwich': {'calories': 420, 'protein': 28, 'carbs': 38, 'fat': 19, 'fiber': 2},
    'ramen': {'calories': 440, 'protein': 16, 'carbs': 65, 'fat': 14, 'fiber': 2},
    'ravioli': {'calories': 240, 'protein': 9, 'carbs': 32, 'fat': 8, 'fiber': 2},
    'red_velvet_cake': {'calories': 380, 'protein': 4, 'carbs': 56, 'fat': 16, 'fiber': 1},
    'risotto': {'calories': 280, 'protein': 7, 'carbs': 45, 'fat': 8, 'fiber': 1},
    'samosa': {'calories': 270, 'protein': 5, 'carbs': 32, 'fat': 14, 'fiber': 3},
    'sashimi': {'calories': 120, 'protein': 22, 'carbs': 0, 'fat': 3, 'fiber': 0},
    'scallops': {'calories': 110, 'protein': 20, 'carbs': 5, 'fat': 1, 'fiber': 0},
    'seaweed_salad': {'calories': 45, 'protein': 2, 'carbs': 8, 'fat': 0.5, 'fiber': 2},
    'shrimp_and_grits': {'calories': 290, 'protein': 18, 'carbs': 28, 'fat': 12, 'fiber': 1},
    'spaghetti_bolognese': {'calories': 340, 'protein': 18, 'carbs': 42, 'fat': 12, 'fiber': 3},
    'spaghetti_carbonara': {'calories': 420, 'protein': 16, 'carbs': 48, 'fat': 18, 'fiber': 2},
    'spring_rolls': {'calories': 120, 'protein': 4, 'carbs': 20, 'fat': 3, 'fiber': 2},
    'steak': {'calories': 250, 'protein': 26, 'carbs': 0, 'fat': 17, 'fiber': 0},
    'strawberry_shortcake': {'calories': 330, 'protein': 4, 'carbs': 50, 'fat': 12, 'fiber': 2},
    'sushi': {'calories': 150, 'protein': 5, 'carbs': 28, 'fat': 1, 'fiber': 1},
    'tacos': {'calories': 210, 'protein': 10, 'carbs': 22, 'fat': 9, 'fiber': 3},
    'takoyaki': {'calories': 220, 'protein': 8, 'carbs': 28, 'fat': 8, 'fiber': 1},
    'tiramisu': {'calories': 450, 'protein': 6, 'carbs': 45, 'fat': 28, 'fiber': 1},
    'tuna_tartare': {'calories': 140, 'protein': 22, 'carbs': 2, 'fat': 5, 'fiber': 0},
    'waffles': {'calories': 290, 'protein': 7, 'carbs': 45, 'fat': 9, 'fiber': 1},
    'pasta': {'calories': 220, 'protein': 8, 'carbs': 43, 'fat': 1, 'fiber': 2},
    'salad': {'calories': 80, 'protein': 3, 'carbs': 12, 'fat': 3, 'fiber': 4},
    'soup': {'calories': 120, 'protein': 6, 'carbs': 15, 'fat': 4, 'fiber': 2},
  };

  /// Inicializa el servicio cargando el modelo TFLite
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Intentar cargar el modelo TFLite
      _interpreter = await Interpreter.fromAsset('assets/models/food_classifier.tflite');
      _isInitialized = true;
      _useDemoMode = false;
      print('FoodRecognitionService: Modelo TFLite cargado exitosamente');
      return true;
    } catch (e) {
      print('FoodRecognitionService: No se pudo cargar el modelo TFLite: $e');
      print('FoodRecognitionService: Usando modo demo');
      _isInitialized = true;
      _useDemoMode = true;
      return true;
    }
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
        print('FoodRecognitionService: No se pudo decodificar la imagen');
        return _analyzeWithDemo(xFile);
      }

      // Redimensionar a 224x224 (tamaño esperado por el modelo)
      final img.Image resizedImage = img.copyResize(
        originalImage,
        width: 224,
        height: 224,
      );

      // Normalizar valores a [0, 1] y preparar input
      // El modelo espera: [1, 224, 224, 3] (batch, height, width, channels)
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

      // Output: [1, 101] (probabilidades para cada clase de Food-101)
      final outputBuffer = List.generate(1, (_) => List.filled(101, 0.0));

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

      // Obtener nombre del alimento
      final foodLabel = _foodLabels[maxIndex];
      final foodName = _formatFoodName(foodLabel);

      // Obtener información nutricional
      final nutrition = _nutritionDatabase[foodLabel] ?? {
        'calories': 250,
        'protein': 10,
        'carbs': 30,
        'fat': 10,
        'fiber': 2,
      };

      return {
        'name': foodName,
        'confidence': maxProbability,
        'calories': nutrition['calories']!.toDouble(),
        'protein': nutrition['protein']!.toDouble(),
        'carbs': nutrition['carbs']!.toDouble(),
        'fat': nutrition['fat']!.toDouble(),
        'fiber': nutrition['fiber']!.toDouble(),
        'label': foodLabel, // Etiqueta original para referencia
      };

    } catch (e) {
      print('FoodRecognitionService: Error en análisis TFLite: $e');
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
  }
}
