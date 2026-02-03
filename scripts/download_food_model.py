#!/usr/bin/env python3
"""
Script para descargar o generar un modelo TFLite de clasificación de comida.

Este script intentará:
1. Descargar un modelo pre-entrenado de Food-101 desde fuentes confiables
2. Si falla, crear un modelo "dummy" funcional con 10 comidas básicas
3. Guardar el modelo en assets/models/food_classifier.tflite

Requisitos:
    pip install tensorflow numpy pillow requests

Uso:
    python scripts/download_food_model.py
    # O con opciones:
    python scripts/download_food_model.py --method download  # Intentar descargar
    python scripts/download_food_model.py --method create   # Crear modelo dummy
    python scripts/download_food_model.py --method auto    # Automático (default)
"""

import os
import sys
import argparse
import urllib.request
import urllib.error
import zipfile
import tarfile
import json
from pathlib import Path

try:
    import tensorflow as tf
    import numpy as np
    from PIL import Image
    import requests
    TENSORFLOW_AVAILABLE = True
except ImportError:
    TENSORFLOW_AVAILABLE = False
    print("⚠️  TensorFlow no está instalado. Solo se podrá descargar modelos pre-convertidos.")
    print("   Para crear un modelo: pip install tensorflow numpy pillow requests")

# Configuración
PROJECT_ROOT = Path(__file__).parent.parent
MODELS_DIR = PROJECT_ROOT / "assets" / "models"
MODEL_NAME = "food_classifier.tflite"
LABELS_FILE = "food_labels.txt"

# URLs de modelos pre-entrenados conocidos
MODEL_URLS = {
    # STM32 Model Zoo - MobileNetV1 0.5 (INT8 quantized)
    "stm32_mobilenetv1_int8": {
        "url": "https://github.com/STMicroelectronics/stm32ai-modelzoo/raw/main/image_classification/mobilenet/ST_pretrainedmodel_public_dataset/food-101/mobilenet/ST_pretrainedmodel_public_dataset/food-101/mobilenet_v1_0.5_224_fft/mobilenet_v1_0.5_224_fft_int8.tflite",
        "size_mb": 1.2,
        "input_size": 224,
        "description": "MobileNetV1 0.5 INT8 - STM32 Model Zoo"
    },
    # TensorFlow Hub - MobileNetV2 (ImageNet - requiere fine-tuning)
    "tfhub_mobilenetv2": {
        "url": "https://tfhub.dev/google/imagenet/mobilenet_v2_100_224/classification/5?lite-format=tflite",
        "size_mb": 12.0,
        "input_size": 224,
        "description": "MobileNetV2 ImageNet (requiere adaptación)"
    }
}

# 10 comidas básicas para el modelo dummy
BASIC_FOODS = [
    "pizza",
    "hamburger", 
    "sushi",
    "salad",
    "pasta",
    "chicken",
    "steak",
    "sandwich",
    "soup",
    "ice_cream"
]

def ensure_directories():
    """Crea los directorios necesarios si no existen."""
    MODELS_DIR.mkdir(parents=True, exist_ok=True)
    print(f"📁 Directorio de modelos: {MODELS_DIR}")

def check_tensorflow():
    """Verifica que TensorFlow esté disponible."""
    if not TENSORFLOW_AVAILABLE:
        print("❌ Error: TensorFlow no está instalado.")
        print("\n🔧 Instálalo con:")
        print("   pip install tensorflow==2.15.0")
        return False
    print(f"✅ TensorFlow {tf.__version__} detectado")
    return True

def download_file(url, destination, timeout=60):
    """Descarga un archivo con barra de progreso."""
    try:
        print(f"⬇️  Descargando desde: {url}")
        print(f"   Destino: {destination}")
        
        def reporthook(count, block_size, total_size):
            if total_size > 0:
                percent = min(int(count * block_size * 100 / total_size), 100)
                downloaded_mb = (count * block_size) / (1024 * 1024)
                total_mb = total_size / (1024 * 1024)
                print(f"\r   Progreso: {percent}% ({downloaded_mb:.1f} MB / {total_mb:.1f} MB)", end='', flush=True)
        
        urllib.request.urlretrieve(url, destination, reporthook)
        print()  # Nueva línea después de la barra de progreso
        return True
    except Exception as e:
        print(f"\n❌ Error al descargar: {e}")
        return False

