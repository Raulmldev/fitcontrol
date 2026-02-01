import 'package:uuid/uuid.dart';

/// Modelo de Lista de Compras para FitControl
///
/// Gestiona las listas de compras inteligentes basadas en planes de comidas.
class ShoppingList {
  String id;
  String userId;
  String name;
  DateTime date;
  List<ShoppingItem> items;
  bool isCompleted;
  double estimatedBudget;
  double actualCost;
  String store;
  String? notes;
  DateTime createdAt;
  DateTime updatedAt;

  ShoppingList({
    String? id,
    required this.userId,
    required this.name,
    required this.date,
    this.items = const [],
    this.isCompleted = false,
    this.estimatedBudget = 0,
    this.actualCost = 0,
    this.store = '',
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  int get totalItems => items.length;
  int get completedItems => items.where((item) => item.isPurchased).length;
  int get pendingItems => items.where((item) => !item.isPurchased).length;
  double get progress => items.isNotEmpty ? completedItems / items.length : 0.0;

  void calculateTotals() {
    actualCost = items
        .where((item) => item.isPurchased)
        .fold(0, (sum, item) => sum + (item.price ?? 0) * item.quantity);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'date': date.toIso8601String(),
      'items': items.map((i) => i.toJson()).toList(),
      'isCompleted': isCompleted,
      'estimatedBudget': estimatedBudget,
      'actualCost': actualCost,
      'store': store,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    return ShoppingList(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      date: DateTime.parse(json['date']),
      items:
          (json['items'] as List).map((i) => ShoppingItem.fromJson(i)).toList(),
      isCompleted: json['isCompleted'],
      estimatedBudget: json['estimatedBudget'].toDouble(),
      actualCost: json['actualCost'].toDouble(),
      store: json['store'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

/// Modelo de Item de Compra
///
/// Representa un alimento o producto en la lista de compras.
class ShoppingItem {
  String id;
  String name;
  double quantity;
  String unit;
  String category; // frutas, verduras, carnes, lacteos, etc.
  bool isPurchased;
  double? price;
  String? store;
  String? notes;
  int priority; // 1-3 (baja, media, alta)

  ShoppingItem({
    String? id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.category,
    this.isPurchased = false,
    this.price,
    this.store,
    this.notes,
    this.priority = 2,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'category': category,
      'isPurchased': isPurchased,
      'price': price,
      'store': store,
      'notes': notes,
      'priority': priority,
    };
  }

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'].toDouble(),
      unit: json['unit'],
      category: json['category'],
      isPurchased: json['isPurchased'],
      price: json['price']?.toDouble(),
      store: json['store'],
      notes: json['notes'],
      priority: json['priority'],
    );
  }

  @override
  String toString() {
    return '$name: ${quantity.toStringAsFixed(0)} $unit';
  }
}

/// Modelo de Plantilla de Alimento
///
/// Almacena alimentos comunes para reutilización rápida.
class FoodTemplate {
  String id;
  String userId;
  String name;
  String category;
  double defaultQuantity;
  String unit;
  double caloriesPerUnit;
  double proteinPerUnit;
  double carbsPerUnit;
  double fatPerUnit;
  double? fiberPerUnit;
  bool isFavorite;
  DateTime createdAt;

  FoodTemplate({
    String? id,
    required this.userId,
    required this.name,
    required this.category,
    required this.defaultQuantity,
    required this.unit,
    required this.caloriesPerUnit,
    required this.proteinPerUnit,
    required this.carbsPerUnit,
    required this.fatPerUnit,
    this.fiberPerUnit,
    this.isFavorite = false,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'category': category,
      'defaultQuantity': defaultQuantity,
      'unit': unit,
      'caloriesPerUnit': caloriesPerUnit,
      'proteinPerUnit': proteinPerUnit,
      'carbsPerUnit': carbsPerUnit,
      'fatPerUnit': fatPerUnit,
      'fiberPerUnit': fiberPerUnit,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FoodTemplate.fromJson(Map<String, dynamic> json) {
    return FoodTemplate(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      category: json['category'],
      defaultQuantity: json['defaultQuantity'].toDouble(),
      unit: json['unit'],
      caloriesPerUnit: json['caloriesPerUnit'].toDouble(),
      proteinPerUnit: json['proteinPerUnit'].toDouble(),
      carbsPerUnit: json['carbsPerUnit'].toDouble(),
      fatPerUnit: json['fatPerUnit'].toDouble(),
      fiberPerUnit: json['fiberPerUnit']?.toDouble(),
      isFavorite: json['isFavorite'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  @override
  String toString() {
    return '$name (${caloriesPerUnit.toStringAsFixed(0)} kcal/$unit)';
  }
}
