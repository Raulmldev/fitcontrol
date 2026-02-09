import 'package:dio/dio.dart';
import 'package:fitcontrol/Config/api_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Debug Groq Request', () async {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.groqBaseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ${ApiConfig.groqApiKey.trim()}', // Trim to be safe
        },
      ),
    );

    print('API Key: "${ApiConfig.groqApiKey}"');
    print('Trimmed Key: "${ApiConfig.groqApiKey.trim()}"');
    print('Base URL: ${ApiConfig.groqBaseUrl}');

    try {
      final response = await dio.post(
        '/chat/completions',
        data: {
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {'role': 'system', 'content': 'You are a helper.'},
            {'role': 'user', 'content': 'Test message'},
          ],
        },
      );
      print('Success: ${response.data}');
    } on DioException catch (e) {
      print('DioException: ${e.message}');
      print('Status Code: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
    } catch (e) {
      print('Unknown Error: $e');
    }
  });
}
