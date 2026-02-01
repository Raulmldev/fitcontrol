import 'package:uuid/uuid.dart';

/// Modelo de Comida para FitControl
///
/// Representa una comida completa con todos sus alimentos y totales nutricionales.
class Meal {
  String id;
  String userId;
  String name;
  String mealType; // breakfast, lunch, dinner, snack
  DateTime date;
  List<FoodItem> foods;
  double totalCalories;
  double totalProtein;
  double totalCarbs;
  double totalFat;
  double totalFiber;
  String? notes;
  String? imageUrl;
  DateTime createdAt;
  DateTime updatedAt;

  Meal({
    String? id,
    required this.userId,
    required this.name,
    required this.mealType,
    required this.date,
    this.foods = const [],
    this.totalCalories = 0,
    this.totalProtein = 0,
    this.totalCarbs = 0,
    this.totalFat = 0,
    this.totalFiber = 0,
    this.notes,
    this.imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Calcula los totales nutricionales sumando todos los alimentos
  void calculateTotals() {
    totalCalories = foods.fold(0, (sum, food) => sum + food.calories);
    totalProtein = foods.fold(0, (sum, food) => sum + food.protein);
    totalCarbs = foods.fold(0, (sum, food) => sum + food.carbs);
    totalFat = foods.fold(0, (sum, food) => sum + food.fat);
    totalFiber = foods.fold(0, (sum, food) => sum + food.fiber);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'mealType': mealType,
      'date': date.toIso8601String(),
      'foods': foods.map((f) => f.toJson()).toList(),
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
      'totalFiber': totalFiber,
      'notes': notes,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      mealType: json['mealType'],
      date: DateTime.parse(json['date']),
      foods: (json['foods'] as List).map((f) => FoodItem.fromJson(f)).toList(),
      totalCalories: json['totalCalories'].toDouble(),
      totalProtein: json['totalProtein'].toDouble(),
      totalCarbs: json['totalCarbs'].toDouble(),
      totalFat: json['totalFat'].toDouble(),
      totalFiber: json['totalFiber'].toDouble(),
      notes: json['notes'],
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

/// Modelo de Alimento individual
///
/// Representa un alimento específico con sus valores nutricionales por porción.
class FoodItem {
  String id;
  String name;
  double quantity;
  String unit; // g, ml, porcion, etc.
  double calories;
  double protein;
  double carbs;
  double fat;
  double fiber;
  double? sugar;
  double? sodium;
  String? category;

  FoodItem({
    String? id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0,
    this.sugar,
    this.sodium,
    this.category,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
      'category': category,
    };
  }

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'].toDouble(),
      unit: json['unit'],
      calories: json['calories'].toDouble(),
      protein: json['protein'].toDouble(),
      carbs: json['carbs'].toDouble(),
      fat: json['fat'].toDouble(),
      fiber: json['fiber']?.toDouble() ?? 0,
      sugar: json['sugar']?.toDouble(),
      sodium: json['sodium']?.toDouble(),
      category: json['category'],
    );
  }

  @override
  String toString() {
    return 'FoodItem($name: ${quantity.toStringAsFixed(0)}$unit, ${calories.toStringAsFixed(0)} kcal)';
  }
}

/// Modelo de Nutrición Diaria
///
/// Registra el progreso nutricional de un día específico.
class DailyNutrition {
  String id;
  String userId;
  DateTime date;
  double targetCalories;
  double consumedCalories;
  double targetProtein;
  double consumedProtein;
  double targetCarbs;
  double consumedCarbs;
  double targetFat;
  double consumedFat;
  double targetFiber;
  double consumedFiber;
  double waterIntake; // ml
  List<String> mealIds;

  DailyNutrition({
    String? id,
    required this.userId,
    required this.date,
    required this.targetCalories,
    this.consumedCalories = 0,
    required this.targetProtein,
    this.consumedProtein = 0,
    required this.targetCarbs,
    this.consumedCarbs = 0,
    required this.targetFat,
    this.consumedFat = 0,
    required this.targetFiber,
    this.consumedFiber = 0,
    this.waterIntake = 0,
    this.mealIds = const [],
  }) : id = id ?? const Uuid().v4();

  double get caloriesPercentage =>
      targetCalories > 0 ? consumedCalories / targetCalories : 0;
  double get proteinPercentage =>
      targetProtein > 0 ? consumedProtein / targetProtein : 0;
  double get carbsPercentage =>
      targetCarbs > 0 ? consumedCarbs / targetCarbs : 0;
  double get fatPercentage => targetFat > 0 ? consumedFat / targetFat : 0;
  double get fiberPercentage =>
      targetFiber > 0 ? consumedFiber / targetFiber : 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'targetCalories': targetCalories,
      'consumedCalories': consumedCalories,
      'targetProtein': targetProtein,
      'consumedProtein': consumedProtein,
      'targetCarbs': targetCarbs,
      'consumedCarbs': consumedCarbs,
      'targetFat': targetFat,
      'consumedFat': consumedFat,
      'targetFiber': targetFiber,
      'consumedFiber': consumedFiber,
      'waterIntake': waterIntake,
      'mealIds': mealIds,
    };
  }

  factory DailyNutrition.fromJson(Map<String, dynamic> json) {
    return DailyNutrition(
      id: json['id'],
      userId: json['userId'],
      date: DateTime.parse(json['date']),
      targetCalories: json['targetCalories'].toDouble(),
      consumedCalories: json['consumedCalories'].toDouble(),
      targetProtein: json['targetProtein'].toDouble(),
      consumedProtein: json['consumedProtein'].toDouble(),
      targetCarbs: json['targetCarbs'].toDouble(),
      consumedCarbs: json['consumedCarbs'].toDouble(),
      targetFat: json['targetFat'].toDouble(),
      consumedFat: json['consumedFat'].toDouble(),
      targetFiber: json['targetFiber'].toDouble(),
      consumedFiber: json['consumedFiber'].toDouble(),
      waterIntake: json['waterIntake'].toDouble(),
      mealIds: List<String>.from(json['mealIds'] ?? []),
    );
  }
}
