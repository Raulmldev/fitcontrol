# Guía Rápida: Descargar Modelo TFLite Pre-entrenado

## PASO 1: Descargar el Modelo (5 minutos)

### Opción A: Kaggle (Más fácil)

1. Ve a: **https://www.kaggle.com/datasets**
2. Busca: `food classification tflite` o `food-101 tflite`
3. Descarga un modelo .tflite (tamaño típico: 15-30 MB)
4. Modelos recomendados:
   - "Food-101 TFLite"
   - "MobileNetV2 Food Classification"
   - "EfficientNet-Lite Food-101"

### Opción B: TensorFlow Hub (Más confiable)

1. Ve a: **https://tfhub.dev/s?module-type=image-classification**
2. Busca: `food` o `imagenet`
3. Descarga un modelo compatible con TFLite

### Opción C: GitHub (Alternativa)

Busca repositorios:
```
- github.com: food classification tflite flutter
- github.com: food-101 tensorflow lite
```

## PASO 2: Colocar el Modelo en tu Proyecto

```bash
# Crear carpeta si no existe
mkdir -p assets/models

# Copiar el modelo descargado
cp ~/Descargas/food_classifier.tflite assets/models/

# Verificar que está ahí
ls -lh assets/models/
```

## PASO 3: Actualizar pubspec.yaml

Añade las assets:
```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/models/food_classifier.tflite
```

## PASO 4: Probar

```bash
# Obtener dependencias
flutter pub get

# Ejecutar la app
flutter run
```

Ve a: **Nutrición → Registrar Comida → Detectar con IA**

Si el modelo está correctamente colocado:
- ✅ Funcionará 100% offline
- ✅ Detectará el alimento automáticamente
- ✅ Mostrará valores nutricionales

Si el modelo NO está:
- ⚠️ Usará modo demo (muestra "Plato de Ejemplo")
- ⚠️ Pero puedes editar los campos manualmente

## Modelos Específicos Recomendados

### 1. MobileNetV2 (Ligero)
- **Archivo:** `mobilenetv2_food101.tflite`
- **Tamaño:** ~15 MB
- **Precisión:** ~75%
- **Velocidad:** Muy rápido
- **Ideal para:** Dispositivos antiguos

### 2. EfficientNet-Lite0 (Equilibrado)
- **Archivo:** `efficientnet-lite0_food101.tflite`
- **Tamaño:** ~20 MB
- **Precisión:** ~78%
- **Velocidad:** Rápido
- **Ideal para:** Uso general

### 3. YOLOv8n-cls (Más preciso)
- **Archivo:** `yolov8n_food101.tflite`
- **Tamaño:** ~15 MB
- **Precisión:** ~82%
- **Velocidad:** Ultra rápido
- **Ideal para:** Mejor precisión

## Si No Encuentras Modelo Específico de Comida

### Usa un Clasificador General + Base de Datos Local

El servicio `FoodRecognitionService` que implementamos incluye:
- ✅ Base de datos con 101 alimentos y valores nutricionales
- ✅ Mapeo de categorías detectadas a información nutricional

Entonces incluso con un modelo genérico de ImageNet, podemos:
1. Detectar: "pizza" (como objeto genérico)
2. Buscar en base de datos: valores nutricionales de pizza
3. Mostrar: calorías, proteínas, etc.

## Solución de Problemas

### "Modelo no encontrado"
```bash
# Verificar que existe
ls assets/models/

# Si no está, copiarlo manualmente
```

### "Error al cargar modelo"
- El modelo debe ser formato TFLite (.tflite)
- No usar modelos PyTorch (.pt) o ONNX (.onnx) directamente
- Convertir primero si es necesario

### Precisión baja
- Asegúrate de que la foto sea clara
- El plato debe ocupar la mayor parte de la imagen
- Buena iluminación ayuda

## Descargas Directas (Links de Ejemplo)

**Nota:** Estos links pueden cambiar. Busca siempre versiones actualizadas.

1. **STM32 Model Zoo:**
   https://github.com/STMicroelectronics/stm32ai-modelzoo
   - Busca: `food_classification.tflite`

2. **TensorFlow Examples:**
   https://www.tensorflow.org/lite/examples
   - Descarga modelos de ejemplo

3. **Kaggle Notebooks:**
   https://www.kaggle.com/code
   - Busca notebooks que exporten a TFLite

## ¿No Quieres Buscar? Entrena el Tuyo en 10 Minutos

Usa **Teachable Machine** (Google):
1. Ve a: https://teachablemachine.withgoogle.com/
2. Proyecto → Image
3. Sube 20-50 fotos de cada plato que comes comúnmente
4. Entrena (1 minuto automático)
5. Exporta → TensorFlow Lite
6. Descarga el modelo
7. ¡Listo para usar!

---

## Estado Actual del Proyecto

✅ **Código listo:** El servicio `FoodRecognitionService` está implementado con:
- Soporte TFLite local
- Procesamiento de imágenes 224x224
- Base de datos nutricional de 101 alimentos
- Modo demo de fallback
- 100% offline y open-source

⏳ **Pendiente:** Solo necesitas descargar el archivo `.tflite` y colocarlo en `assets/models/`

¿Necesitas ayuda encontrando un modelo específico?
