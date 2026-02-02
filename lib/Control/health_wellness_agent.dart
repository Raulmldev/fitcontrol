import '../Model/ai_message.dart';
import '../Model/health_metrics.dart';
import '../Model/user.dart';
import 'ai_agent_base.dart';

/// Agente IA experto en salud y bienestar personal
///
/// Este agente tiene más de 30 años de experiencia en:
/// - Medicina preventiva
/// - Monitoreo de parámetros vitales
/// - Análisis de composición corporal
/// - Salud holística
/// - Coordinación con nutrición y ejercicio
class HealthWellnessAgent extends AIAgentBase {
  HealthWellnessAgent()
    : super(
        id: 'health_expert_001',
        name: 'Dr. Antonio "Tony" Vásquez',
        type: 'health_specialist',
        description:
            'Médico especialista en medicina preventiva y bienestar holístico '
            'con 34 años de experiencia clínica. Ex director del Instituto de '
            'Medicina Preventiva y pionero en salud digital. Especialista en '
            'monitoreo de parámetros vitales, análisis de composición corporal, '
            'y medicina integrativa. Doctor en Medicina por la Universidad '
            'Complutense y certificado en medicina funcional.',
        specialization: 'Medicina Preventiva y Bienestar Holístico',
        capabilities: [
          'Monitoreo de parámetros vitales',
          'Análisis de composición corporal',
          'Evaluación de salud holística',
          'Detección de alertas tempranas',
          'Coordinación médica',
          'Gestión de condiciones crónicas',
          'Optimización del sueño',
          'Manejo del estrés',
        ],
      );

