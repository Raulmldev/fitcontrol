import 'dart:async';
import 'dart:collection';
import '../Model/ai_message.dart';
import '../Model/user.dart';
import 'ai_agent_base.dart';
import 'health_wellness_agent.dart';
import 'nutrition_agent.dart';
import 'personal_trainer_agent.dart';

/// Sistema central de coordinación multi-agente para FitControl
///
/// Este coordinador gestiona la comunicación entre los 3 agentes principales:
/// - Dra. Elena Martínez (Nutricionista)
/// - Carlos "El Profesor" Rodríguez (Entrenador Personal)
/// - Dr. Antonio Vásquez (Especialista en Salud)
///
/// Además coordina con los 12 agentes especializados adicionales que forman
/// el equipo completo de 15 expertos de IA.
class AIAgentCoordinator {
  static final AIAgentCoordinator _instance = AIAgentCoordinator._internal();
  factory AIAgentCoordinator() => _instance;
  AIAgentCoordinator._internal();

  // Agentes principales
  late final NutritionAgent nutritionAgent;
  late final PersonalTrainerAgent trainerAgent;
  late final HealthWellnessAgent healthAgent;

  // Mapa de todos los agentes registrados
  final Map<String, AIAgentBase> _agents = {};

  // Cola de solicitudes de coordinación
  final Queue<AgentCoordinationRequest> _coordinationQueue = Queue();

  // Stream controller para eventos del sistema
  final _systemEventController = StreamController<CoordinatorEvent>.broadcast();
  Stream<CoordinatorEvent> get systemEvents => _systemEventController.stream;

  // Stream consolidado de todos los mensajes
  final _allMessagesController = StreamController<AIAgentMessage>.broadcast();
  Stream<AIAgentMessage> get allMessages => _allMessagesController.stream;

  // Historial de conversaciones
  final List<AIConversation> _conversations = [];
  AIConversation? _currentConversation;

  // Usuario actual
  User? _currentUser;

  // Estado del sistema
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Inicializa el sistema de agentes
  Future<void> initialize({User? user}) async {
    if (_isInitialized) return;

    _currentUser = user;

    // Crear agentes principales
    nutritionAgent = NutritionAgent();
    trainerAgent = PersonalTrainerAgent();
    healthAgent = HealthWellnessAgent();

    // Registrar agentes
    _registerAgent(nutritionAgent);
    _registerAgent(trainerAgent);
    _registerAgent(healthAgent);

    // Configurar callbacks de coordinación
    _setupCoordinationCallbacks();

    // Suscribirse a mensajes de todos los agentes
    _subscribeToAgentMessages();

    _isInitialized = true;

    _emitEvent(
      CoordinatorEvent(
        type: EventType.systemInitialized,
        message: 'Sistema Multi-Agente FitControl iniciado',
        data: {'agentCount': _agents.length},
      ),
    );
  }

  /// Registra un agente en el sistema
  void _registerAgent(AIAgentBase agent) {
    _agents[agent.id] = agent;

    // Registrar otros agentes para coordinación
    for (final otherAgent in _agents.values) {
      if (otherAgent.id != agent.id) {
        agent.registerCoordinatorAgent(otherAgent.id, otherAgent);
      }
    }
  }

  /// Configura los callbacks de coordinación entre agentes
  void _setupCoordinationCallbacks() {
    for (final agent in _agents.values) {
      agent.onCoordinationRequest = _handleCoordinationRequest;
    }
  }

  /// Maneja una solicitud de coordinación entre agentes
  Future<void> _handleCoordinationRequest(
    AgentCoordinationRequest request,
  ) async {
    // Agregar a la cola
    _coordinationQueue.add(request);

    _emitEvent(
      CoordinatorEvent(
        type: EventType.coordinationRequested,
        message:
            '${request.requestingAgentName} solicita coordinación con ${request.targetAgentName}',
        data: {
          'requestType': request.requestType,
          'requestingAgent': request.requestingAgentId,
          'targetAgent': request.targetAgentId,
        },
      ),
    );

    // Procesar la solicitud
    final targetAgent = _agents[request.targetAgentId];
    if (targetAgent != null) {
      try {
        final response = await targetAgent.respondToCoordination(request);

        // Crear mensaje de coordinación
        final coordMessage = AIAgentMessage(
          agentId: 'coordinator',
          agentName: 'Sistema de Coordinación',
          agentType: 'coordination',
          content: '''
🤝 COORDINACIÓN ENTRE AGENTES

De: ${request.requestingAgentName}
Para: ${request.targetAgentName}
Tipo: ${request.requestType}

Respuesta:
$response
          ''',
          type: MessageType.coordination,
          metadata: {'request': request.toJson(), 'response': response},
        );

        _allMessagesController.add(coordMessage);

        _emitEvent(
          CoordinatorEvent(
            type: EventType.coordinationCompleted,
            message: 'Coordinación completada exitosamente',
            data: {'response': response},
          ),
        );
      } catch (e) {
        _emitEvent(
          CoordinatorEvent(
            type: EventType.coordinationFailed,
            message: 'Error en coordinación: $e',
            data: {'error': e.toString()},
          ),
        );
      }
    }
  }

