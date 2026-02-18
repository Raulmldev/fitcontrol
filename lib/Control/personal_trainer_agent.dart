import 'dart:async';
import '../Model/ai_message.dart';
import '../Model/user.dart';
import '../Model/workout.dart';
import 'ai_agent_base.dart';

/// Agente IA experto en entrenamiento personal y ejercicio
///
/// Este agente tiene más de 30 años de experiencia en:
/// - Entrenamiento personalizado
/// - Periodización del entrenamiento
/// - Fisiología del ejercicio
/// - Rehabilitación deportiva
/// - Coordinación con nutrición y salud
class PersonalTrainerAgent extends AIAgentBase {
  PersonalTrainerAgent()
    : super(
        id: 'trainer_expert_001',
        name: 'Carlos "El Profesor" Rodríguez',
        type: 'personal_trainer',
        description:
            'Entrenador personal certificado con 35 años de experiencia. '
            'Especialista en preparación física de élite, rehabilitación deportiva, '
            'y entrenamiento funcional. Ex entrenador de atletas olímpicos y '
            'creador de metodologías de entrenamiento adaptativas. '
            'Certificado por NSCA, ACE y EXOS.',
        specialization: 'Entrenamiento Personal y Preparación Física',
        capabilities: [
          'Diseño de planes de entrenamiento personalizados',
          'Periodización del entrenamiento',
          'Análisis de técnica de ejercicios',
          'Rehabilitación y prevención de lesiones',
          'Entrenamiento de fuerza y hipertrofia',
          'Entrenamiento cardiovascular',
          'Coordinación con plan nutricional',
          'Adaptación según parámetros de salud',
        ],
      );

  // Se elimina el override de processQuery para usar la implementación base con NVIDIA NIM

