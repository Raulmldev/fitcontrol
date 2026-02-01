import 'package:uuid/uuid.dart';

/// Modelo de Usuario para FitControl
///
/// Almacena toda la información del usuario incluyendo datos personales,
/// preferencias dietéticas, y métricas de salud calculadas automáticamente.
class User {
  String id;
  String email;
  String name;
  String? avatarUrl;
  DateTime birthDate;
  String gender;
  double height; // cm
  double weight; // kg
  String activityLevel;
  List<String> dietaryPreferences;
  List<String> allergies;
  List<String> healthConditions;
  String fitnessGoal;
  int targetCalories;
  DateTime createdAt;
  DateTime updatedAt;

  User({
    String? id,
    required this.email,
    required this.name,
    this.avatarUrl,
    required this.birthDate,
    required this.gender,
    required this.height,
    required this.weight,
    required this.activityLevel,
    this.dietaryPreferences = const [],
    this.allergies = const [],
    this.healthConditions = const [],
    required this.fitnessGoal,
    this.targetCalories = 2000,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Calcula la edad del usuario
  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// Calcula el Índice de Masa Corporal (IMC)
  double get bmi {
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  /// Obtiene la categoría del IMC
  String get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue < 18.5) return 'Bajo peso';
    if (bmiValue < 25) return 'Peso normal';
    if (bmiValue < 30) return 'Sobrepeso';
    return 'Obesidad';
  }

  /// Calcula la Tasa Metabólica Basal (TMB) usando Harris-Benedict
  double get bmr {
    if (gender.toLowerCase() == 'masculino' || gender.toLowerCase() == 'male') {
      return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }
  }

  /// Calcula el Gasto Energético Total Diario (TDEE)
  double get tdee {
    final multipliers = {
      'sedentario': 1.2,
      'ligero': 1.375,
      'moderado': 1.55,
      'activo': 1.725,
      'muy_activo': 1.9,
    };
    return bmr * (multipliers[activityLevel.toLowerCase()] ?? 1.55);
  }

  /// Convierte el usuario a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatarUrl': avatarUrl,
      'birthDate': birthDate.toIso8601String(),
      'gender': gender,
      'height': height,
      'weight': weight,
      'activityLevel': activityLevel,
      'dietaryPreferences': dietaryPreferences,
      'allergies': allergies,
      'healthConditions': healthConditions,
      'fitnessGoal': fitnessGoal,
      'targetCalories': targetCalories,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Crea un usuario desde JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      birthDate: DateTime.parse(json['birthDate']),
      gender: json['gender'],
      height: json['height'].toDouble(),
      weight: json['weight'].toDouble(),
      activityLevel: json['activityLevel'],
      dietaryPreferences: List<String>.from(json['dietaryPreferences'] ?? []),
      allergies: List<String>.from(json['allergies'] ?? []),
      healthConditions: List<String>.from(json['healthConditions'] ?? []),
      fitnessGoal: json['fitnessGoal'],
      targetCalories: json['targetCalories'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// Crea una copia del usuario con cambios específicos
  User copyWith({
    String? email,
    String? name,
    String? avatarUrl,
    DateTime? birthDate,
    String? gender,
    double? height,
    double? weight,
    String? activityLevel,
    List<String>? dietaryPreferences,
    List<String>? allergies,
    List<String>? healthConditions,
    String? fitnessGoal,
    int? targetCalories,
  }) {
    return User(
      id: id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      activityLevel: activityLevel ?? this.activityLevel,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      allergies: allergies ?? this.allergies,
      healthConditions: healthConditions ?? this.healthConditions,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      targetCalories: targetCalories ?? this.targetCalories,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, bmi: ${bmi.toStringAsFixed(1)})';
  }
}
