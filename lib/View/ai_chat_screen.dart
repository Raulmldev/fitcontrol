import 'package:flutter/material.dart';
import '../Control/ai_coordinator.dart';
import '../Control/ai_expert_team.dart';
import '../Model/ai_message.dart';
import '../Model/user.dart';

/// Vista de Chat con los Agentes IA de FitControl
///
/// Permite al usuario interactuar con el equipo de 15 expertos de IA
class AIChatScreen extends StatefulWidget {
  final User user;

  const AIChatScreen({super.key, required this.user});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final AIAgentCoordinator _coordinator = AIAgentCoordinator();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<AIAgentMessage> _messages = [];
  bool _isLoading = false;
  bool _showTeamInfo = false;

  @override
  void initState() {
    super.initState();
    _initializeCoordinator();
  }

  Future<void> _initializeCoordinator() async {
    await _coordinator.initialize(user: widget.user);
    _coordinator.setUser(widget.user);

    // Escuchar mensajes de todos los agentes
    _coordinator.allMessages.listen((message) {
      if (mounted) {
        setState(() {
          _messages.add(message);
        });
        _scrollToBottom();
      }
    });

    // Mensaje de bienvenida
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    final welcomeMessage = AIAgentMessage(
      agentId: 'coordinator',
      agentName: 'Equipo FitControl',
      agentType: 'welcome',
      content: '''
🎉 ¡Bienvenido a FitControl!

Has activado a tu equipo personal de 15 expertos de IA con más de 450 años de experiencia combinada.

🤖 AGENTES PRINCIPALES:
• Dra. Elena Martínez - Tu nutricionista personal (32 años de experiencia)
• Carlos "El Profesor" Rodríguez - Tu entrenador personal (35 años de experiencia)
• Dr. Antonio Vásquez - Tu especialista en salud (34 años de experiencia)

💡 ¿En qué puedo ayudarte hoy?
- Planificar tus comidas
- Diseñar tu rutina de ejercicios
- Analizar tus parámetros de salud
- Cualquier otra consulta sobre tu bienestar

Escribe tu pregunta y el agente más apropiado te responderá. ¡Todos trabajan coordinadamente!
      ''',
      type: MessageType.text,
    );

    setState(() {
      _messages.add(welcomeMessage);
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    // Agregar mensaje del usuario
    final userMessage = AIAgentMessage(
      agentId: 'user',
      agentName: widget.user.name,
      agentType: 'user',
      content: text,
      type: MessageType.text,
    );

    setState(() {
      _messages.add(userMessage);
      _messageController.clear();
    });

    _scrollToBottom();

    try {
      // Procesar con el coordinador
      final response = await _coordinator.processUserQuery(text);

      if (mounted) {
        setState(() {
          _messages.add(response);
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = AIAgentMessage(
          agentId: 'system',
          agentName: 'Sistema',
          agentType: 'system',
          content:
              'Lo siento, ha ocurrido un error. Por favor intenta de nuevo.',
          type: MessageType.warning,
        );

        setState(() {
          _messages.add(errorMessage);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showTeamDetails() {
    setState(() {
      _showTeamInfo = true;
    });

    final summary = AIExpertTeam.getTeamSummary();
    final teamMessage = AIAgentMessage(
      agentId: 'coordinator',
      agentName: 'Equipo FitControl',
      agentType: 'team_info',
      content: summary,
      type: MessageType.text,
    );

    setState(() {
      _messages.add(teamMessage);
    });
    _scrollToBottom();
  }

  Future<void> _getRecommendations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final recommendations = await _coordinator.generateAllRecommendations(
        perAgent: 2,
      );

      if (mounted) {
        setState(() {
          _messages.addAll(recommendations);
        });
        _scrollToBottom();
      }
    } catch (e) {
      // Error silencioso - los mensajes de error se manejan en el coordinador
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistente IA FitControl'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: _showTeamDetails,
            tooltip: 'Ver equipo de expertos',
          ),
          IconButton(
            icon: const Icon(Icons.lightbulb),
            onPressed: _getRecommendations,
            tooltip: 'Obtener recomendaciones',
          ),
        ],
      ),
      body: Column(
        children: [
          // Info del equipo
          if (_showTeamInfo)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.deepPurple.shade50,
              child: Row(
                children: [
                  const Icon(Icons.people, color: Colors.deepPurple),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '15 Expertos IA • ${AIExpertTeam.getTotalExperience()} años de experiencia',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showTeamInfo = false;
                      });
                    },
                    child: const Text('Ocultar'),
                  ),
                ],
              ),
            ),

          // Lista de mensajes
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Indicador de carga
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),

          // Campo de entrada
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Escribe tu consulta...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  icon: const Icon(Icons.send),
                  color: Colors.deepPurple,
                  iconSize: 28,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(AIAgentMessage message) {
    final isUser = message.agentId == 'user';
    final isCoordinator = message.agentId == 'coordinator';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Nombre del agente
            if (!isUser)
              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getAgentIcon(message.agentType),
                      size: 16,
                      color: _getAgentColor(message.agentType),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      message.agentName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getAgentColor(message.agentType),
                      ),
                    ),
                  ],
                ),
              ),

            // Burbuja del mensaje
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:
                    isUser
                        ? Colors.deepPurple
                        : isCoordinator
                        ? Colors.orange.shade100
                        : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomRight: isUser ? const Radius.circular(4) : null,
                  bottomLeft: !isUser ? const Radius.circular(4) : null,
                ),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),

            // Sugerencias
            if (message.suggestions != null && message.suggestions!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 12),
                child: Wrap(
                  spacing: 8,
                  children:
                      message.suggestions!.map((suggestion) {
                        return ActionChip(
                          label: Text(suggestion),
                          onPressed: () {
                            _messageController.text = suggestion;
                            _sendMessage();
                          },
                          backgroundColor: Colors.deepPurple.shade50,
                        );
                      }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getAgentIcon(String agentType) {
    switch (agentType) {
      case 'nutritionist':
        return Icons.restaurant;
      case 'personal_trainer':
        return Icons.fitness_center;
      case 'health_specialist':
        return Icons.favorite;
      case 'coordination':
        return Icons.sync;
      case 'user':
        return Icons.person;
      default:
        return Icons.smart_toy;
    }
  }

  Color _getAgentColor(String agentType) {
    switch (agentType) {
      case 'nutritionist':
        return Colors.green;
      case 'personal_trainer':
        return Colors.blue;
      case 'health_specialist':
        return Colors.red;
      case 'coordination':
        return Colors.orange;
      default:
        return Colors.deepPurple;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _coordinator.dispose();
    super.dispose();
  }
}
