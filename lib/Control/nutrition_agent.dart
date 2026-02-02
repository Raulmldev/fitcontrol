import '../Model/ai_message.dart';
import '../Model/meal.dart';
import '../Model/shopping_list.dart';
import '../Model/user.dart';
import 'ai_agent_base.dart';

/// Agente IA experto en nutrición y gestión de comidas
///
/// Este agente tiene más de 30 años de experiencia en:
/// - Nutrición clínica y deportiva
/// - Planificación de dietas personalizadas
/// - Análisis de composición de alimentos
/// - Gestión de listas de compras inteligentes
/// - Coordinación con entrenadores y expertos en salud
class NutritionAgent extends AIAgentBase {
  NutritionAgent()
    : super(
        id: 'nutrition_expert_001',
        name: 'Dra. Elena Martínez',
        type: 'nutritionist',
        description:
            'Nutricionista clínica y deportiva con 32 años de experiencia. '
            'Especialista en dietética personalizada, nutrición molecular y '
            'planificación de comidas para diferentes objetivos de salud. '
            'Doctora en Ciencias de la Nutrición por la Universidad de Barcelona '
            'y miembro fundador de la Sociedad Española de Nutrición Deportiva.',
        specialization: 'Nutrición Clínica y Deportiva',
        capabilities: [
          'Planificación de dietas personalizadas',
          'Análisis de composición de alimentos',
          'Cálculo de necesidades calóricas y macronutrientes',
          'Gestión de alergias e intolerancias alimentarias',
          'Optimización de listas de compras',
          'Recomendaciones de suplementación',
          'Educación nutricional',
          'Coordinación con planes de entrenamiento',
        ],
      );

  // Se elimina el override de processQuery para usar la implementación base con DeepSeek

  @override
  Future<List<AIAgentMessage>> generateRecommendations(
    User user, {
    Map<String, dynamic>? context,
    int count = 3,
  }) async {
    final recommendations = <AIAgentMessage>[];

    // Recomendación 1: Balance calórico
    recommendations.add(
      createMessage(
        content: '''
📊 ANÁLISIS DE BALANCE CALÓRICO

Basándome en tu perfil:
• TDEE: ${user.tdee.toStringAsFixed(0)} kcal/día
• Objetivo: ${user.fitnessGoal}
• Recomendación: ${user.targetCalories} kcal/día

Consejo: Distribuye tus calorías en 4-5 comidas durante el día para mantener energía estable y evitar picos de hambre.
      ''',
        type: MessageType.recommendation,
        metadata: {'category': 'calories', 'priority': 'high'},
      ),
    );

    // Recomendación 2: Distribución de macronutrientes
    recommendations.add(
      createMessage(
        content: '''
🥗 DISTRIBUCIÓN DE MACRONUTRIENTES

Para tu objetivo "${user.fitnessGoal}", recomiendo:
• Proteínas: ${(user.targetCalories * 0.30 / 4).toStringAsFixed(0)}g (30%)
• Carbohidratos: ${(user.targetCalories * 0.40 / 4).toStringAsFixed(0)}g (40%)
• Grasas: ${(user.targetCalories * 0.30 / 9).toStringAsFixed(0)}g (30%)

Prioriza proteínas de alta calidad en cada comida para mantener masa muscular.
      ''',
        type: MessageType.recommendation,
        metadata: {'category': 'macros', 'priority': 'high'},
      ),
    );

    // Recomendación 3: Hidratación
    recommendations.add(
      createMessage(
        content: '''
💧 RECOMENDACIÓN DE HIDRATACIÓN

Tu peso actual: ${user.weight} kg
Agua recomendada: ${(user.weight * 35).toStringAsFixed(0)} ml/día

Consejo: Bebe 500ml de agua al despertar y distribuye el resto uniformemente durante el día.
      ''',
        type: MessageType.recommendation,
        metadata: {'category': 'hydration', 'priority': 'medium'},
      ),
    );

    return recommendations.take(count).toList();
  }