  /// Se suscribe a los mensajes de todos los agentes
  void _subscribeToAgentMessages() {
    for (final agent in _agents.values) {
      agent.messageStream.listen((message) {
        _allMessagesController.add(message);

        // Agregar a conversación actual si existe
        _currentConversation?.addMessage(message);
      });
    }
  }

  /// Procesa una consulta del usuario enrutándola al agente apropiado
  Future<AIAgentMessage> processUserQuery(
    String query, {
    QueryContext context = QueryContext.general,
    String? preferredAgent,
  }) async {
    if (_currentUser == null) {
      throw Exception('Usuario no configurado');
    }

    // Crear objeto de consulta
    final userQuery = UserQuery(
      userId: _currentUser!.id,
      query: query,
      context: context,
      preferredAgent: preferredAgent,
    );

    // Determinar qué agente debe responder
    AIAgentBase? selectedAgent;

    if (preferredAgent != null && _agents.containsKey(preferredAgent)) {
      selectedAgent = _agents[preferredAgent];
    } else {
      selectedAgent = _selectAgentForContext(context, query);
    }

    if (selectedAgent == null) {
      throw Exception('No se pudo determinar el agente apropiado');
    }

    // Crear o continuar conversación
    if (_currentConversation == null) {
      _currentConversation = AIConversation(userId: _currentUser!.id);
      _conversations.add(_currentConversation!);
    }

    // Agregar mensaje del usuario
    final userMessage = AIAgentMessage(
      agentId: 'user',
      agentName: _currentUser!.name,
      agentType: 'user',
      content: query,
      type: MessageType.text,
    );
    _currentConversation!.addMessage(userMessage);

    // Procesar con el agente seleccionado
    final response = await selectedAgent.processQuery(userQuery, _currentUser!);

    _emitEvent(
      CoordinatorEvent(
        type: EventType.queryProcessed,
        message: 'Consulta procesada por ${selectedAgent.name}',
        data: {'agentId': selectedAgent.id, 'queryContext': context.name},
      ),
    );

    return response;
  }

  /// Selecciona el mejor agente según el contexto de la consulta
  AIAgentBase? _selectAgentForContext(QueryContext context, String query) {
    final queryLower = query.toLowerCase();

    // Palabras clave para cada agente
    final nutritionKeywords = [
      'comida',
      'dieta',
      'nutrición',
      'calorías',
      'proteína',
      'carbohidrato',
      'grasa',
      'compra',
      'lista',
      'alimento',
    ];

    final workoutKeywords = [
      'ejercicio',
      'entrenamiento',
      'rutina',
      'gym',
      'gimnasio',
      'pesas',
      'cardio',
      'músculo',
      'fuerza',
    ];

    final healthKeywords = [
      'salud',
      'presión',
      'ritmo',
      'peso',
      'grasa',
      'sueño',
      'estrés',
      'energía',
      'vital',
    ];

    // Contar coincidencias
    int nutritionScore = 0;
    int workoutScore = 0;
    int healthScore = 0;

    for (final keyword in nutritionKeywords) {
      if (queryLower.contains(keyword)) nutritionScore++;
    }

    for (final keyword in workoutKeywords) {
      if (queryLower.contains(keyword)) workoutScore++;
    }

    for (final keyword in healthKeywords) {
      if (queryLower.contains(keyword)) healthScore++;
    }

    // Decidir según puntuación o contexto explícito
    switch (context) {
      case QueryContext.nutrition:
        return nutritionAgent;
      case QueryContext.workout:
        return trainerAgent;
      case QueryContext.health:
        return healthAgent;
      default:
        // Determinar por puntuación
        if (nutritionScore >= workoutScore && nutritionScore >= healthScore) {
          return nutritionAgent;
        } else if (workoutScore >= healthScore) {
          return trainerAgent;
        } else {
          return healthAgent;
        }
    }
  }

  /// Genera recomendaciones de todos los agentes
  Future<List<AIAgentMessage>> generateAllRecommendations({
    int perAgent = 2,
  }) async {
    if (_currentUser == null) {
      throw Exception('Usuario no configurado');
    }

    final allRecommendations = <AIAgentMessage>[];

    // Obtener recomendaciones de cada agente
    final nutritionRecs = await nutritionAgent.generateRecommendations(
      _currentUser!,
      count: perAgent,
    );
    allRecommendations.addAll(nutritionRecs);

    final trainerRecs = await trainerAgent.generateRecommendations(
      _currentUser!,
      count: perAgent,
    );
    allRecommendations.addAll(trainerRecs);

    final healthRecs = await healthAgent.generateRecommendations(
      _currentUser!,
      count: perAgent,
    );
    allRecommendations.addAll(healthRecs);

    _emitEvent(
      CoordinatorEvent(
        type: EventType.recommendationsGenerated,
        message:
            'Generadas ${allRecommendations.length} recomendaciones de todos los agentes',
        data: {'count': allRecommendations.length},
      ),
    );

    return allRecommendations;
  }

