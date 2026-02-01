import 'package:uuid/uuid.dart';

/// Modelo de Entrenamiento/Workout para FitControl
///
/// Representa una sesión completa de ejercicio.
class Workout {
  String id;
  String userId;
  String name;
  String type; // cardio, strength, flexibility, sport
  DateTime date;
  int duration; // minutos
  int caloriesBurned;
  int intensity; // 1-5
  List<Exercise> exercises;
  String? notes;
  String? imageUrl;
  DateTime createdAt;
  DateTime updatedAt;

  Workout({
    String? id,
    required this.userId,
    required this.name,
    required this.type,
    required this.date,
    required this.duration,
    this.caloriesBurned = 0,
    this.intensity = 3,
    this.exercises = const [],
    this.notes,
    this.imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'type': type,
      'date': date.toIso8601String(),
      'duration': duration,
      'caloriesBurned': caloriesBurned,
      'intensity': intensity,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'notes': notes,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      type: json['type'],
      date: DateTime.parse(json['date']),
      duration: json['duration'],
      caloriesBurned: json['caloriesBurned'],
      intensity: json['intensity'],
      exercises:
          (json['exercises'] as List).map((e) => Exercise.fromJson(e)).toList(),
      notes: json['notes'],
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

/// Modelo de Ejercicio individual
///
/// Representa un ejercicio específico con sus parámetros.
class Exercise {
  String id;
  String name;
  String category; // chest, back, legs, arms, shoulders, core, cardio
  int sets;
  int reps;
  double? weight; // kg
  int? duration; // segundos
  int restTime; // segundos
  String? notes;

  Exercise({
    String? id,
    required this.name,
    required this.category,
    this.sets = 0,
    this.reps = 0,
    this.weight,
    this.duration,
    this.restTime = 60,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'duration': duration,
      'restTime': restTime,
      'notes': notes,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      sets: json['sets'],
      reps: json['reps'],
      weight: json['weight']?.toDouble(),
      duration: json['duration'],
      restTime: json['restTime'],
      notes: json['notes'],
    );
  }

  @override
  String toString() {
    if (weight != null && weight! > 0) {
      return '$name: $sets x $reps @ ${weight}kg';
    }
    return '$name: $sets x $reps';
  }
}

/// Modelo de Plan de Entrenamiento
///
/// Representa un programa de entrenamiento estructurado.
class WorkoutPlan {
  String id;
  String userId;
  String name;
  String description;
  int durationWeeks;
  int daysPerWeek;
  String difficulty;
  String goal;
  List<WorkoutDay> workoutDays;
  bool isActive;
  DateTime createdAt;
  DateTime updatedAt;

  WorkoutPlan({
    String? id,
    required this.userId,
    required this.name,
    required this.description,
    required this.durationWeeks,
    required this.daysPerWeek,
    required this.difficulty,
    required this.goal,
    this.workoutDays = const [],
    this.isActive = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'durationWeeks': durationWeeks,
      'daysPerWeek': daysPerWeek,
      'difficulty': difficulty,
      'goal': goal,
      'workoutDays': workoutDays.map((d) => d.toJson()).toList(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    return WorkoutPlan(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      description: json['description'],
      durationWeeks: json['durationWeeks'],
      daysPerWeek: json['daysPerWeek'],
      difficulty: json['difficulty'],
      goal: json['goal'],
      workoutDays:
          (json['workoutDays'] as List)
              .map((d) => WorkoutDay.fromJson(d))
              .toList(),
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

/// Modelo de Día de Entrenamiento
///
/// Representa un día específico dentro de un plan.
class WorkoutDay {
  String id;
  int dayOfWeek; // 1-7 (Lunes-Domingo)
  String focus; // pecho, piernas, cardio, etc.
  List<Exercise> exercises;
  int estimatedDuration; // minutos

  WorkoutDay({
    String? id,
    required this.dayOfWeek,
    required this.focus,
    this.exercises = const [],
    required this.estimatedDuration,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dayOfWeek': dayOfWeek,
      'focus': focus,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'estimatedDuration': estimatedDuration,
    };
  }

  factory WorkoutDay.fromJson(Map<String, dynamic> json) {
    return WorkoutDay(
      id: json['id'],
      dayOfWeek: json['dayOfWeek'],
      focus: json['focus'],
      exercises:
          (json['exercises'] as List).map((e) => Exercise.fromJson(e)).toList(),
      estimatedDuration: json['estimatedDuration'],
    );
  }
}
