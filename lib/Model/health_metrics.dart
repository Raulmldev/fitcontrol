import 'package:uuid/uuid.dart';

/// Modelo de Métricas de Salud para FitControl
///
/// Registra todos los parámetros vitales y corporales del usuario.
class HealthMetrics {
  String id;
  String userId;
  DateTime date;

  // Parámetros vitales
  double? heartRate; // BPM
  double? bloodPressureSystolic; // mmHg
  double? bloodPressureDiastolic; // mmHg
  double? bodyTemperature; // °C
  double? bloodOxygen; // %
  double? respiratoryRate; // respiraciones por minuto

  // Parámetros corporales
  double weight; // kg
  double? bodyFat; // %
  double? muscleMass; // kg
  double? boneMass; // kg
  double? waterPercentage; // %
  double? visceralFat; // nivel 1-30
  double? bmi;

  // Medidas corporales (cm)
  double? chest;
  double? waist;
  double? hips;
  double? neck;
  double? biceps;
  double? forearm;
  double? thigh;
  double? calf;
  double? shoulder;

  // Parámetros de salud adicionales
  int? sleepHours;
  int? sleepQuality; // 1-10
  int? stressLevel; // 1-10
  int? energyLevel; // 1-10
  int? mood; // 1-10
  String? notes;
  DateTime createdAt;

  HealthMetrics({
    String? id,
    required this.userId,
    required this.date,
    this.heartRate,
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.bodyTemperature,
    this.bloodOxygen,
    this.respiratoryRate,
    required this.weight,
    this.bodyFat,
    this.muscleMass,
    this.boneMass,
    this.waterPercentage,
    this.visceralFat,
    this.bmi,
    this.chest,
    this.waist,
    this.hips,
    this.neck,
    this.biceps,
    this.forearm,
    this.thigh,
    this.calf,
    this.shoulder,
    this.sleepHours,
    this.sleepQuality,
    this.stressLevel,
    this.energyLevel,
    this.mood,
    this.notes,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  /// Obtiene la presión arterial como string
  String get bloodPressure {
    if (bloodPressureSystolic != null && bloodPressureDiastolic != null) {
      return '${bloodPressureSystolic!.toInt()}/${bloodPressureDiastolic!.toInt()}';
    }
    return 'N/A';
  }

  /// Obtiene la categoría de presión arterial
  String get bloodPressureCategory {
    if (bloodPressureSystolic == null || bloodPressureDiastolic == null) {
      return 'Desconocida';
    }

    final sys = bloodPressureSystolic!;
    final dia = bloodPressureDiastolic!;

    if (sys < 120 && dia < 80) return 'Normal';
    if (sys < 130 && dia < 80) return 'Elevada';
    if (sys < 140 || dia < 90) return 'Hipertensión Etapa 1';
    if (sys >= 140 || dia >= 90) return 'Hipertensión Etapa 2';
    if (sys > 180 || dia > 120) return 'Crisis Hipertensiva';

    return 'Desconocida';
  }

  /// Calcula la relación cintura-cadera
  double? get waistToHipRatio {
    if (waist != null && hips != null && hips! > 0) {
      return waist! / hips!;
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'heartRate': heartRate,
      'bloodPressureSystolic': bloodPressureSystolic,
      'bloodPressureDiastolic': bloodPressureDiastolic,
      'bodyTemperature': bodyTemperature,
      'bloodOxygen': bloodOxygen,
      'respiratoryRate': respiratoryRate,
      'weight': weight,
      'bodyFat': bodyFat,
      'muscleMass': muscleMass,
      'boneMass': boneMass,
      'waterPercentage': waterPercentage,
      'visceralFat': visceralFat,
      'bmi': bmi,
      'chest': chest,
      'waist': waist,
      'hips': hips,
      'neck': neck,
      'biceps': biceps,
      'forearm': forearm,
      'thigh': thigh,
      'calf': calf,
      'shoulder': shoulder,
      'sleepHours': sleepHours,
      'sleepQuality': sleepQuality,
      'stressLevel': stressLevel,
      'energyLevel': energyLevel,
      'mood': mood,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory HealthMetrics.fromJson(Map<String, dynamic> json) {
    return HealthMetrics(
      id: json['id'],
      userId: json['userId'],
      date: DateTime.parse(json['date']),
      heartRate: json['heartRate']?.toDouble(),
      bloodPressureSystolic: json['bloodPressureSystolic']?.toDouble(),
      bloodPressureDiastolic: json['bloodPressureDiastolic']?.toDouble(),
      bodyTemperature: json['bodyTemperature']?.toDouble(),
      bloodOxygen: json['bloodOxygen']?.toDouble(),
      respiratoryRate: json['respiratoryRate']?.toDouble(),
      weight: json['weight'].toDouble(),
      bodyFat: json['bodyFat']?.toDouble(),
      muscleMass: json['muscleMass']?.toDouble(),
      boneMass: json['boneMass']?.toDouble(),
      waterPercentage: json['waterPercentage']?.toDouble(),
      visceralFat: json['visceralFat']?.toDouble(),
      bmi: json['bmi']?.toDouble(),
      chest: json['chest']?.toDouble(),
      waist: json['waist']?.toDouble(),
      hips: json['hips']?.toDouble(),
      neck: json['neck']?.toDouble(),
      biceps: json['biceps']?.toDouble(),
      forearm: json['forearm']?.toDouble(),
      thigh: json['thigh']?.toDouble(),
      calf: json['calf']?.toDouble(),
      shoulder: json['shoulder']?.toDouble(),
      sleepHours: json['sleepHours'],
      sleepQuality: json['sleepQuality'],
      stressLevel: json['stressLevel'],
      energyLevel: json['energyLevel'],
      mood: json['mood'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

/// Modelo de Objetivo de Salud
///
/// Representa un objetivo específico de salud o fitness.
class HealthGoal {
  String id;
  String userId;
  String type; // weight, bodyfat, muscle, steps, sleep, etc.
  String title;
  String description;
  double targetValue;
  double currentValue;
  double initialValue;
  String unit;
  DateTime startDate;
  DateTime targetDate;
  bool isCompleted;
  DateTime? completedDate;
  DateTime createdAt;
  DateTime updatedAt;

  HealthGoal({
    String? id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    required this.targetValue,
    required this.currentValue,
    required this.initialValue,
    required this.unit,
    required this.startDate,
    required this.targetDate,
    this.isCompleted = false,
    this.completedDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  double get progress {
    if (targetValue == initialValue) return 1.0;
    final totalChange = targetValue - initialValue;
    final currentChange = currentValue - initialValue;
    return (currentChange / totalChange).clamp(0.0, 1.0);
  }

  double get percentage => progress * 100;

  int get daysRemaining {
    return targetDate.difference(DateTime.now()).inDays;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'description': description,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'initialValue': initialValue,
      'unit': unit,
      'startDate': startDate.toIso8601String(),
      'targetDate': targetDate.toIso8601String(),
      'isCompleted': isCompleted,
      'completedDate': completedDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory HealthGoal.fromJson(Map<String, dynamic> json) {
    return HealthGoal(
      id: json['id'],
      userId: json['userId'],
      type: json['type'],
      title: json['title'],
      description: json['description'],
      targetValue: json['targetValue'].toDouble(),
      currentValue: json['currentValue'].toDouble(),
      initialValue: json['initialValue'].toDouble(),
      unit: json['unit'],
      startDate: DateTime.parse(json['startDate']),
      targetDate: DateTime.parse(json['targetDate']),
      isCompleted: json['isCompleted'],
      completedDate:
          json['completedDate'] != null
              ? DateTime.parse(json['completedDate'])
              : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