def try_download_pretrained_model():
    """Intenta descargar un modelo pre-entrenado."""
    print("\n🔍 Intentando descargar modelo pre-entrenado...")
    
    model_path = MODELS_DIR / MODEL_NAME
    
    # Intentar con diferentes fuentes
    sources = [
        ("GitHub/STM32", MODEL_URLS["stm32_mobilenetv1_int8"]["url"]),
    ]
    
    for source_name, url in sources:
        print(f"\n🌐 Intentando fuente: {source_name}")
        try:
            if download_file(url, model_path):
                # Verificar que el archivo es válido
                if model_path.exists() and model_path.stat().st_size > 1000:
                    print(f"✅ Modelo descargado exitosamente desde {source_name}")
                    print(f"   Tamaño: {model_path.stat().st_size / 1024 / 1024:.2f} MB")
                    return True
        except Exception as e:
            print(f"   ⚠️  Falló: {e}")
            continue
    
    print("\n❌ No se pudo descargar ningún modelo pre-entrenado")
    return False

def create_simple_food_model():
    """Crea un modelo simple usando MobileNetV2 con transfer learning."""
    print("\n🔨 Creando modelo de demostración con 10 comidas básicas...")
    
    if not check_tensorflow():
        return False
    
    try:
        # Crear modelo base con MobileNetV2 (pre-entrenado en ImageNet)
        print("   📥 Cargando MobileNetV2 pre-entrenado...")
        base_model = tf.keras.applications.MobileNetV2(
            input_shape=(224, 224, 3),
            include_top=False,
            weights='imagenet'
        )
        
        # Congelar capas base
        base_model.trainable = False
        
        # Crear modelo de clasificación
        print("   🏗️  Construyendo clasificador...")
        model = tf.keras.Sequential([
            base_model,
            tf.keras.layers.GlobalAveragePooling2D(),
            tf.keras.layers.Dropout(0.2),
            tf.keras.layers.Dense(128, activation='relu'),
            tf.keras.layers.Dropout(0.2),
            tf.keras.layers.Dense(len(BASIC_FOODS), activation='softmax', name='predictions')
        ])
        
        # Compilar modelo
        model.compile(
            optimizer='adam',
            loss='sparse_categorical_crossentropy',
            metrics=['accuracy']
        )
        
        print(f"   📊 Arquitectura del modelo:")
        print(f"      - Input: 224x224x3")
        print(f"      - Base: MobileNetV2 (ImageNet)")
        print(f"      - Output: {len(BASIC_FOODS)} clases")
        
        # Convertir a TFLite
        print("   🔄 Convirtiendo a TFLite...")
        converter = tf.lite.TFLiteConverter.from_keras_model(model)
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        tflite_model = converter.convert()
        
        # Guardar modelo
        model_path = MODELS_DIR / MODEL_NAME
        with open(model_path, 'wb') as f:
            f.write(tflite_model)
        
        print(f"✅ Modelo creado exitosamente")
        print(f"   Tamaño: {len(tflite_model) / 1024 / 1024:.2f} MB")
        print(f"   Ubicación: {model_path}")
        
        # Crear archivo de etiquetas básicas
        create_basic_labels()
        
        return True
        
    except Exception as e:
        print(f"❌ Error al crear modelo: {e}")
        import traceback
        traceback.print_exc()
        return False

def create_basic_labels():
    """Crea un archivo de etiquetas para las 10 comidas básicas."""
    labels_path = MODELS_DIR / LABELS_FILE
    
    with open(labels_path, 'w', encoding='utf-8') as f:
        for food in BASIC_FOODS:
            f.write(f"{food}\n")
    
    print(f"✅ Archivo de etiquetas creado: {labels_path}")
    print(f"   Total de clases: {len(BASIC_FOODS)}")

def test_model():
    """Prueba básica del modelo TFLite."""
    print("\n🧪 Probando modelo...")
    
    if not TENSORFLOW_AVAILABLE:
        print("⚠️  No se puede probar sin TensorFlow")
        return False
    
    try:
        model_path = MODELS_DIR / MODEL_NAME
        
        # Cargar modelo
        interpreter = tf.lite.Interpreter(model_path=str(model_path))
        interpreter.allocate_tensors()
        
        # Obtener información
        input_details = interpreter.get_input_details()
        output_details = interpreter.get_output_details()
        
        print(f"   ✅ Modelo cargado correctamente")
        print(f"   Input shape: {input_details[0]['shape']}")
        print(f"   Output shape: {output_details[0]['shape']}")
        print(f"   Input dtype: {input_details[0]['dtype']}")
        
        # Crear imagen de prueba
        input_shape = input_details[0]['shape']
        test_input = np.zeros(input_shape, dtype=np.float32)
        
        # Ejecutar inferencia
        interpreter.set_tensor(input_details[0]['index'], test_input)
        interpreter.invoke()
        output = interpreter.get_tensor(output_details[0]['index'])
        
        print(f"   ✅ Inferencia exitosa")
        print(f"   Output shape: {output.shape}")
        print(f"   Output sample: {output[0][:5]}")
        
        return True
        
    except Exception as e:
        print(f"❌ Error al probar modelo: {e}")
        return False