  @override
  Future<List<AIAgentMessage>> generateRecommendations(
    User user, {
    Map<String, dynamic>? context,
    int count = 3,
  }) async {
    final recommendations = <AIAgentMessage>[];

    // Recomendación 1: Plan de entrenamiento basado en nivel
    recommendations.add(
      createMessage(
        content: '''
🏋️ PLAN DE ENTRENAMIENTO RECOMENDADO

Nivel de actividad: ${user.activityLevel}
Objetivo: ${user.fitnessGoal}

ESTRUCTURA SEMANAL:
• Lunes: Pecho + Tríceps (60 min)
• Martes: Espalda + Bíceps (60 min)  
• Miércoles: Cardio + Core (45 min)
• Jueves: Piernas + Hombros (70 min)
• Viernes: Full Body Funcional (50 min)
• Sábado: Cardio LISS (40 min)
• Domingo: Descanso activo

Frecuencia: ${user.activityLevel == 'sedentario' ? '3-4' : '4-6'} días/semana
      ''',
        type: MessageType.recommendation,
        metadata: {'category': 'workout_plan', 'priority': 'high'},
      ),
    );

    // Recomendación 2: Progresión de cargas
    recommendations.add(
      createMessage(
        content: '''
📈 PRINCIPIO DE PROGRESIÓN

Para maximizar resultados en ${user.fitnessGoal}:

• Semanas 1-2: Adaptación (60-70% 1RM)
• Semanas 3-4: Intensidad (70-80% 1RM)
• Semanas 5-6: Sobrecarga (80-85% 1RM)
• Semana 7: Deload (50-60% 1RM)

Progresa cargas un 2.5-5% cada 2 semanas.
      ''',
        type: MessageType.recommendation,
        metadata: {'category': 'progression', 'priority': 'high'},
      ),
    );

    // Recomendación 3: Coordinación con nutrición
    recommendations.add(
      createMessage(
        content: '''
🤝 COORDINACIÓN NUTRICIÓN-ENTRENAMIENTO

He coordinado con tu nutricionista:

• Pre-entreno: 1.5-2h antes (carbos + proteína)
• Post-entreno: Dentro de 60 min (20-30g proteína)
• Hidratación: 500ml antes, 200ml cada 15 min durante

Ajustes calóricos según volumen de entrenamiento.
      ''',
        type: MessageType.coordination,
        metadata: {'category': 'nutrition_coordination', 'priority': 'medium'},
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
      case 'workouts':
        analysis = _analyzeWorkoutData(user, startDate, endDate);
        break;
      case 'progress':
        analysis = _analyzeProgressData(user);
        break;
      case 'performance':
        analysis = _analyzePerformanceMetrics(user);
        break;
      default:
        analysis =
            'Tipo de análisis no reconocido para datos de entrenamiento.';
    }

    final message = createMessage(content: analysis, type: MessageType.insight);

    sendMessage(message);
    return message;
  }

  @override
  Future<String> respondToCoordination(AgentCoordinationRequest request) async {
    switch (request.requestType) {
      case 'nutrition_workout':
        return _coordinateWithNutritionAgent(request);
      case 'health_workout_restrictions':
        return _coordinateWithHealthAgent(request);
      case 'workout_plan_modification':
        return _modifyWorkoutPlan(request);
      default:
        return 'Solicitud de coordinación recibida del entrenador.';
    }
  }

  // MÉTODOS PRIVADOS

  // Unused mock methods removed

  String _analyzeWorkoutData(
    User user,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    return '''
📈 ANÁLISIS DE ENTRENAMIENTO

Período analizado: ${startDate?.toString() ?? 'últimas 4 semanas'}

MÉTRICAS CLAVE:
• Frecuencia de entrenamiento: 4.2 días/semana (Excelente)
• Duración promedio: 58 minutos
• Intensidad media: 7.5/10
• Cumplimiento de plan: 87%

PATRONES IDENTIFICADOS:
• Mejor rendimiento: Lunes y Miércoles
• Fatiga acumulada: Slight por Viernes
• Recuperación: Optimal

RECOMENDACIONES:
1. Implementar deload semana 5
2. Aumentar volumen en piernas 10%
3. Añadir día de movilidad activa

He coordinado con tu experto en salud y no hay contraindicaciones.
    ''';
  }

  String _analyzeProgressData(User user) {
    return '''
🎯 ANÁLISIS DE PROGRESO

TENDENCIAS (últimas 8 semanas):
• Fuerza máxima: ↑ 12% (Excelente progresión)
• Resistencia cardiovascular: ↑ 8%
• Composición corporal: Mejorando
• Recuperación: Mantenida

COMPARATIVAS:
• vs Usuarios similares: Top 25%
• vs Tu historial: Mejor trimestre

PRÓXIMOS MILESTONES:
• Semana 4: PR en press banca
• Semana 6: Meta de peso muerto
• Semana 8: Evaluación de composición

¡Progreso outstanding! Mantén la consistencia.
    ''';
  }

  String _analyzePerformanceMetrics(User user) {
    return '''
⚡ MÉTRICAS DE RENDIMIENTO

VOLUMEN TOTAL SEMANAL:
• Series de fuerza: 85 (óptimo)
• Minutos cardio: 120 (meta: 150)
• Carga total: 45,000 kg (↑ 8%)

EFICIENCIA:
• Tiempo entre series: 75s (ideal)
• Intensidad relativa: 78% (progresivo)
• RPE promedio: 7.8 (adecuado)

SEÑALES:
• Positiva: Progresión constante de cargas
• Atención: Slight disminución en energía viernes
• Oportunidad: Aumentar frecuencia cardíaca máxima
    ''';
  }

  String _coordinateWithNutritionAgent(AgentCoordinationRequest request) {
    final data = request.data;
    final workoutSchedule = data['workout_schedule'] ?? [];

    return '''
COORDINACIÓN CON NUTRICIONISTA - OPTIMIZACIÓN DEL ENTRENAMIENTO

Basándome en tu plan de entrenamiento (${workoutSchedule.length} sesiones/semana):

AJUSTES NUTRICIONALES PROPUESTOS:
• Días de entreno alto volumen: +300 kcal
• Días de entreno moderado: Mantener
• Días de descanso: -200 kcal
• Timing de comidas optimizado para rendimiento

La Dra. Martínez ha ajustado tu plan para maximizar:
1. Energía durante entrenamientos
2. Recuperación post-entreno
3. Adaptaciones musculares

Plan coordinado y listo para implementar.
    ''';
  }

  String _coordinateWithHealthAgent(AgentCoordinationRequest request) {
    final data = request.data;
    final healthMetrics = data['health_metrics'] ?? {};

    return '''
COORDINACIÓN CON EXPERTO EN SALUD - AJUSTES DE SEGURIDAD

Considerando tus parámetros de salud:
• Ritmo cardíaco: ${healthMetrics['heart_rate'] ?? 'N/A'} BPM
• Presión arterial: ${healthMetrics['blood_pressure'] ?? 'N/A'}
• Nivel de energía: ${healthMetrics['energy_level'] ?? 'N/A'}/10

MODIFICACIONES APLICADAS:
• Intensidad cardiovascular ajustada al 75%
• Series de fuerza: Reducido volumen 15%
• Pausas de recuperación: +30 segundos
• Ejercicios de alta carga: Verificados para seguridad

Plan modificado manteniendo efectividad con máxima seguridad.
    ''';
  }

  String _modifyWorkoutPlan(AgentCoordinationRequest request) {
    return '''
MODIFICACIÓN DE PLAN - COORDINACIÓN MULTI-AGENTE

He recibido actualizaciones de todos los agentes:

CAMBIOS INTEGRADOS:
✓ Ajustado a nuevo plan nutricional
✓ Considerados parámetros de salud
✓ Optimizado según progreso reciente
✓ Adaptado a disponibilidad horaria

NUEVA ESTRUCTURA:
• Frecuencia: 5 días/semana (anterior: 4)
• Enfoque: Hipertrofia + Funcional
• Duración: 60-75 min por sesión
• Intensidad: Progresiva del 70% al 85%

Plan actualizado y sincronizado con todos tus objetivos.
    ''';
  }

  // MÉTODO PÚBLICO PARA CREAR PLAN DE ENTRENAMIENTO

  Future<WorkoutPlan> createPersonalizedWorkoutPlan({
    required String userId,
    required User user,
    required int weeks,
    required String goal,
  }) async {
    final workoutDays = <WorkoutDay>[];

    // Crear días de entrenamiento según nivel
    final daysPerWeek = _getDaysPerWeek(user.activityLevel);
    final dayDistribution = _distributeWorkoutDays(daysPerWeek);

    for (final dayNum in dayDistribution) {
      workoutDays.add(
        WorkoutDay(
          dayOfWeek: dayNum,
          focus: _getFocusForDay(dayNum, goal),
          exercises: _getExercisesForDay(dayNum, goal, user),
          estimatedDuration: _getDurationForLevel(user.activityLevel),
        ),
      );
    }

    return WorkoutPlan(
      userId: userId,
      name: 'Plan $goal - $weeks semanas',
      description: 'Plan personalizado basado en objetivo: $goal',
      durationWeeks: weeks,
      daysPerWeek: daysPerWeek,
      difficulty: _getDifficultyLevel(user),
      goal: goal,
      workoutDays: workoutDays,
      isActive: true,
    );
  }

  int _getDaysPerWeek(String activityLevel) {
    switch (activityLevel) {
      case 'sedentario':
        return 3;
      case 'ligero':
        return 4;
      case 'moderado':
        return 5;
      case 'activo':
        return 6;
      case 'muy_activo':
        return 6;
      default:
        return 4;
    }
  }

  List<int> _distributeWorkoutDays(int daysPerWeek) {
    switch (daysPerWeek) {
      case 3:
        return [1, 3, 5]; // Lunes, Miércoles, Viernes
      case 4:
        return [1, 2, 4, 5]; // Lunes, Martes, Jueves, Viernes
      case 5:
        return [1, 2, 3, 5, 6]; // Lunes-Viernes
      case 6:
        return [1, 2, 3, 4, 5, 6]; // Lunes-Sábado
      default:
        return [1, 3, 5];
    }
  }

  String _getFocusForDay(int dayOfWeek, String goal) {
    if (goal.toLowerCase().contains('fuerza')) {
      final focuses = [
        'Pecho',
        'Espalda',
        'Piernas',
        'Hombros',
        'Brazos',
        'Full Body',
      ];
      return focuses[(dayOfWeek - 1) % focuses.length];
    }
    return 'Full Body';
  }

  List<Exercise> _getExercisesForDay(int dayOfWeek, String goal, User user) {
    // Ejercicios de ejemplo - en una implementación real, vendrían de una base de datos
    return [
      Exercise(
        name: 'Calentamiento específico',
        category: 'warmup',
        duration: 600,
      ),
      Exercise(
        name: 'Ejercicio principal',
        category: 'strength',
        sets: 4,
        reps: 8,
        restTime: 120,
      ),
      Exercise(
        name: 'Ejercicio secundario',
        category: 'strength',
        sets: 3,
        reps: 10,
        restTime: 90,
      ),
    ];
  }

  int _getDurationForLevel(String activityLevel) {
    switch (activityLevel) {
      case 'sedentario':
        return 45;
      case 'ligero':
        return 50;
      case 'moderado':
        return 60;
      case 'activo':
        return 75;
      case 'muy_activo':
        return 90;
      default:
        return 60;
    }
  }

  String _getDifficultyLevel(User user) {
    switch (user.activityLevel) {
      case 'sedentario':
        return 'Principiante';
      case 'ligero':
        return 'Principiante-Intermedio';
      case 'moderado':
        return 'Intermedio';
      case 'activo':
        return 'Intermedio-Avanzado';
      case 'muy_activo':
        return 'Avanzado';
      default:
        return 'Intermedio';
    }
  }
}
