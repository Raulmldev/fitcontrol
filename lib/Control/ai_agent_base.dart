import 'dart:async';
import '../Model/ai_message.dart';
import '../Model/user.dart';

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

  AIAgentBase({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.specialization,
    required this.capabilities,
  });

  /// Procesa una consulta del usuario y genera una respuesta
  Future<AIAgentMessage> processQuery(UserQuery query, User user);

  /// Genera recomendaciones basadas en el contexto del usuario
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
Siempre coordina con otros agentes cuando sea necesario para proporcionar el mejor consejo integral.
    ''';
  }
}
