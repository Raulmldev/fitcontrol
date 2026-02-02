import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../Config/api_config.dart';

/// Servicio de reconocimiento de comida usando Google Gemini Pro Vision
/// ✅ Tiene capacidad de visión REAL - puede analizar imágenes
/// Requiere API Key de Google AI Studio (gratis hasta cierto límite)
class FoodRecognitionService {
  static final FoodRecognitionService _instance = FoodRecognitionService._internal();
  factory FoodRecognitionService() => _instance;
  FoodRecognitionService._internal();

  // API de Google Gemini (soporta visión de imágenes)
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://generativelanguage.googleapis.com/v1beta',
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  bool _isInitialized = false;

  /// Inicializa el servicio
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    if (ApiConfig.geminiApiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      print('FoodRecognitionService: Gemini API Key no configurada');
      return false;
    }
    
    _isInitialized = true;
    return true;
  }

  /// Analiza una imagen y detecta el alimento usando visión REAL
  Future<Map<String, dynamic>?> analyzeFoodImage(XFile xFile) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        // Si no hay API key, usar modo demo
        return _analyzeWithDemo(xFile);
      }
    }

    try {
      // Leer imagen y convertir a base64
      final bytes = await xFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      final response = await _dio.post(
        '/models/gemini-pro-vision:generateContent?key=${ApiConfig.geminiApiKey}',
        data: {
          'contents': [
            {
              'parts': [
                {
                  'text': '''Analiza esta imagen de comida y proporciona la información nutricional.
                  
Responde ÚNICAMENTE en formato JSON:
{
  "name": "Nombre del plato identificado",
  "confidence": 0.95,
  "calories": 350,
  "protein": 25,
  "carbs": 45,
  "fat": 12,
  "fiber": 8,
  "description": "Breve descripción de lo que ves"
}'''
                },
                {
                  'inline_data': {
                    'mime_type': 'image/jpeg',
                    'data': base64Image,
                  }
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.2,
            'maxOutputTokens': 500,
          }
        },
      );

      if (response.statusCode == 200) {
        final text = response.data['candidates'][0]['content']['parts'][0]['text'];
        
        // Extraer JSON
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
        if (jsonMatch != null) {
          final result = jsonDecode(jsonMatch.group(0)!);
          
          return {
            'name': result['name'] ?? 'Plato Identificado',
            'confidence': (result['confidence'] ?? 0.8).toDouble(),
            'calories': (result['calories'] ?? 250).toDouble(),
            'protein': (result['protein'] ?? 12).toDouble(),
            'carbs': (result['carbs'] ?? 30).toDouble(),
            'fat': (result['fat'] ?? 10).toDouble(),
            'fiber': (result['fiber'] ?? 2).toDouble(),
          };
        }
      }

      return null;
    } catch (e) {
      print('FoodRecognitionService: Error - $e');
      // Fallback a modo demo
      return _analyzeWithDemo(xFile);
    }
  }

  /// Modo Demo: Simula reconocimiento (funciona sin API key)
  Future<Map<String, dynamic>?> _analyzeWithDemo(XFile xFile) async {
    await Future.delayed(const Duration(seconds: 2));
    
    // Datos realistas de ejemplo
    return {
      'name': 'Plato Detectado (Modo Demo)',
      'confidence': 0.85,
      'calories': 420.0,
      'protein': 28.0,
      'carbs': 45.0,
      'fat': 15.0,
      'fiber': 6.0,
    };
  }

  void dispose() {
    _isInitialized = false;
  }
}
