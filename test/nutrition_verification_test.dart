import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fitcontrol/View/nutrition_screen.dart';
import 'package:fitcontrol/Control/nutrition_controller.dart';
import 'package:fitcontrol/Model/user.dart';

void main() {
  testWidgets('NutritionScreen allows adding and deleting a meal', (
    WidgetTester tester,
  ) async {
    // Set screen size to avoid overflows (Tablet size)
    tester.view.physicalSize = const Size(2400, 1800);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // 1. Setup
    final user = User(
      id: 'test_user',
      email: 'test@example.com',
      name: 'Test User',
      birthDate: DateTime(1990, 1, 1),
      gender: 'Masculino',
      weight: 70,
      height: 175,
      targetCalories: 2000,
      activityLevel: 'moderado',
      fitnessGoal: 'Mantenimiento',
      dietaryPreferences: [],
    );

    final nutritionController = NutritionController();
    nutritionController.setUser(user);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<NutritionController>.value(
          value: nutritionController,
          child: NutritionScreen(user: user),
        ),
      ),
    );

    // 2. Verify initial state
    expect(find.text('Nutrición'), findsOneWidget);
    expect(find.text('No hay comidas registradas hoy.'), findsOneWidget);
    expect(find.text('0 / 2000 g/kcal'), findsOneWidget); // Calories progress

    // 3. Add a meal
    await tester.tap(find.text('Registrar Comida'));
    await tester.pumpAndSettle();

    expect(
      find.text('Registrar Comida'),
      findsNWidgets(2),
    ); // AppBar title + Dialog title

    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre (ej. Almuerzo)'),
      'Desayuno Test',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Calorías Totales'),
      '500',
    );

    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    // 4. Verify meal added
    expect(find.text('Desayuno Test'), findsOneWidget);
    expect(find.text('500 kcal'), findsOneWidget);
    expect(find.text('No hay comidas registradas hoy.'), findsNothing);

    // Check if progress updated (500 consumed)
    expect(find.text('500 / 2000 g/kcal'), findsOneWidget);

    // 5. Delete the meal
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    // 6. Verify meal deleted
    expect(find.text('Desayuno Test'), findsNothing);
    expect(find.text('No hay comidas registradas hoy.'), findsOneWidget);
    expect(find.text('0 / 2000 g/kcal'), findsOneWidget);
  });
}
