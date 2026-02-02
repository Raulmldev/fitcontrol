import 'dart:async';
import '../Model/ai_message.dart';
import '../Model/user.dart';
import 'ai_service.dart';

/// Clase base abstracta para todos los agentes IA de FitControl
abstract class AIAgentBase {
  final String id;
  final String name;
  final String type;
  final String description;
  final String specialization;
  final List<String> capabilities;

  // Referencias a otros agentes para coordinación
  final Map<String, AIAgentBase> _coordinatorAgents = {};

  // Stream controller para mensajes
  final _messageController = StreamController<AIAgentMessage>.broadcast();
  Stream<AIAgentMessage> get messageStream => _messageController.stream;

  // Callback para coordinación
  Function(AgentCoordinationRequest)? onCoordinationRequest;

  // Servicio de IA
  final AIService _aiService = AIService();

  AIAgentBase({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.specialization,
    required this.capabilities,
  });

  /// Procesa una consulta del usuario y genera una respuesta usando DeepSeek
  Future<AIAgentMessage> processQuery(
    UserQuery query,
    User user, {
    List<AIAgentMessage>? history,
  }) async {
    // Construir el prompt del sistema enriquecido con datos del usuario
    final enrichedSystemContext = _buildEnrichedSystemContext(user);

    // Formatear historial para la API
    final apiHistory = <Map<String, String>>[];
    if (history != null) {
      // Tomar los últimos 100 mensajes (según petición de usuario)
      final recentHistory =
          history.length > 100
              ? history.sublist(history.length - 100)
              : history;

      for (final msg in recentHistory) {
        // Mapear rol
        final role = msg.agentId == 'user' ? 'user' : 'assistant';
        apiHistory.add({'role': role, 'content': msg.content});
      }
    }

    // Llamar al servicio de IA
    final responseContent = await _aiService.chat(
      systemPrompt: enrichedSystemContext,
      userMessage: query.query,
      history: apiHistory,
    );

    // Crear mensaje de respuesta
    final message = createMessage(
      content: responseContent,
      type: MessageType.text,
    );

    sendMessage(message);
    return message;
  }

  /// Construye un contexto de sistema enriquecido con los datos del usuario
  String _buildEnrichedSystemContext(User user) {
    return '''
${getSystemContext()}

PERFIL DEL USUARIO:
- Nombre: ${user.name}
- Edad: ${user.age}
- Peso: ${user.weight}kg
- Altura: ${user.height}cm
- Nivel de Actividad: ${user.activityLevel}
- Objetivo: ${user.fitnessGoal}
- Preferencias Alimentarias: ${user.dietaryPreferences.join(', ')}
- Alergias: ${user.allergies.join(', ')}
- Calorías Objetivo: ${user.targetCalories}

INSTRUCCIONES:
Responde siempre en español. Sé conciso pero útil. Usa un tono motivador y profesional.
Si la pregunta requiere cálculos, hazlos paso a paso.
Si la pregunta es peligrosa o médica grave, recomienda ver a un doctor real.
''';
  }

  /// Genera recomendaciones basadas en el contexto del usuario (a implementar por subclases o vía API)
  Future<List<AIAgentMessage>> generateRecommendations(
    User user, {
    Map<String, dynamic>? context,
    int count = 3,
  });

  /// Analiza datos del usuario y genera insights
  Future<AIAgentMessage> analyzeUserData(
    User user, {
    required String dataType,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Coordina con otro agente
  Future<AgentCoordinationRequest> coordinateWithAgent({
    required String targetAgentId,
    required String targetAgentName,
    required String requestType,
    required String description,
    required Map<String, dynamic> data,
  }) async {
    final request = AgentCoordinationRequest(
      requestingAgentId: id,
      requestingAgentName: name,
      targetAgentId: targetAgentId,
      targetAgentName: targetAgentName,
      requestType: requestType,
      description: description,
      data: data,
    );

    // Notificar al coordinador principal
    onCoordinationRequest?.call(request);

    return request;
  }

  /// Responde a una solicitud de coordinación
  Future<String> respondToCoordination(AgentCoordinationRequest request);

  /// Registra otros agentes disponibles para coordinación
  void registerCoordinatorAgent(String agentId, AIAgentBase agent) {
    _coordinatorAgents[agentId] = agent;
  }

  /// Obtiene un agente coordinador por ID
  AIAgentBase? getCoordinatorAgent(String agentId) {
    return _coordinatorAgents[agentId];
  }

  /// Envía un mensaje al stream
  void sendMessage(AIAgentMessage message) {
    _messageController.add(message);
  }

  /// Crea un mensaje de respuesta estándar
  AIAgentMessage createMessage({
    required String content,
    MessageType type = MessageType.text,
    Map<String, dynamic>? metadata,
    List<String>? suggestions,
    bool requiresAction = false,
    String? actionType,
  }) {
    return AIAgentMessage(
      agentId: id,
      agentName: name,
      agentType: type.name,
      content: content,
      type: type,
      metadata: metadata,
      suggestions: suggestions,
      requiresAction: requiresAction,
      actionType: actionType,
    );
  }

  /// Libera recursos
  void dispose() {
    _messageController.close();
  }

  /// Obtiene el contexto del sistema para el agente
  String getSystemContext() {
    return '''
Eres $name, un experto en $specialization con más de 30 años de experiencia.

DESCRIPCIÓN:
$description

CAPACIDADES:
${capabilities.join(', ')}

TU ROL:
Actúas como un experto profesional que guía al usuario en su estilo de vida saludable. 
Debes ser empático, profesional y basar tus recomendaciones en evidencia científica.
''';
  }
}
