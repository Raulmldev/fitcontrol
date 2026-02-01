import 'package:flutter_test/flutter_test.dart';

import 'package:fitcontrol/main.dart';

void main() {
  testWidgets('Login screen displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('FitControl'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsOneWidget);
  });
}
