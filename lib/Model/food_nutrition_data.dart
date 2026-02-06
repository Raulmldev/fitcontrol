/// Modelo de Datos Nutricionales de Alimentos para FitControl
///
/// Contiene información completa sobre valor nutricional de un alimento
/// incluyendo datos de confianza, fuente y metadatos.
class FoodNutritionData {
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double? sugar;
  final double? sodium;
  final String servingSize;
  final String source;
  final String category;
  final double confidence;
  final DateTime lastUpdated;

  FoodNutritionData({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    this.sugar,
    this.sodium,
    required this.servingSize,
    required this.source,
    required this.category,
    required this.confidence,
    required this.lastUpdated,
  });

  /// Crea desde JSON
  factory FoodNutritionData.fromJson(Map<String, dynamic> json) {
    return FoodNutritionData(
      name: json['name'] as String,
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      fiber: (json['fiber'] as num).toDouble(),
      sugar: json['sugar'] != null ? (json['sugar'] as num).toDouble() : null,
      sodium: json['sodium'] != null ? (json['sodium'] as num).toDouble() : null,
      servingSize: json['servingSize'] as String,
      source: json['source'] as String,
      category: json['category'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
      'servingSize': servingSize,
      'source': source,
      'category': category,
      'confidence': confidence,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  String get confidenceLabel {
    if (confidence >= 0.9) return 'Alta Confianza';
    if (confidence >= 0.7) return 'Confianza Media';
    return 'Baja Confianza';
  }

  @override
  String toString() {
    return 'FoodNutritionData(name: $name, calories: $calories, source: $source, confidence: ${(confidence * 100).toStringAsFixed(0)}%)';
  }
}