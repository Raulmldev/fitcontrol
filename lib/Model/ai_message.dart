import 'package:uuid/uuid.dart';

class AIAgentMessage {
  final String id;
  final String agentId;
  final String agentName;
  final String agentType;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final Map<String, dynamic>? metadata;
  final List<String>? suggestions;
  final bool requiresAction;
  final String? actionType;

  AIAgentMessage({
    String? id,
    required this.agentId,
    required this.agentName,
    required this.agentType,
    required this.content,
    DateTime? timestamp,
    this.type = MessageType.text,
    this.metadata,
    this.suggestions,
    this.requiresAction = false,
    this.actionType,
  }) : id = id ?? const Uuid().v4(),
       timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agentId': agentId,
      'agentName': agentName,
      'agentType': agentType,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'metadata': metadata,
      'suggestions': suggestions,
      'requiresAction': requiresAction,
      'actionType': actionType,
    };
  }

  factory AIAgentMessage.fromJson(Map<String, dynamic> json) {
    return AIAgentMessage(
      id: json['id'],
      agentId: json['agentId'],
      agentName: json['agentName'],
      agentType: json['agentType'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      metadata: json['metadata'],
      suggestions:
          json['suggestions'] != null
              ? List<String>.from(json['suggestions'])
              : null,
      requiresAction: json['requiresAction'] ?? false,
      actionType: json['actionType'],
    );
  }
}

enum MessageType {
  text,
  recommendation,
  warning,
  insight,
  question,
  action,
  coordination,
  summary,
}

class AIConversation {
  final String id;
  final String userId;
  final List<AIAgentMessage> messages;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String? summary;
  final List<String> participatingAgents;

  AIConversation({
    String? id,
    required this.userId,
    List<AIAgentMessage>? messages,
    DateTime? startedAt,
    this.endedAt,
    this.summary,
    List<String>? participatingAgents,
  }) : id = id ?? const Uuid().v4(),
       messages = List<AIAgentMessage>.from(messages ?? []),
       startedAt = startedAt ?? DateTime.now(),
       participatingAgents = List<String>.from(participatingAgents ?? []);

  void addMessage(AIAgentMessage message) {
    messages.add(message);
    if (!participatingAgents.contains(message.agentId)) {
      participatingAgents.add(message.agentId);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'messages': messages.map((m) => m.toJson()).toList(),
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'summary': summary,
      'participatingAgents': participatingAgents,
    };
  }

  factory AIConversation.fromJson(Map<String, dynamic> json) {
    return AIConversation(
      id: json['id'],
      userId: json['userId'],
      messages:
          (json['messages'] as List)
              .map((m) => AIAgentMessage.fromJson(m))
              .toList(),
      startedAt: DateTime.parse(json['startedAt']),
      endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
      summary: json['summary'],
      participatingAgents: List<String>.from(json['participatingAgents'] ?? []),
    );
  }
}

class AgentCoordinationRequest {
  final String id;
  final String requestingAgentId;
  final String requestingAgentName;
  final String targetAgentId;
  final String targetAgentName;
  final String requestType;
  final String description;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final CoordinationStatus status;
  final String? response;

  AgentCoordinationRequest({
    String? id,
    required this.requestingAgentId,
    required this.requestingAgentName,
    required this.targetAgentId,
    required this.targetAgentName,
    required this.requestType,
    required this.description,
    required this.data,
    DateTime? timestamp,
    this.status = CoordinationStatus.pending,
    this.response,
  }) : id = id ?? const Uuid().v4(),
       timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requestingAgentId': requestingAgentId,
      'requestingAgentName': requestingAgentName,
      'targetAgentId': targetAgentId,
      'targetAgentName': targetAgentName,
      'requestType': requestType,
      'description': description,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'response': response,
    };
  }

  factory AgentCoordinationRequest.fromJson(Map<String, dynamic> json) {
    return AgentCoordinationRequest(
      id: json['id'],
      requestingAgentId: json['requestingAgentId'],
      requestingAgentName: json['requestingAgentName'],
      targetAgentId: json['targetAgentId'],
      targetAgentName: json['targetAgentName'],
      requestType: json['requestType'],
      description: json['description'],
      data: json['data'],
      timestamp: DateTime.parse(json['timestamp']),
      status: CoordinationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CoordinationStatus.pending,
      ),
      response: json['response'],
    );
  }
}

enum CoordinationStatus { pending, processing, completed, rejected }

class UserQuery {
  final String id;
  final String userId;
  final String query;
  final DateTime timestamp;
  final QueryContext context;
  final String? preferredAgent;
  final List<String>? relevantData;

  UserQuery({
    String? id,
    required this.userId,
    required this.query,
    DateTime? timestamp,
    this.context = QueryContext.general,
    this.preferredAgent,
    this.relevantData,
  }) : id = id ?? const Uuid().v4(),
       timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'query': query,
      'timestamp': timestamp.toIso8601String(),
      'context': context.name,
      'preferredAgent': preferredAgent,
      'relevantData': relevantData,
    };
  }

  factory UserQuery.fromJson(Map<String, dynamic> json) {
    return UserQuery(
      id: json['id'],
      userId: json['userId'],
      query: json['query'],
      timestamp: DateTime.parse(json['timestamp']),
      context: QueryContext.values.firstWhere(
        (e) => e.name == json['context'],
        orElse: () => QueryContext.general,
      ),
      preferredAgent: json['preferredAgent'],
      relevantData:
          json['relevantData'] != null
              ? List<String>.from(json['relevantData'])
              : null,
    );
  }
}

enum QueryContext { nutrition, workout, health, general, shopping, goals }