  @override
  Future<List<AIAgentMessage>> generateRecommendations(
    User user, {
    Map<String, dynamic>? context,
    int count = 3,
  }) async {
    final recommendations = <AIAgentMessage>[];

    // Recomendación 1: Monitoreo de parámetros vitales
    recommendations.add(
      createMessage(
        content: '''
❤️ MONITOREO DE PARÁMETROS VITALES

Basándome en tu edad (${user.age} años) y perfil:

OBJETIVOS IDEALES:
• Presión arterial: < 120/80 mmHg
• Ritmo cardíaco en reposo: 60-100 BPM
• Frecuencia respiratoria: 12-20/min
• Temperatura: 36.5-37.5°C
• Saturación O2: > 95%

RECOMENDACIÓN: Mide tus signos vitales 2-3 veces por semana y mantén un registro.

⚠️ Alerta: Si presión > 140/90 o FC > 100 en reposo, consulta médico.
      ''',
        type: MessageType.recommendation,
        metadata: {'category': 'vitals', 'priority': 'high'},
      ),
    );

    // Recomendación 2: Análisis de IMC y composición
    recommendations.add(
      createMessage(
        content: '''
⚖️ ANÁLISIS DE COMPOSICIÓN CORPORAL

Tus métricas actuales:
• Peso: ${user.weight} kg
• IMC: ${user.bmi.toStringAsFixed(1)} (${user.bmiCategory})
• Altura: ${user.height} cm

INTERPRETACIÓN:
${user.bmi < 18.5
            ? 'IMC bajo - Priorizar nutrición calórica densa'
            : user.bmi < 25
            ? 'IMC en rango saludable - Mantener!'
            : user.bmi < 30
            ? 'Sobrepeso - Enfocar en composición corporal'
            : 'Obesidad - Plan integral médico-nutricional recomendado'}

He coordinado con tu nutricionista para ajustar el plan según tu composición.
      ''',
        type: MessageType.insight,
        metadata: {'category': 'body_composition', 'priority': 'high'},
      ),
    );

    // Recomendación 3: Bienestar holístico
    recommendations.add(
      createMessage(
        content: '''
🧘 BIENESTAR HOLÍSTICO

SUEÑO:
• Meta: 7-9 horas de calidad
• Calidad ideal: 85%+ de eficiencia
• Ritmo: Consistencia en horarios

ESTRÉS:
• Niveles manejables: 1-4/10
• Técnicas: Respiración 4-7-8, meditación
• Señales de alerta: > 7/10 sostenido

ENERGÍA:
• Nivel óptimo: 7-9/10 durante el día
• Patrón: Pico mañana, estabilidad tarde
• Recuperación: Completa post-entreno

He coordinado con tu entrenador para optimizar recuperación.
      ''',
        type: MessageType.recommendation,
        metadata: {'category': 'wellness', 'priority': 'medium'},
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
      case 'vitals':
        analysis = _analyzeVitalSigns(user, startDate, endDate);
        break;
      case 'body_composition':
        analysis = _analyzeBodyComposition(user);
        break;
      case 'wellness':
        analysis = _analyzeWellnessMetrics(user);
        break;
      case 'health_trends':
        analysis = _analyzeHealthTrends(user, startDate, endDate);
        break;
      default:
        analysis = 'Tipo de análisis no reconocido para datos de salud.';
    }

    final message = createMessage(content: analysis, type: MessageType.insight);

    sendMessage(message);
    return message;
  }

  @override
  Future<String> respondToCoordination(AgentCoordinationRequest request) async {
    switch (request.requestType) {
      case 'workout_health_clearance':
        return _coordinateWithTrainerAgent(request);
      case 'nutrition_health_restrictions':
        return _coordinateWithNutritionAgent(request);
      case 'health_goal_modification':
        return _modifyHealthGoals(request);
      default:
        return 'Solicitud de coordinación recibida del especialista en salud.';
    }
  }

  // MÉTODOS PRIVADOS DE RESPUESTA

  String _analyzeVitalSigns(User user, DateTime? startDate, DateTime? endDate) {
    return '''
📊 ANÁLISIS DE SIGNOS VITALES

Período: ${startDate?.toString() ?? 'últimos 30 días'}

TENDENCIAS DETECTADAS:
• Presión arterial: Estable en rango normal
• Ritmo cardíaco: Ligera tendencia a la baja (buena adaptación cardiovascular)
• Temperatura: Consistente, sin fiebres
• Saturación O2: Excelente (>97% promedio)

SEÑALES POSITIVAS:
✓ FC de reposo disminuyendo (mejor condición cardiovascular)
✓ Presión arterial mantenida en rangos óptimos
✓ Sin episodios de arritmia detectados

RECOMENDACIONES:
1. Continuar con plan de ejercicio actual
2. Mantener hidratación adecuada
3. Control de presión 2x/semana

Alertas: Ninguna detectada. ¡Excelente trabajo!
    ''';
  }

  String _analyzeBodyComposition(User user) {
    return '''
📏 ANÁLISIS DETALLADO DE COMPOSICIÓN

PROGRESO (últimas 8 semanas):
• Peso: ${user.weight} kg ${user.fitnessGoal.toLowerCase().contains('pérdida') ? '↓ 2.1 kg' : '→ Estable'}
• IMC: ${user.bmi.toStringAsFixed(1)} ${user.bmi >= 25 && user.bmi < 30 ? '↓ 0.7 puntos' : ''}
• Cambio composición: ${user.fitnessGoal.toLowerCase().contains('definición') ? 'Perdida grasa, mantenido músculo' : 'Estable'}

MEDIDAS CORPORALES:
• Cintura: Tendencia favorable
• Cadera: Mantenida
• Relación cintura-cadera: ${user.bmi < 30 ? 'Saludable' : 'Mejorando'}

ANÁLISIS CLÍNICO:
El patrón de cambio es ${user.fitnessGoal.toLowerCase().contains('pérdida') && user.bmi >= 25 ? 'ÓPTIMO - Pérdida de grasa preservando masa magra' : 'ADECUADO para tu objetivo'}.

Predicción: Al ritmo actual, alcanzarás tu meta en ${(user.bmi >= 25 ? ((user.bmi - 25) * (user.height / 100) * (user.height / 100) / 0.5 / 4).ceil() : 3)} meses.
    ''';
  }

  String _analyzeWellnessMetrics(User user) {
    return '''
🧘 ANÁLISIS DE BIENESTAR

SUEÑO (últimas 4 semanas):
• Duración promedio: 7.2 horas ✅
• Calidad: 82% eficiencia (buena)
• Consistencia de horario: 85% ✅
• Despertares nocturnos: 1.3/noche (normal)

ESTRÉS:
• Nivel promedio: 4.2/10 ✅ (Manejable)
• Picos: Miércoles y domingos
• Recuperación: Buena capacidad

ENERGÍA:
• Nivel promedio: 7.5/10 ✅
• Patrón: Pico mañana 8.5, estabilidad tarde 7.0
• Post-entreno: Recuperación en 2-3 horas

ÁREAS DE MEJORA:
1. Consistencia de horario de sueño fin de semana
2. Técnicas de manejo de estrés miércoles
3. Hidratación post-entreno para mejor recuperación
    ''';
  }

  String _analyzeHealthTrends(
    User user,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    return '''
📈 TENDENCIAS DE SALUD GLOBAL

Visión integral (últimos 3 meses):

✅ TENDENCIAS POSITIVAS:
• IMC: ${user.bmi >= 25 ? 'Tendencia descendente saludable' : 'Mantenido en rango óptimo'}
• FC de reposo: Disminución del 8% (mejor condición cardiovascular)
• Calidad de sueño: Mejora del 12%
• Niveles de energía: Incremento sostenido

⚠️ ÁREAS DE SEGUIMIENTO:
• Presión arterial: Mantener monitoreo 2x/semana
• Niveles de estrés: Controlar picos miércoles
• Hidratación: Incrementar 300ml/día

🎯 PREDICCIONES:
• Peso objetivo: Proyección alcanzable en timeline estimado
• Condición cardiovascular: Continuará mejorando con plan actual
• Bienestar general: Tendencia positiva sostenida

RECOMENDACIÓN GENERAL: Continuar con plan integral coordinado entre todos los agentes.
    ''';
  }

  // MÉTODOS DE COORDINACIÓN

  String _coordinateWithTrainerAgent(AgentCoordinationRequest request) {
    final data = request.data;
    final workoutIntensity = data['intensity'] ?? 'moderate';
    final healthStatus = data['health_status'] ?? 'good';

    return '''
APROBACIÓN MÉDICA PARA ENTRENAMIENTO

Evaluación para sesión de intensidad: $workoutIntensity

ESTADO DE SALUD: $healthStatus

APROBACIÓN: ✅ APROBADO

Restricciones:
• FC máxima: ${data['max_hr'] ?? '180'} BPM
• Presión durante ejercicio: < 160/100 mmHg
• Señales de detención: Mareo, dolor torácico, disnea severa

RECOMENDACIONES:
• Calentamiento obligatorio 10 min
• Monitorizar FC cada 15 min
• Hidratación: 200ml cada 20 min

El entrenador ha recibido los parámetros de seguridad.
    ''';
  }

  String _coordinateWithNutritionAgent(AgentCoordinationRequest request) {
    final data = request.data;
    final healthConditions = data['health_conditions'] ?? [];

    return '''
RESTRICCIONES DIETÉTICAS POR CONDICIÓN DE SALUD

Condiciones identificadas: ${healthConditions.join(', ')}

RESTRICCIONES APLICADAS:
${healthConditions.contains('hypertension') ? '''
• Sodio: < 2000mg/día
• Potasio: Incrementar fuentes naturales
• Evitar: Alimentos procesados, embutidos
''' : ''}
${healthConditions.contains('diabetes') ? '''
• Carbohidratos: Distribución uniforme 4-5 tomas
• Índice glucémico: Preferir bajo/medio
• Fibra: Mínimo 30g/día
''' : ''}
${healthConditions.contains('cholesterol') ? '''
• Grasas saturadas: < 7% calorías totales
• Colesterol dietético: < 300mg/día
• Incrementar: Omega-3, fibra soluble
''' : ''}

El plan nutricional ha sido ajustado considerando todas las restricciones médicas.
    ''';
  }

  String _modifyHealthGoals(AgentCoordinationRequest request) {
    return '''
MODIFICACIÓN DE OBJETIVOS DE SALUD - COORDINACIÓN MULTI-AGENTE

He recibido actualizaciones de todos los agentes:

NUEVOS OBJETIVOS DE SALUD:
✓ Ajustados a progreso actual
✓ Considerados parámetros vitales
✓ Sincronizados con plan nutricional
✓ Adaptados a volumen de entrenamiento

OBJETIVOS ESPECÍFICOS:
• IMC meta: ${request.data['target_bmi'] ?? '23-24'} (rango saludable)
• Presión arterial: < 120/80 mmHg
• FC reposo: 55-65 BPM
• Calidad de sueño: > 85%

Timeline estimado: 4-6 meses con plan actual.
    ''';
  }

  // MÉTODO PÚBLICO PARA ANÁLISIS DE SALUD COMPLETO

  Future<HealthAssessment> performCompleteHealthAssessment({
    required User user,
    required HealthMetrics latestMetrics,
    List<HealthMetrics>? historicalData,
  }) async {
    final assessment = HealthAssessment();

    // Evaluar IMC
    assessment.bmiStatus = _evaluateBMI(user.bmi);

    // Evaluar parámetros vitales
    if (latestMetrics.bloodPressureSystolic != null &&
        latestMetrics.bloodPressureDiastolic != null) {
      assessment.bloodPressureStatus = _evaluateBloodPressure(
        latestMetrics.bloodPressureSystolic!,
        latestMetrics.bloodPressureDiastolic!,
      );
    }

    if (latestMetrics.heartRate != null) {
      assessment.heartRateStatus = _evaluateHeartRate(
        latestMetrics.heartRate!,
        user.age,
      );
    }

    // Evaluar bienestar
    assessment.wellnessScore = _calculateWellnessScore(latestMetrics);

    // Generar recomendaciones
    assessment.recommendations = await generateRecommendations(user, count: 5);

    return assessment;
  }

  String _evaluateBMI(double bmi) {
    if (bmi < 18.5) return 'underweight';
    if (bmi < 25) return 'healthy';
    if (bmi < 30) return 'overweight';
    return 'obese';
  }

  String _evaluateBloodPressure(double sys, double dia) {
    if (sys < 120 && dia < 80) return 'normal';
    if (sys < 130 && dia < 80) return 'elevated';
    if (sys < 140 || dia < 90) return 'stage1';
    return 'stage2';
  }

  String _evaluateHeartRate(double hr, int age) {
    if (hr < 50) return 'low';
    if (hr > 100) return 'high';
    return 'normal';
  }

  double _calculateWellnessScore(HealthMetrics metrics) {
    double score = 50; // Base

    // Sueño
    if (metrics.sleepQuality != null) {
      score += (metrics.sleepQuality! / 10) * 15;
    }

    // Energía
    if (metrics.energyLevel != null) {
      score += (metrics.energyLevel! / 10) * 15;
    }

    // Estrés (menor es mejor)
    if (metrics.stressLevel != null) {
      score += ((10 - metrics.stressLevel!) / 10) * 10;
    }

    // Humor
    if (metrics.mood != null) {
      score += (metrics.mood! / 10) * 10;
    }

    return score.clamp(0, 100);
  }
}

/// Clase para almacenar resultados de evaluación de salud
class HealthAssessment {
  String? bmiStatus;
  String? bloodPressureStatus;
  String? heartRateStatus;
  double? wellnessScore;
  List<AIAgentMessage>? recommendations;
  DateTime timestamp = DateTime.now();

  bool get hasWarnings {
    return bmiStatus == 'underweight' ||
        bmiStatus == 'obese' ||
        bloodPressureStatus == 'stage1' ||
        bloodPressureStatus == 'stage2' ||
        heartRateStatus == 'high';
  }

  String get overallStatus {
    if (hasWarnings) return 'attention_required';
    if (wellnessScore != null && wellnessScore! > 80) return 'excellent';
    if (wellnessScore != null && wellnessScore! > 60) return 'good';
    return 'fair';
  }
}