  /// Coordina una consulta compleja entre múltiples agentes
  Future<List<AIAgentMessage>> coordinateMultiAgentConsultation(
    String query, {
    List<String>? agentIds,
  }) async {
    if (_currentUser == null) {
      throw Exception('Usuario no configurado');
    }

    final responses = <AIAgentMessage>[];
    final agentsToConsult = agentIds ?? _agents.keys.toList();

    _emitEvent(
      CoordinatorEvent(
        type: EventType.multiAgentConsultationStarted,
        message: 'Iniciando consulta multi-agente',
        data: {'agents': agentsToConsult, 'query': query},
      ),
    );

    // Consultar cada agente
    for (final agentId in agentsToConsult) {
      final agent = _agents[agentId];
      if (agent != null) {
        final userQuery = UserQuery(
          userId: _currentUser!.id,
          query: query,
          preferredAgent: agentId,
        );

        final response = await agent.processQuery(userQuery, _currentUser!);
        responses.add(response);
      }
    }

    // Generar resumen coordinado
    final summaryMessage = AIAgentMessage(
      agentId: 'coordinator',
      agentName: 'Coordinador FitControl',
      agentType: 'summary',
      content: '''
📋 RESUMEN DE CONSULTA MULTI-AGENTE

Consulta: "$query"

Agentes consultados: ${agentsToConsult.length}
${responses.map((r) => '• ${r.agentName}: ${r.content.substring(0, r.content.length > 100 ? 100 : r.content.length)}...').join('\n')}

Todos los agentes han coordinado sus respuestas para darte la mejor orientación integral.
      ''',
      type: MessageType.summary,
    );

    responses.add(summaryMessage);

    _emitEvent(
      CoordinatorEvent(
        type: EventType.multiAgentConsultationCompleted,
        message: 'Consulta multi-agente completada',
        data: {'responses': responses.length},
      ),
    );

    return responses;
  }

  /// Realiza un análisis integral coordinado de todos los datos del usuario
  Future<Map<String, AIAgentMessage>> performComprehensiveAnalysis() async {
    if (_currentUser == null) {
      throw Exception('Usuario no configurado');
    }

    final analyses = <String, AIAgentMessage>{};

    // Análisis de nutrición
    analyses['nutrition'] = await nutritionAgent.analyzeUserData(
      _currentUser!,
      dataType: 'nutrition',
    );

    // Análisis de entrenamiento
    analyses['workout'] = await trainerAgent.analyzeUserData(
      _currentUser!,
      dataType: 'workouts',
    );

    // Análisis de salud
    analyses['health'] = await healthAgent.analyzeUserData(
      _currentUser!,
      dataType: 'health_trends',
    );

    _emitEvent(
      CoordinatorEvent(
        type: EventType.comprehensiveAnalysisCompleted,
        message: 'Análisis integral completado',
        data: {'areas': analyses.keys.toList()},
      ),
    );

    return analyses;
  }

  /// Obtiene información del equipo de agentes
  List<Map<String, dynamic>> getTeamInfo() {
    return _agents.values
        .map(
          (agent) => {
            'id': agent.id,
            'name': agent.name,
            'type': agent.type,
            'description': agent.description,
            'specialization': agent.specialization,
            'capabilities': agent.capabilities,
          },
        )
        .toList();
  }

  /// Obtiene el historial de conversaciones
  List<AIConversation> getConversationHistory() {
    return List.unmodifiable(_conversations);
  }

  /// Establece el usuario actual
  void setUser(User user) {
    _currentUser = user;
  }

  /// Emite un evento del sistema
  void _emitEvent(CoordinatorEvent event) {
    _systemEventController.add(event);
  }

  /// Limpia recursos
  void dispose() {
    for (final agent in _agents.values) {
      agent.dispose();
    }
    _systemEventController.close();
    _allMessagesController.close();
  }
}

/// Evento del coordinador
class CoordinatorEvent {
  final EventType type;
  final String message;
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  CoordinatorEvent({
    required this.type,
    required this.message,
    this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Tipos de eventos del coordinador
enum EventType {
  systemInitialized,
  queryProcessed,
  recommendationsGenerated,
  coordinationRequested,
  coordinationCompleted,
  coordinationFailed,
  multiAgentConsultationStarted,
  multiAgentConsultationCompleted,
  comprehensiveAnalysisCompleted,
  error,
}
