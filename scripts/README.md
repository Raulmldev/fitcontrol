# Scripts de Setup para FitControl

Esta carpeta contiene scripts para facilitar la configuración del modelo TFLite de clasificación de comida.

## 🚀 Uso Rápido

### Windows
```bash
cd scripts
setup_model.bat
```

### Linux/Mac
```bash
cd scripts
chmod +x setup_model.sh
./setup_model.sh
```

## 📁 Archivos

### `download_food_model.py`
Script principal en Python que:
- Intenta descargar un modelo pre-entrenado de Food-101
- Si falla, crea un modelo demo con 10 comidas básicas
- Guarda el modelo en `assets/models/food_classifier.tflite`

**Opciones:**
```bash
# Modo automático (default): Intenta descargar, luego crear
python download_food_model.py

# Forzar descarga
python download_food_model.py --method download

# Crear modelo demo
python download_food_model.py --method create

# Saltar prueba del modelo
python download_food_model.py --skip-test
```

### `setup_model.bat`
Script para Windows que:
1. Verifica Python
2. Instala dependencias automáticamente
3. Ejecuta el script Python
4. Muestra instrucciones finales

### `setup_model.sh`
Script para Linux/Mac que:
1. Verifica Python 3
2. Instala dependencias automáticamente
3. Ejecuta el script Python
4. Muestra instrucciones finales

### `requirements.txt`
Dependencias necesarias:
- `tensorflow>=2.13.0` - Para crear/convertir modelos
- `numpy>=1.23.0` - Procesamiento numérico
- `pillow>=9.0.0` - Procesamiento de imágenes
- `requests>=2.28.0` - Descargas HTTP

## 🍕 Modelo de Demostración

Si no se puede descargar un modelo pre-entrenado, el script creará automáticamente un modelo con:

**Arquitectura:**
- Base: MobileNetV2 (pre-entrenado en ImageNet)
- Input: 224×224×3
- Output: 10 clases
- Tamaño: ~12 MB

**Comidas detectadas:**
1. pizza
2. hamburger
3. sushi
4. salad
5. pasta
6. chicken
7. steak
8. sandwich
9. soup
10. ice_cream

⚠️ **Nota:** Este modelo es funcional pero limitado. Es ideal para demostraciones y desarrollo. Para producción, se recomienda entrenar con el dataset completo Food-101 (101 clases).

## 🔧 Instalación Manual de Dependencias

Si los scripts automáticos fallan:

```bash
pip install tensorflow==2.15.0 numpy pillow requests
```

## 📊 Fuentes de Modelos Pre-entrenados

El script intenta descargar desde:

1. **STM32 Model Zoo** (GitHub)
   - MobileNetV1 0.5 INT8
   - ~1 MB
   - Dataset: Food-101
   - URL: https://github.com/STMicroelectronics/stm32ai-modelzoo

## 🐛 Solución de Problemas

### "Python no está instalado"
- Descarga Python desde https://python.org
- En Windows: Marca "Add Python to PATH"
- En Linux: `sudo apt install python3 python3-pip`

### "No module named tensorflow"
```bash
pip install tensorflow
```

### "Error al descargar modelo"
- Verifica tu conexión a internet
- Prueba el modo de creación: `python download_food_model.py --method create`
- Descarga manual desde las fuentes listadas arriba

### "Modelo muy grande"
El modelo usa MobileNetV2 completo. Para reducir tamaño:
- Usa cuantización INT8
- Elimina capas intermedias
- Usa MobileNetV1 0.5 en su lugar

## 📝 Flujo del Script

```
┌─────────────────┐
│ Verificar Python │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Instalar deps   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐     ┌─────────────────┐
│ Descargar modelo? │──No──▶│ Crear modelo    │
└────────┬────────┘     │ demo (MobileNet)│
         │ Sí           └────────┬────────┘
         ▼                      │
┌─────────────────┐              │
│ Guardar .tflite │              │
└────────┬────────┘              │
         │                      │
         ▼                      ▼
┌─────────────────┐
│ Probar modelo   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Mostrar         │
│ instrucciones   │
└─────────────────┘
```

## 🎯 Alternativas

Si este script no funciona para ti:

1. **Teachable Machine** (Más fácil)
   - https://teachablemachine.withgoogle.com/
   - Sube fotos de tu comida
   - Exporta a TFLite

2. **Descarga Manual**
   - Ve a docs/DESCARGAR_MODELO_TFLITE.md
   - Sigue las instrucciones paso a paso

3. **Entrenamiento Propio**
   - Usa TensorFlow Lite Model Maker
   - Entrena con Food-101 dataset

## 📚 Documentación Relacionada

- `docs/DESCARGAR_MODELO_TFLITE.md` - Guía de descarga manual
- `docs/ALTERNATIVAS_OPENSOURCE.md` - Otras opciones de modelos
- `assets/models/README.md` - Información del modelo

---

**Nota:** Estos scripts requieren conexión a internet para descargar dependencias y/o modelos.
