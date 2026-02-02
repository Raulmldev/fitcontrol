# Activar Reconocimiento de Comida por IA

## Opción Recomendada: Google Gemini Pro Vision (Funciona Inmediatamente) ✅

Google Gemini Pro Vision **SÍ tiene capacidad de visión** y puede analizar imágenes de comida en tiempo real.

### Paso 1: Obtener API Key Gratis

1. Ve a: **https://makersuite.google.com/app/apikey**
2. Inicia sesión con tu cuenta de Google
3. Clic en "Create API Key"
4. Copia la clave generada

### Paso 2: Configurar la API Key

Edita el archivo `lib/Config/api_config.dart`:

```dart
class ApiConfig {
  // ... otras configs ...
  
  // Reemplaza esto:
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
  
  // Por tu API key real:
  static const String geminiApiKey = 'AIzaSyBxxxxxxxxxxxxxxxxxxxxxxxxx';
}
```

### Paso 3: ¡Listo!

La funcionalidad está activa. Cuando uses "Detectar con IA" en la app:
- ✅ Tomarás una foto del plato
- ✅ Gemini analizará la imagen automáticamente
- ✅ Autorellenará nombre y valores nutricionales
- ✅ Puedes modificar los campos antes de guardar

---

## Alternativa: Modelo TensorFlow Lite (Offline)

Si prefieres no depender de internet, puedes usar un modelo local:

### Descargar Modelo Food-101

1. Descarga el modelo desde: https://github.com/STMicroelectronics/stm32ai-modelzoo
2. Busca: `food_classification.tflite`
3. Colócalo en: `assets/models/food_classification.tflite`
4. Actualiza `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - assets/models/food_classification.tflite
       - assets/models/food_labels.txt
   ```

### Cambiar a TFLite

Modifica `lib/Control/food_recognition_service.dart`:

```dart
// Comenta la implementación actual y descomenta la de TFLite
```

---

## Notas Importantes

### Google Gemini (Recomendado)
- ✅ Visión de imágenes real
- ✅ Muy preciso
- ✅ Gratis hasta 60 requests/minuto
- ✅ Funciona en Android, iOS y Web
- ❌ Requiere conexión a internet

### TensorFlow Lite (Alternativa)
- ✅ Funciona offline
- ✅ Más rápido (local)
- ✅ Sin costos
- ❌ Requiere descargar modelo (~25MB)
- ❌ Menos preciso que IA en la nube
- ❌ Solo 101 alimentos pre-entrenados

### DeepSeek (NO soporta visión)
- DeepSeek Chat **NO puede analizar imágenes**
- Solo funciona con texto
- Sigue siendo útil para otros agentes de la app

---

## Solución de Problemas

### "API Key no válida"
- Verifica que copiaste la clave completa
- Asegúrate de no tener espacios extras
- Regenera la clave en Google AI Studio si es necesario

### "Error de conexión"
- Verifica tu conexión a internet
- Gemini requiere conexión para funcionar

### Precisión baja
- Asegúrate de que el plato ocupe la mayor parte de la foto
- Buena iluminación ayuda
- Evita fotos borrosas

---

## Costos

**Google Gemini Pro Vision:**
- Gratis: 60 requests/minuto
- Después: $0.0025 por imagen (muy económico)
- Para uso personal, el plan gratis es suficiente

**DeepSeek (Chat):**
- Gratis: 1M tokens/día
- Suficiente para uso normal

---

## Resumen

Para activar AHORA:
1. ✅ Obtener API key de Gemini (gratis)
2. ✅ Pegarla en `api_config.dart`
3. ✅ ¡Listo! La IA detectará tus comidas automáticamente

Para usar OFFLINE:
1. Descargar modelo TFLite
2. Cambiar implementación
3. Funciona sin internet

La app está lista para ambas opciones. Elige la que mejor se adapte a tus necesidades.
