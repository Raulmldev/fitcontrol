class ApiConfig {
  // API de Groq (para chat/texto)
  static const String groqApiKey = String.fromEnvironment(
    'GROQ_API_KEY',
    defaultValue: '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',
  );
  static const String groqBaseUrl = 'https://api.groq.com/openai/v1';

  // API de DeepSeek (Mantener por si acaso)
  static const String deepSeekApiKey = String.fromEnvironment(
    'DEEPSEEK_API_KEY',
    defaultValue: 'sk-a92ce461686a4f51906478359066d332',
  );
  static const String deepSeekBaseUrl = 'https://api.deepseek.com';
  
  // API de Google Gemini (para visión de imágenes - reconocimiento de comida)
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
}
