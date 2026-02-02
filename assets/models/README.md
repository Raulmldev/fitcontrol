# Food-101 TFLite Model - Setup Instructions

## Status
⚠️ **Modelo no incluido** - Debes descargar y colocar el modelo manualmente.

## Opciones de Modelos Recomendados

### Opción 1: STM32 Model Zoo (RECOMENDADA)
- **Modelo**: MobileNetV1 0.5 (int8 quantized)
- **Tamaño**: ~1 MB
- **Input**: 224x224x3
- **Dataset**: Food-101
- **URL**: https://github.com/STMicroelectronics/stm32ai-modelzoo/blob/main/image_classification/mobilenetv1/ST_pretrainedmodel_public_dataset/food-101/mobilenet_v1_0.5_224_fft/mobilenet_v1_0.5_224_fft_int8.tflite
- **Descarga directa**: Usa el botón "Download" en la página de GitHub

### Opción 2: AlexKoff88 MobileNetV2 Food101
- **Modelo**: MobileNetV2 (PyTorch → TFLite)
- **Precisión**: Top-1 76.3%
- **URL**: https://huggingface.co/AlexKoff88/mobilenet_v2_food101
- **Nota**: Requiere conversión de PyTorch a TFLite

### Opción 3: TensorFlow Lite Model Maker (Creación propia)
```bash
pip install tflite-model-maker
# Entrena tu propio modelo con Food-101
```

## Instrucciones de Instalación

1. Descarga el modelo `.tflite` desde una de las opciones anteriores
2. Colócalo en esta carpeta: `assets/models/`
3. Renómbralo a: `food_classifier.tflite`
4. Verifica que el archivo `food_labels.txt` esté presente

## Verificación

El modelo debe:
- Estar en formato `.tflite`
- Tener input size 224x224 o 160x160
- Producir 101 clases de salida (Food-101)
- Ser menor a 50MB (preferiblemente < 10MB para móvil)

## Referencias

- **Food-101 Dataset**: https://data.vision.ee.ethz.ch/cvl/datasets_extra/food-101/
- **TensorFlow Lite**: https://www.tensorflow.org/lite
- **Modelos pre-entrenados**: https://tfhub.dev

---
*Archivo generado automáticamente - FitControl App*
