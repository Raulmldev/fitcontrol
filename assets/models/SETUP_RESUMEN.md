# Food-101 Model Setup - RESUMEN

## ✅ Archivos Creados

1. **food_labels.txt** - 101 etiquetas del dataset Food-101
   - Ubicación: `assets/models/food_labels.txt`
   - Total de clases: 101
   - Formato: Una etiqueta por línea

2. **README.md** - Instrucciones detalladas
   - Ubicación: `assets/models/README.md`

## ❌ Modelo NO Descargado

**Razón**: Los modelos TFLite de Food-101 disponibles públicamente requieren:
- Descarga manual desde GitHub (requiere autenticación/interacción)
- Conversión desde PyTorch a TFLite
- Entrenamiento propio con TensorFlow

## 🔧 Siguientes Pasos

### Opción 1: Descargar modelo existente (RECOMENDADO)

1. Visita: https://github.com/STMicroelectronics/stm32ai-modelzoo
2. Navega a: `image_classification/mobilenetv1/ST_pretrainedmodel_public_dataset/food-101/`
3. Descarga: `mobilenet_v1_0.5_224_fft_int8.tflite`
4. Colócalo en: `assets/models/food_classifier.tflite`

**Características del modelo:**
- Tamaño: ~1 MB
- Input: 224x224x3
- Cuantizado: INT8 (optimizado para móvil)
- Dataset: Food-101 (101 clases)

### Opción 2: Entrenar modelo propio

Si tienes Python y TensorFlow instalados:

```bash
# Instalar dependencias
pip install tensorflow tensorflow-datasets

# Descargar dataset Food-101
python -c "import tensorflow_datasets as tfds; tfds.load('food101')"

# Entrenar modelo (ver tutoriales en GitHub)
```

### Opción 3: Usar TensorFlow Lite Model Maker

```bash
pip install tflite-model-maker
```

Luego seguir la documentación oficial para crear un modelo personalizado.

## 📚 Recursos Adicionales

- **Food-101 Dataset**: https://data.vision.ee.ethz.ch/cvl/datasets_extra/food-101/
- **STM32 AI Model Zoo**: https://github.com/STMicroelectronics/stm32ai-modelzoo
- **TensorFlow Hub**: https://tfhub.dev/s?deployment-format=lite&module-type=image-classification
- **TFLite Model Maker**: https://www.tensorflow.org/lite/models/modify/model_maker

## 📝 Nota Importante

Para una app Flutter con TensorFlow Lite, necesitarás:
1. El archivo `.tflite` en `assets/models/`
2. El archivo `food_labels.txt` (ya creado ✅)
3. El plugin `tflite_flutter` o `tflite` en tu pubspec.yaml

---
*FitControl App - Model Setup*
