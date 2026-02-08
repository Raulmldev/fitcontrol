import 'package:flutter/material.dart';
import '../Model/workout.dart';
import '../Model/user.dart';

class WorkoutController extends ChangeNotifier {
  User? _user;
  Workout? _todayWorkout;
  List<WorkoutDay> _weeklySchedule = [];
  final List<Workout> _workoutHistory = [];

  User? get user => _user;
  Workout? get todayWorkout => _todayWorkout;
  List<WorkoutDay> get weeklySchedule => List.unmodifiable(_weeklySchedule);
  List<Workout> get workoutHistory => List.unmodifiable(_workoutHistory);

  void setUser(User user) {
    _user = user;
    _loadMockData();
  }

  void logWorkout(Workout workout) {
    _workoutHistory.insert(0, workout);
    notifyListeners();
  }

  void _loadMockData() {
    if (_user == null) return;

    // Mock Weekly Schedule
    _weeklySchedule = [
      WorkoutDay(dayOfWeek: 1, focus: 'Full Body', estimatedDuration: 60),
      WorkoutDay(dayOfWeek: 2, focus: 'Cardio + Abs', estimatedDuration: 45),
      WorkoutDay(dayOfWeek: 3, focus: 'Descanso', estimatedDuration: 0),
      WorkoutDay(dayOfWeek: 4, focus: 'Tren Superior', estimatedDuration: 60),
      WorkoutDay(dayOfWeek: 5, focus: 'Tren Inferior', estimatedDuration: 60),
      WorkoutDay(dayOfWeek: 6, focus: 'Actividad Libre', estimatedDuration: 30),
      WorkoutDay(dayOfWeek: 7, focus: 'Descanso', estimatedDuration: 0),
    ];

    // Mock Today's Workout (assuming today is Monday/Day 1 for demo)
    _todayWorkout = Workout(
      userId: _user!.id,
      name: 'Full Body Power',
      type: 'strength',
      date: DateTime.now(),
      duration: 60,
      intensity: 4,
      exercises: [
        Exercise(name: 'Sentadillas', category: 'Legs', sets: 4, reps: 12),
        Exercise(name: 'Flexiones', category: 'Chest', sets: 4, reps: 15),
        Exercise(
          name: 'Remo con Mancuerna',
          category: 'Back',
          sets: 3,
          reps: 12,
        ),
        Exercise(
          name: 'Plancha Abdominal',
          category: 'Core',
          sets: 3,
          duration: 45,
        ), // duration in seconds
      ],
    );

    notifyListeners();
  }

  String getDayName(int day) {
    switch (day) {
      case 1:
        return 'Lunes';
      case 2:
        return 'Martes';
      case 3:
        return 'Miércoles';
      case 4:
        return 'Jueves';
      case 5:
        return 'Viernes';
      case 6:
        return 'Sábado';
      case 7:
        return 'Domingo';
      default:
        return '';
    }
  }
}
