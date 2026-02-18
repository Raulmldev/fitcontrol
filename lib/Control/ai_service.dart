import 'package:dio/dio.dart';
import '../Config/api_config.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.nvidiaBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${ApiConfig.nvidiaApiKey}',
      },
    ),
  );

  /// Sends a chat message to the NVIDIA NIM API (using Kimi K2.5)
  /// [systemPrompt] - The persona/instructions for the agent
  /// [userMessage] - The current query from the user
  /// [history] - (Optional) Previous messages for context
  Future<String> chat({
    required String systemPrompt,
    required String userMessage,
    List<Map<String, String>>? history,
  }) async {
    try {
      final messages = <Map<String, String>>[];

      // Add system prompt
      messages.add({'role': 'system', 'content': systemPrompt});

      // Add history if available
      if (history != null) {
        messages.addAll(history);
      }

      // Add user message
      messages.add({'role': 'user', 'content': userMessage});

      final response = await _dio.post(
        '/chat/completions',
        data: {'model': ApiConfig.model, 'messages': messages, 'stream': false},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          return data['choices'][0]['message']['content'] ??
              'Lo siento, no pude generar una respuesta.';
        }
      }

      return 'Error: Respuesta inesperada del servicio de IA.';
    } on DioException catch (e) {
      if (e.response != null) {
        return 'Error del servicio (${e.response?.statusCode}): ${e.response?.statusMessage}';
      }
      return 'Error de conexión: Por favor verifica tu internet.';
    } catch (e) {
      return 'Error desconocido: $e';
    }
  }
}
