import 'dart:async';
import '../Model/ai_message.dart';
import '../Model/user.dart';
import '../Model/shopping_list.dart';
import 'ai_agent_base.dart';

/// Agente Especialista en Nutrición y Dietética
/// "Dra. Elena Martínez" - Nutrition Expert
class NutritionAgent extends AIAgentBase {
  NutritionAgent()
      : super(
          id: 'nutrition_expert_001',
          name: 'Dra. Elena Martínez',
          type: 'nutrition',
          description:
              'Especialista en nutrición clínica y dietética aplicada al fitness. Más de 15 años de experiencia ayudando a personas a alcanzar sus objetivos de salud a través de la alimentación.',
          specialization: 'Nutrición y Dietética',
          capabilities: [
            'Planificación de dietas personalizadas',
            'Cálculo de macros y calorías',
            'Análisis de valor nutricional',
            'Recomendaciones de suplementación',
            'Educación nutricional',
            'Gestión de alergias e intolerancias',
            'Creación de listas de compras saludables',
          ],
        );

  @override
  Future<List<AIAgentMessage>> generateRecommendations(
    User user, {
    Map<String, dynamic>? context,
    int count = 3,
  }) async {
    // Generar recomendaciones nutricionales personalizadas
    final recommendations = <AIAgentMessage>[];

    // Obtener datos de progreso si están disponibles
    final progress = context?['progress'] as Map<String, dynamic>?;

    for (int i = 0; i < count; i++) {
      final message = createMessage(
        content: _generateNutritionTip(user, progress, i),
        type: MessageType.recommendation,
        metadata: {
          'category': 'nutrition',
          'priority': i == 0 ? 'high' : 'medium',
          'userGoal': user.fitnessGoal,
        },
        suggestions: [
          'Explain this recommendation in more detail',
          'Give me a meal example',
          'Create a meal plan for this',
        ],
      );
      recommendations.add(message);
    }

    return recommendations;
  }

  String _generateNutritionTip(
      User user, Map<String, dynamic>? progress, int index) {
    final tips = [
      '''
💡 **Optimiza tu distribución de macronutrientes**

Para tu objetivo de "${user.fitnessGoal}", te recomiendo:

• **Proteínas**: ${(user.targetCalories * 0.3 / 4).round()}g (30%)
• **Carbohidratos**: ${(user.targetCalories * 0.4 / 4).round()}g (40%)
• **Grasas**: ${(user.targetCalories * 0.3 / 9).round()}g (30%)

¿Te gustaría que te prepare un plan de comidas detallado?
''',
      '''
🥗 **La importancia de las proteínas en el desayuno**

Comenzar el día con 25-30g de proteína en el desayuno puede:
- Mejorar el control del apetito
- Estabilizar los niveles de energía
- Apoyar la recuperación muscular

Ejemplo: 3 huevos + 150g de griego + 30g de almendras.
''',
      '''
💧 **Hidratación y rendimiento**

Estás bebiendo suficiente agua? 
Tu requerimiento diario es aproximadamente: ${(user.weight * 35).round()}ml

La deshidratación incluso leve puede afectar tu rendimiento en el gym hasta un 20%.
''',
    ];

    return tips[index % tips.length];
  }

