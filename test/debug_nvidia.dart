// ignore_for_file: avoid_print
import 'package:dio/dio.dart';
import 'package:fitcontrol/Config/api_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Debug NVIDIA NIM Request', () async {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.nvidiaBaseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiConfig.nvidiaApiKey.trim()}',
        },
      ),
    );

    print('API Key: "${ApiConfig.nvidiaApiKey.substring(0, 10)}..."');
    print('Base URL: ${ApiConfig.nvidiaBaseUrl}');
    print('Model: ${ApiConfig.model}');

    try {
      final response = await dio.post(
        '/chat/completions',
        data: {
          'model': ApiConfig.model,
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
