# 🍕 FitControl - Modelo TFLite Setup - RESUMEN RÁPIDO

## ⚡ Método Rápido (Recomendado)

### Windows
```cmd
cd scripts
setup_model.bat
```

### Linux/Mac
```bash
cd scripts
chmod +x setup_model.sh && ./setup_model.sh
```

✅ **Esto hace TODO automáticamente:**
- Verifica Python
- Instala dependencias
- Descarga o crea modelo
- Guarda en assets/models/
- Prueba que funcione

---

## 📋 ¿Qué obtienes?

### Opción A: Modelo Descargado (si está disponible)
- MobileNet o EfficientNet pre-entrenado
- Dataset Food-101 (101 clases)
- Tamaño: 1-20 MB
- Precisión: 70-82%

### Opción B: Modelo Demo (fallback automático)
- MobileNetV2 con 10 comidas
- **Clases incluidas:**
  1. 🍕 Pizza
  2. 🍔 Hamburguesa
  3. 🍣 Sushi
  4. 🥗 Ensalada
  5. 🍝 Pasta
  6. 🍗 Pollo
  7. 🥩 Steak
  8. 🥪 Sandwich
  9. 🍲 Sopa
  10. 🍦 Helado
- Tamaño: ~12 MB
- Precisión: Funcional para demo

---

## 🎯 Ubicación del Modelo

```
assets/models/
├── food_classifier.tflite  ← Modelo TFLite
└── food_labels.txt         ← Etiquetas de clases
```

---

## 🚀 Probar la App

```bash
flutter pub get
flutter run
```

Navega a: **Nutrición → Registrar Comida → Detectar con IA**

---

## 🆘 Si el Script Falla

### Opción 1: Modo manual Python
```bash
cd scripts
pip install tensorflow numpy pillow
python download_food_model.py --method create
```

### Opción 2: Descarga directa
1. Ve a: https://github.com/STMicroelectronics/stm32ai-modelzoo
2. Busca: `mobilenet_v1_0.5_224_fft_int8.tflite`
3. Descarga y copia a `assets/models/food_classifier.tflite`

### Opción 3: Teachable Machine (¡Muy fácil!)
1. https://teachablemachine.withgoogle.com/
2. Sube fotos de tu comida (20-30 por clase)
3. Entrena (1 min)
4. Exporta → TensorFlow Lite
5. ¡Listo!

---

## 📚 Documentación

- **Guía completa:** `docs/DESCARGAR_MODELO_TFLITE.md`
- **Alternativas:** `docs/ALTERNATIVAS_OPENSOURCE.md`
- **Info del modelo:** `assets/models/README.md`
- **Scripts:** `scripts/README.md`

---

## ⚙️ Requisitos del Sistema

- **Python:** 3.8+
- **TensorFlow:** 2.13.0+ (se instala automáticamente)
- **Espacio:** 50 MB para descargas
- **RAM:** 2 GB mínimo (para crear modelo)
- **Internet:** Sí, para descargar dependencias

---

## ✅ Checklist

- [ ] Ejecutar script automático
- [ ] Verificar que existe `assets/models/food_classifier.tflite`
- [ ] Verificar que existe `assets/models/food_labels.txt`
- [ ] Ejecutar `flutter pub get`
- [ ] Probar detección de comida en la app

---

## 🎉 ¡Listo en 2 minutos!

Ejecuta el script y el modelo se configura automáticamente. Sin búsquedas, sin complicaciones.

¿Problemas? Revisa `docs/DESCARGAR_MODELO_TFLITE.md` o ejecuta con `--method create`.