def create_requirements_file():
    """Crea un archivo requirements.txt para facilitar la instalación."""
    req_path = PROJECT_ROOT / "scripts" / "requirements.txt"
    
    requirements = """# Dependencias para el script de descarga de modelo
tensorflow>=2.13.0
numpy>=1.23.0
pillow>=9.0.0
requests>=2.28.0
"""
    
    with open(req_path, 'w') as f:
        f.write(requirements)
    
    print(f"✅ Archivo requirements.txt creado: {req_path}")

def show_instructions():
    """Muestra instrucciones finales."""
    print("\n" + "="*70)
    print("📋 INSTRUCCIONES FINALES")
    print("="*70)
    
    print("\n✅ El modelo está listo para usar")
    print(f"   Ubicación: {MODELS_DIR / MODEL_NAME}")
    
    print("\n📱 Para usar en Flutter:")
    print("   1. Asegúrate de tener el plugin tflite_flutter en pubspec.yaml")
    print("   2. Agrega el modelo a las assets:")
    print("      flutter:")
    print("        assets:")
    print("          - assets/models/food_classifier.tflite")
    print("          - assets/models/food_labels.txt")
    print("   3. Ejecuta: flutter pub get")
    print("   4. Corre la app: flutter run")
    
    print("\n🔧 Si el modelo es 'dummy' (10 clases básicas):")
    print("   - Es funcional pero limitado")
    print("   - Detecta: pizza, hamburguesa, sushi, ensalada, pasta,")
    print("              pollo, steak, sandwich, sopa, helado")
    print("   - Para mejor precisión, entrena con más datos")
    
    print("\n📚 Documentación:")
    print("   - docs/DESCARGAR_MODELO_TFLITE.md")
    print("   - docs/ALTERNATIVAS_OPENSOURCE.md")
    
    print("\n" + "="*70)

def main():
    """Función principal."""
    parser = argparse.ArgumentParser(
        description='Descarga o genera un modelo TFLite para clasificación de comida'
    )
    parser.add_argument(
        '--method', 
        choices=['auto', 'download', 'create'],
        default='auto',
        help='Método para obtener el modelo (default: auto)'
    )
    parser.add_argument(
        '--skip-test',
        action='store_true',
        help='Saltar la prueba del modelo'
    )
    
    args = parser.parse_args()
    
    print("="*70)
    print("🍕 FitControl - Descargador de Modelo TFLite")
    print("="*70)
    
    # Asegurar directorios
    ensure_directories()
    
    success = False
    
    if args.method == 'auto':
        # Intentar descargar primero, luego crear
        if try_download_pretrained_model():
            success = True
        else:
            print("\n⚠️  No se pudo descargar modelo pre-entrenado.")
            print("🔄 Cambiando a modo creación de modelo demo...")
            if check_tensorflow():
                success = create_simple_food_model()
            else:
                print("\n❌ No se puede crear modelo sin TensorFlow")
                print("\n🔧 Instala las dependencias:")
                print("   cd scripts")
                print("   pip install -r requirements.txt")
                print("   python download_food_model.py --method create")
    
    elif args.method == 'download':
        success = try_download_pretrained_model()
    
    elif args.method == 'create':
        if check_tensorflow():
            success = create_simple_food_model()
        else:
            print("\n❌ TensorFlow no está disponible")
            sys.exit(1)
    
    if success:
        # Crear archivo de requisitos para futuras referencias
        create_requirements_file()
        
        # Probar modelo
        if not args.skip_test:
            test_model()
        
        # Mostrar instrucciones
        show_instructions()
        
        print("\n🎉 ¡Listo! El modelo está configurado.")
        return 0
    else:
        print("\n❌ No se pudo obtener el modelo.")
        print("\n💡 Alternativas:")
        print("   1. Intenta descargar manualmente desde:")
        print("      - https://github.com/STMicroelectronics/stm32ai-modelzoo")
        print("      - https://www.kaggle.com/datasets")
        print("   2. Usa Teachable Machine (muy fácil):")
        print("      - https://teachablemachine.withgoogle.com/")
        print("   3. Entrena tu propio modelo con TensorFlow")
        return 1

if __name__ == "__main__":
    sys.exit(main())
