import 'package:flutter/material.dart';
import '../Model/meal.dart';
import '../Model/user.dart';

class NutritionController extends ChangeNotifier {
  User? _user;

  User? get user => _user;

  // State
  final List<Meal> _todayMeals = [];
  DailyNutrition? _dailyNutrition;

  // Getters
  List<Meal> get todayMeals => _todayMeals;
  DailyNutrition? get dailyNutrition => _dailyNutrition;

  // Computed values
  double get totalCalories => _dailyNutrition?.consumedCalories ?? 0;
  double get totalProtein => _dailyNutrition?.consumedProtein ?? 0;
  double get totalCarbs => _dailyNutrition?.consumedCarbs ?? 0;
  double get totalFat => _dailyNutrition?.consumedFat ?? 0;

  NutritionController();

  void setUser(User user) {
    _user = user;
    _initializeDay();
  }

  void _initializeDay() {
    if (_user == null) return;

    // In a real app, we would load from DB here
    _dailyNutrition = DailyNutrition(
      userId: _user!.id,
      date: DateTime.now(),
      targetCalories: _user!.targetCalories.toDouble(),
      targetProtein: (_user!.targetCalories * 0.30) / 4, // 30% protein
      targetCarbs: (_user!.targetCalories * 0.40) / 4, // 40% carbs
      targetFat: (_user!.targetCalories * 0.30) / 9, // 30% fat
      targetFiber: 30,
    );
    notifyListeners();
  }

  void addMeal(Meal meal) {
    _todayMeals.add(meal);
    _recalculateTotals();
    notifyListeners();
  }

  void deleteMeal(String mealId) {
    _todayMeals.removeWhere((m) => m.id == mealId);
    _recalculateTotals();
    notifyListeners();
  }

  void _recalculateTotals() {
    if (_dailyNutrition == null) return;

    double cal = 0;
    double prot = 0;
    double carbs = 0;
    double fat = 0;
    double fiber = 0;

    for (var meal in _todayMeals) {
      cal += meal.totalCalories;
      prot += meal.totalProtein;
      carbs += meal.totalCarbs;
      fat += meal.totalFat;
      fiber += meal.totalFiber;
    }

    _dailyNutrition!.consumedCalories = cal;
    _dailyNutrition!.consumedProtein = prot;
    _dailyNutrition!.consumedCarbs = carbs;
    _dailyNutrition!.consumedFat = fat;
    _dailyNutrition!.consumedFiber = fiber;
    _dailyNutrition!.mealIds = _todayMeals.map((m) => m.id).toList();
  }

  // Mock method to add example data (useful for testing)
  void loadMockData() {
    if (_user == null) return;

    final breakfast = Meal(
      userId: _user!.id,
      name: 'Desayuno',
      mealType: 'breakfast',
      date: DateTime.now(),
      foods: [
        FoodItem(
          name: 'Avena',
          quantity: 50,
          unit: 'g',
          calories: 190,
          protein: 6,
          carbs: 33,
          fat: 3,
        ),
        FoodItem(
          name: 'Leche',
          quantity: 200,
          unit: 'ml',
          calories: 120,
          protein: 8,
          carbs: 12,
          fat: 5,
        ),
      ],
    )..calculateTotals();

    addMeal(breakfast);
  }
}
