import 'package:flutter/material.dart';
import '../Model/health_metrics.dart';
import '../Model/user.dart';

class HealthController extends ChangeNotifier {
  User? _user;
  List<HealthMetrics> _history = [];
  HealthMetrics? _latestMetrics;

  User? get user => _user;
  List<HealthMetrics> get history => List.unmodifiable(_history);
  HealthMetrics? get latestMetrics => _latestMetrics;

  void setUser(User user) {
    _user = user;
    // In a real app, we would load data from a database here
    _loadMockData();
  }

  void addMetrics(HealthMetrics metrics) {
    _history.insert(0, metrics);
    _latestMetrics = metrics;
    notifyListeners();
  }

  void _loadMockData() {
    if (_user == null) return;

    // Create some dummy history
    final now = DateTime.now();
    _history = [
      HealthMetrics(
        userId: _user!.id,
        date: now,
        heartRate: 72,
        bloodPressureSystolic: 120,
        bloodPressureDiastolic: 80,
        weight: _user!.weight,
        sleepHours: 7,
        waterPercentage: 60,
        stressLevel: 3,
      ),
      HealthMetrics(
        userId: _user!.id,
        date: now.subtract(const Duration(days: 1)),
        heartRate: 70,
        bloodPressureSystolic: 118,
        bloodPressureDiastolic: 78,
        weight: _user!.weight,
        sleepHours: 8,
        waterPercentage: 62,
        stressLevel: 2,
      ),
      HealthMetrics(
        userId: _user!.id,
        date: now.subtract(const Duration(days: 2)),
        heartRate: 75,
        bloodPressureSystolic: 122,
        bloodPressureDiastolic: 82,
        weight: _user!.weight + 0.2,
        sleepHours: 6,
        waterPercentage: 58,
        stressLevel: 5,
      ),
    ];
    _latestMetrics = _history.first;
    notifyListeners();
  }
}