  @override
  Future<AIAgentMessage> analyzeUserData(
    User user, {
    required String dataType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    switch (dataType) {
      case 'nutrition':
        return _analyzeNutritionHabits(user);
      case 'meal_log':
        return _analyzeMealLog(user);
      case 'progress':
        return _analyzeProgress(user);
      default:
        return createMessage(
          content: 'No tengo datos de tipo "$dataType" para analizar en este momento.',
          type: MessageType.text,
        );
    }
  }

  Future<AIAgentMessage> _analyzeNutritionHabits(User user) async {
    // Simular análisis de hábitos nutricionales
    final message = createMessage(
      content: '''
📊 **Análisis de Nutricional Personalizado**

Basado en tu perfil:
- Objetivo: ${user.fitnessGoal}
- Calorías diarias: ${user.targetCalories}
- Restricciones: ${user.dietaryPreferences.isNotEmpty ? user.dietaryPreferences.join(', ') : 'Ninguna'}
- Alergias: ${user.allergies.isNotEmpty ? user.allergies.join(', ') : 'Ninguna'}

**Puntuación Nutricional: 85/100** ✅

Áreas de mejora:
1. Aumentar consumo de proteínas vegetales
2. Incluir más omega-3 en tu dieta
3. Reducir azúcares refinados

¿Quieres que genere un plan de acción específico?
''',
      type: MessageType.insight,
      metadata: {'score': 85, 'category': 'nutrition'},
      suggestions: [
        'Show me a detailed meal plan',
        'What foods should I eat more of?',
        'Create a shopping list',
      ],
    );

    return message;
  }

  Future<AIAgentMessage> _analyzeMealLog(User user) async {
    final message = createMessage(
      content: '''
📋 **Análisis del Registro de Comidas**

He revisado tu registro de comidas de la última semana:

**Patrón detectado:**
- Desayuno: Inconsistente (50% de los días)
- Almuerzo: Regular (90% de los días)
- cena: Excess tarde (60% de los días)

**Recomendación:**
Establece horarios fijos para tus comidas.
Considera un snack saludable a las 4 PM para evitar hunger at night.

**Próximos pasos:**
1. Planificar el desayuno la noche anterior
2. Preparar snacks saludables
3. Establecer horario de cena antes de las 9 PM
''',
      type: MessageType.insight,
      metadata: {'analyzedDays': 7, 'score': 72},
    );

    return message;
  }

  Future<AIAgentMessage> _analyzeProgress(User user) async {
    final message = createMessage(
      content: '''
📈 **Reporte de Progreso Nutricional**

**Esta semana:**
- Adherencia al plan: 78%
- Calorías promedio: ${user.targetCalories - 150} kcal
- Consistency score: 8/10

**Logros:**
✅ Cumples con tu objetivo de proteínas
✅ Buena hidratación
⚠️ Necesitas mejorar el consumo de vegetales

**Sugerencia para la próxima semana:**
Incremente el consumo de vegetales a 3 porciones diarias.
¿Quieres que te prepare una lista de compras?
''',
      type: MessageType.insight,
      metadata: {'week': 3, 'adherence': 78},
    );

    return message;
  }

  @override
  Future<String> respondToCoordination(AgentCoordinationRequest request) async {
    switch (request.requestType) {
      case 'nutrition_plan':
        return _handleNutritionPlanRequest(request);
      case 'meal_recommendation':
        return _handleMealRecommendation(request);
      case 'calorie_check':
        return _handleCalorieCheck(request);
      case 'shopping_list':
        return _handleShoppingListRequest(request);
      default:
        return 'Solicitud de coordinación no reconocida: ${request.requestType}';
    }
  }

  String _handleNutritionPlanRequest(AgentCoordinationRequest request) {
    final userData = request.data['user'] as Map<String, dynamic>;
    final goal = userData['fitnessGoal'] ?? 'general_health';

    return '''
He creado un plan nutricional para el objetivo: "$goal"

**Resumen del plan:**
- Duración: 7 días
- Calorías diarias: ${request.data['targetCalories'] ?? userData['targetCalories']} kcal
- Distribución: 30% proteína, 40% carbs, 30% grasa

**Fases del plan:**
1. Día 1-2: Transición y limpieza
2. Día 3-5: Implementación completa
3. Día 6-7: Ajuste y optimización

¿Te gustaría que detalle el plan para cada día?
''';
  }

  String _handleMealRecommendation(AgentCoordinationRequest request) {
    final mealType = request.data['mealType'] ?? 'snack';

    return '''
Aquí tienes una recomendación de $mealType balanceada:

🍽️ **Opción recomendada:**
- Pechuga de pollo a la plancha (150g)
- Arroz integral (100g cocido)
- Ensalada mixta con aderezo ligero
- Fruta de temporada

**Valor nutricional:**
- Calorías: ~450 kcal
- Proteína: 35g
- Carbohidratos: 45g
- Grasa: 12g

¿Te gustaría alternativas para esta comida?
''';
  }

  String _handleCalorieCheck(AgentCoordinationRequest request) {
    final calories = request.data['calories'] ?? 0;
    final target = request.data['targetCalories'] ?? 2000;
    final remaining = target - calories;

    return '''
**Control de Calorías:**

Consumido: $calories kcal
Objetivo: $target kcal
Restante: $remaining kcal

${remaining < 0 ? '⚠️ Has excedido tu objetivo diario.' : remaining < 200 ? '🎯 Muy cerca de tu objetivo!' : '✅ Estas dentro del presupuesto.'}

${remaining > 0 ? 'Te recomiendo una comida ligera para terminar el día.' : 'Te sugiero un entrenamiento para compensar el exceso.'}
''';
  }

  String _handleShoppingListRequest(AgentCoordinationRequest request) {
    final userData = request.data['user'] as User;
    final preferences = userData.dietaryPreferences;

    return '''
📝 **Lista de Compras Inteligente**

Basado en tu plan y preferencias (${preferences.join(', ')}):

**Proteínas:**
- Pechuga de pollo: 1kg
- Salmón fresco: 500g
- Huevos: 2 docenas
- Greek yogurt: 1kg

**Carbohidratos complejos:**
- Arroz integral: 2kg
- Avena: 1kg
- Patatas dulces: 1kg
- Pan integral: 1 unidad

**Verduras y frutas:**
- Brócoli: 2 unidades
- Espinacas: 300g
- Manzana: 6 unidades
- Plátano: 6 unidades

**Grasas saludables:**
- Aguacate: 3 unidades
- Almendras: 500g
- Aceite de oliva extra virgen: 1L

¿Quieres que guarde esta lista en tu perfil?
''';
  }

  /// Genera una lista de compras inteligente basada en el plan nutricional
  Future<ShoppingList> generateSmartShoppingList(
      User user, List<String> meals) async {
    final items = <ShoppingItem>[];
    final now = DateTime.now();

    // Agregar items base para cada comida
    for (final meal in meals) {
      items.addAll(_getItemsForMeal(meal));
    }

    // Filtrar por preferencias y alergias
    final filteredItems = _filterByPreferences(items, user);

    return ShoppingList(
      userId: user.id,
      name: 'Lista de compras - ${now.day}/${now.month}/${now.year}',
      date: now,
    )..items = filteredItems;
  }

  List<ShoppingItem> _getItemsForMeal(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'desayuno':
        return [
          ShoppingItem(
            name: 'Huevos',
            category: 'proteinas',
            quantity: 6,
            unit: 'unidades',
            price: 2.50,
          ),
          ShoppingItem(
            name: 'Avena',
            category: 'carbohidratos',
            quantity: 500,
            unit: 'g',
            price: 3.00,
          ),
          ShoppingItem(
            name: 'Plátano',
            category: 'frutas',
            quantity: 5,
            unit: 'unidades',
            price: 1.50,
          ),
        ];
      case 'almuerzo':
      case 'cena':
        return [
          ShoppingItem(
            name: 'Pechuga de pollo',
            category: 'proteinas',
            quantity: 500,
            unit: 'g',
            price: 6.00,
          ),
          ShoppingItem(
            name: 'Arroz integral',
            category: 'carbohidratos',
            quantity: 1000,
            unit: 'g',
            price: 3.50,
          ),
          ShoppingItem(
            name: 'Brócoli',
            category: 'verduras',
            quantity: 2,
            unit: 'unidades',
            price: 2.00,
          ),
        ];
      default:
        return [
          ShoppingItem(
            name: 'Yogur griego',
            category: 'lacteos',
            quantity: 500,
            unit: 'g',
            price: 4.00,
          ),
          ShoppingItem(
            name: 'Almendras',
            category: 'frutos_secos',
            quantity: 200,
            unit: 'g',
            price: 5.00,
          ),
        ];
    }
  }

  List<ShoppingItem> _filterByPreferences(
      List<ShoppingItem> items, User user) {
    return items.where((item) {
      // Filtrar por alergias
      for (final allergy in user.allergies) {
        if (item.name.toLowerCase().contains(allergy.toLowerCase())) {
          return false;
        }
      }
      return true;
    }).toList();
  }
}
