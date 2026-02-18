// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';
import 'package:fitcontrol/Control/ai_service.dart';
import 'package:fitcontrol/Config/api_config.dart';

void main() {
  test('Verify AI Service Connectivity (NVIDIA NIM)', () async {
    print('Checking API Key length: ${ApiConfig.nvidiaApiKey.length}');
    if (ApiConfig.nvidiaApiKey.isEmpty ||
        ApiConfig.nvidiaApiKey.contains('PASTE_YOUR_')) {
      print('ERROR: API Key is invalid or empty.');
      return;
    }

    print('Sending test request to NVIDIA NIM (Kimi K2.5)...');
    final service = AIService();
    final response = await service.chat(
      systemPrompt: 'You are a helpful assistant.',
      userMessage: 'Hello, are you working?',
    );

    print('Response received:');
    print(response);

    expect(response, isNot(contains('Error')));
  });
}