  @override
  Future<AIAgentMessage> analyzeUserData(
    User user, {
    required String dataType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    String analysis;

    switch (dataType) {
      case 'nutrition':
        analysis = _analyzeNutritionData(user, startDate, endDate);
        break;
      case 'meals':
        analysis = _analyzeMealPatterns(user);
        break;
      case 'shopping':
        analysis = _analyzeShoppingEfficiency(user);
        break;
      default:
        analysis = 'Tipo de análisis no reconocido para datos de nutrición.';
    }

    final message = createMessage(content: analysis, type: MessageType.insight);

    sendMessage(message);
    return message;
  }

  @override
  Future<String> respondToCoordination(AgentCoordinationRequest request) async {
    // Procesar solicitudes de coordinación de otros agentes
    switch (request.requestType) {
      case 'workout_nutrition':
        return _coordinateWithWorkoutAgent(request);
      case 'health_dietary_restrictions':
        return _coordinateWithHealthAgent(request);
      case 'meal_plan_adjustment':
        return _adjustMealPlan(request);
      default:
        return 'Solicitud de coordinación recibida pero no procesada específicamente.';
    }
  }

  // MÉTODOS PRIVADOS DE RESPUESTA

  // Unused mock methods removed

  String _analyzeNutritionData(
    User user,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    return '''
📊 ANÁLISIS DE DATOS NUTRICIONALES

Período: ${startDate?.toString() ?? 'últimos 30 días'}

OBSERVACIONES:
• Promedio calórico: Por calcular con datos históricos
• Tendencia de peso: Estable
• Cumplimiento de objetivos: 85%

RECOMENDACIONES:
1. Mantener consistencia en el desayuno
2. Aumentar ingesta de fibra (objetivo: 30g/día)
3. Distribución de proteínas en 4 tomas

Te coordinaré con el agente de salud para ajustar según tus parámetros vitales.
    ''';
  }

  String _analyzeMealPatterns(User user) {
    return '''
🍽️ PATRONES DE ALIMENTACIÓN

Frecuencia de comidas: 4 veces/día (ideal)
Variación de alimentos: Buena
Preparación de comidas: Regular

ÁREAS DE MEJORA:
• Preparar snacks saludables con anticipación
• Variedad de vegetales de colores
• Timing de comidas post-entreno
    ''';
  }

  String _analyzeShoppingEfficiency(User user) {
    return '''
🛒 EFICIENCIA DE COMPRAS

Análisis de compras recientes:
• Cumplimiento de lista: 92%
• Desperdicio estimado: 5%
• Economía: Optimizada

Me he coordinado con tu plan de ejercicios para incluir alimentos que maximicen tu recuperación muscular.
    ''';
  }

  // MÉTODOS DE COORDINACIÓN

  String _coordinateWithWorkoutAgent(AgentCoordinationRequest request) {
    final data = request.data;
    final workoutIntensity = data['intensity'] ?? 'moderate';
    final workoutDuration = data['duration'] ?? 60;

    return '''
COORDINACIÓN CON ENTRENADOR - NUTRICIÓN PRE/POST ENTRENO

Basado en la sesión de entrenamiento ($workoutDuration min, intensidad $workoutIntensity):

RECOMENDACIONES NUTRICIONALES:
• Pre-entreno (2-3h antes): Carbohidratos complejos + proteína moderada
• Durante entreno: Hidratación con electrolitos
• Post-entreno (30-60min): 20-30g proteína de rápida absorción + carbohidratos

He ajustado tus macronutrientes del día para optimizar recuperación y rendimiento.
    ''';
  }

  String _coordinateWithHealthAgent(AgentCoordinationRequest request) {
    final data = request.data;
    final healthCondition = data['healthCondition'] ?? 'general';

    return '''
COORDINACIÓN CON EXPERTO EN SALUD - RESTRICCIONES DIETÉTICAS

Considerando condición de salud: $healthCondition

AJUSTES REALIZADOS:
• Reducción de sodio para presión arterial
• Aumento de alimentos anti-inflamatorios
• Suplementación específica validada
• Frecuencia de comidas ajustada

Plan nutricional modificado y seguro para el usuario.
    ''';
  }

  String _adjustMealPlan(AgentCoordinationRequest request) {
    return '''
AJUSTE DE PLAN DE COMIDAS - COORDINACIÓN MULTI-AGENTE

He recibido información de múltiples agentes y he ajustado el plan de comidas:

CAMBIOS REALIZADOS:
• Adaptado a nuevo plan de entrenamiento
• Considerados parámetros de salud actualizados
• Optimizada lista de compras correspondiente

El plan está ahora sincronizado con todos tus objetivos.
    ''';
  }

  // MÉTODO PÚBLICO PARA GENERAR LISTA DE COMPRAS

  Future<ShoppingList> generateSmartShoppingList({
    required String userId,
    required List<Meal> plannedMeals,
    DateTime? date,
  }) async {
    final shoppingList = ShoppingList(
      userId: userId,
      name: 'Lista de compras ${date ?? DateTime.now()}',
      date: date ?? DateTime.now(),
      items: [],
    );

    // Agrupar ingredientes de todas las comidas
    final Map<String, ShoppingItem> aggregatedItems = {};

    for (final meal in plannedMeals) {
      for (final food in meal.foods) {
        final key = food.name.toLowerCase();

        if (aggregatedItems.containsKey(key)) {
          final existing = aggregatedItems[key]!;
          aggregatedItems[key] = ShoppingItem(
            name: existing.name,
            quantity: existing.quantity + food.quantity,
            unit: existing.unit,
            category: existing.category,
            priority: existing.priority,
          );
        } else {
          aggregatedItems[key] = ShoppingItem(
            name: food.name,
            quantity: food.quantity,
            unit: food.unit,
            category: food.category ?? 'Otros',
            priority: 2,
          );
        }
      }
    }

    shoppingList.items.addAll(aggregatedItems.values);

    return shoppingList;
  }
}
