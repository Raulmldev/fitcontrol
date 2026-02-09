import 'package:flutter_test/flutter_test.dart';
import 'package:fitcontrol/Control/nutrition_controller.dart';
import 'package:fitcontrol/Control/food_search_service.dart';
import 'package:fitcontrol/Model/user.dart';
import 'package:fitcontrol/Model/meal.dart';

void main() {
  group('Food Scraping and Registration Flow', () {
    late NutritionController controller;
    late FoodSearchService searchService;
    late User testUser;

    setUp(() {
      controller = NutritionController();
      searchService = FoodSearchService();
      testUser = User(
        id: 'user123',
        name: 'Test User',
        email: 'test@example.com',
        birthDate: DateTime(1996, 1, 1),
        height: 175,
        weight: 70,
        gender: 'male',
        activityLevel: 'moderate',
        fitnessGoal: 'maintain',
        targetCalories: 2000,
        dietaryPreferences: [],
        healthConditions: [],
      );
      controller.setUser(testUser);
    });

    test('Search for existing food (Banana) returns correct data', () async {
      final results = await searchService.searchFood('banana');
      expect(results, isNotEmpty);
      final banana = results.first;

      expect(banana.name, 'Banana');
      expect(banana.calories, 105);
      expect(banana.protein, 1.3);
      expect(banana.carbs, 27);
      expect(banana.fat, 0.4);
    });

    test('Search for unknown food returns web result placeholder', () async {
      final query = 'Pizza';
      final results = await searchService.searchFood(query);
      expect(results, isNotEmpty);
      final result = results.first;

      expect(result.name, contains('Web Result'));
      expect(result.name, contains(query));
      // Default checks based on current implementation
      expect(result.calories, 100);
    });

    test('Adding scraped food to meal updates controller', () async {
      // 1. Search
      final results = await searchService.searchFood('arroz');
      final foodItem = results.first;

      // 2. Create Meal
      final meal = Meal(
        userId: testUser.id,
        name: 'Almuerzo Test',
        mealType: 'lunch',
        date: DateTime.now(),
        foods: [foodItem],
      )..calculateTotals();

      // 3. Add to Controller
      controller.addMeal(meal);

      // 4. Verify
      expect(controller.todayMeals.length, 1);
      expect(controller.todayMeals.first.name, 'Almuerzo Test');
      expect(controller.totalCalories, foodItem.calories);
      expect(controller.totalCarbs, foodItem.carbs);
    });
  });
}
