class ApiConfig {
  // API de DeepSeek (para chat/texto)
  // Obtén tu API key en: https://platform.deepseek.com/
  static const String deepSeekApiKey = String.fromEnvironment(
    'DEEPSEEK_API_KEY',
    defaultValue: 'sk-a92ce461686a4f51906478359066d332',
  );
  static const String deepSeekBaseUrl = 'https://api.deepseek.com';
  
  // API de Google Gemini (para visión de imágenes - reconocimiento de comida)
  // Obtén tu API key gratis en: https://makersuite.google.com/app/apikey
  // Nota: Gemini Pro Vision SÍ puede analizar imágenes, DeepSeek no tiene visión
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
}
