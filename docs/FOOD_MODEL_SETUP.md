# Configuración del Modelo de Reconocimiento de Comida (TFLite)

Este documento explica cómo descargar y configurar el modelo de TensorFlow Lite para reconocimiento de comida.

## Opciones de Modelos

### Opción 1: Modelo Pre-entrenado (Recomendado para empezar)

**Modelo:** Food-101 Dataset (101 tipos de comidas)
- Tamaño: ~25-50MB
- Precisión: ~75-80%
- Velocidad: Muy rápido en dispositivos móviles

**Pasos para descargar:**

1. **Descargar desde TensorFlow Hub:**
   ```bash
   # Modelo MobileNetV2 pre-entrenado con Food-101
   wget https://storage.googleapis.com/tfhub-tfjs-modules/google/MobileNetV2/food_101/1/model.json
   ```

2. **O usar un modelo ya convertido a TFLite:**
   - Visita: https://www.kaggle.com/datasets
   - Busca: "food classification tflite"
   - Descarga un modelo .tflite

3. **Crear la carpeta de assets:**
   ```bash
   mkdir -p assets/models
   ```

4. **Colocar el archivo del modelo:**
   - Copia el archivo `.tflite` descargado a: `assets/models/food_classification.tflite`

5. **Crear archivo de etiquetas:**
   Crea el archivo `assets/models/food_labels.txt` con las 101 comidas:
   ```
   apple_pie
   baby_back_ribs
   baklava
   beef_carpaccio
   beef_tartare
   beet_salad
   beignets
   bibimbap
   bread_pudding
   breakfast_burrito
   bruschetta
   caesar_salad
   cannoli
   caprese_salad
   carrot_cake
   ceviche
   cheesecake
   cheese_plate
   chicken_curry
   chicken_quesadilla
   chicken_wings
   chocolate_cake
   chocolate_mousse
   churros
   clam_chowder
   club_sandwich
   crab_cakes
   creme_brulee
   croque_madame
   cup_cakes
   deviled_eggs
   donuts
   dumplings
   edamame
   eggs_benedict
   escargots
   falafel
   filet_mignon
   fish_and_chips
   foie_gras
   french_fries
   french_onion_soup
   french_toast
   fried_calamari
   fried_rice
   frozen_yogurt
   garlic_bread
   gnocchi
   greek_salad
   grilled_cheese_sandwich
   grilled_salmon
   guacamole
   gyoza
   hamburger
   hot_and_sour_soup
   hot_dog
   huevos_rancheros
   hummus
   ice_cream
   lasagna
   lobster_bisque
   lobster_roll_sandwich
   macaroni_and_cheese
   macarons
   miso_soup
   mussels
   nachos
   omelette
   onion_rings
   oysters
   pad_thai
   paella
   pancakes
   panna_cotta
   peking_duck
   pho
   pizza
   pork_chop
   poutine
   prime_rib
   pulled_pork_sandwich
   ramen
   ravioli
   red_velvet_cake
   risotto
   samosa
   sashimi
   scallops
   seaweed_salad
   shrimp_and_grits
   spaghetti_bolognese
   spaghetti_carbonara
   spring_rolls
   steak
   strawberry_shortcake
   sushi
   tacos
   takoyaki
   tiramisu
   tuna_tartare
   waffles
   ```

6. **Actualizar pubspec.yaml:**
   Asegúrate de incluir la carpeta de assets:
   ```yaml
   flutter:
     uses-material-design: true
     assets:
       - assets/models/food_classification.tflite
       - assets/models/food_labels.txt
   ```

7. **Ejecutar la app:**
   ```bash
   flutter pub get
   flutter run
   ```

## Opción 2: Entrenar tu Propio Modelo (Avanzado)

Si necesitas detectar comidas específicas que no están en Food-101:

1. **Recopilar datos:**
   - Tomar 100-500 fotos de cada plato
   - Variar ángulos, iluminación, presentación

2. **Entrenar con Python:**
   ```python
   # Usar TensorFlow o PyTorch
   import tensorflow as tf
   
   # Crear modelo base (Transfer Learning)
   base_model = tf.keras.applications.MobileNetV2(
       input_shape=(224, 224, 3),
       include_top=False,
       weights='imagenet'
   )
   
   # Añadir capas personalizadas
   model = tf.keras.Sequential([
       base_model,
       tf.keras.layers.GlobalAveragePooling2D(),
       tf.keras.layers.Dense(128, activation='relu'),
       tf.keras.layers.Dropout(0.2),
       tf.keras.layers.Dense(NUM_CLASSES, activation='softmax')
   ])
   
   # Entrenar
   model.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])
   model.fit(train_data, epochs=20)
   
   # Convertir a TFLite
   converter = tf.lite.TFLiteConverter.from_keras_model(model)
   tflite_model = converter.convert()
   
   # Guardar
   with open('food_classification.tflite', 'wb') as f:
       f.write(tflite_model)
   ```

3. **Optimizar para móvil:**
   ```python
   # Cuantización (reduce tamaño y mejora velocidad)
   converter.optimizations = [tf.lite.Optimize.DEFAULT]
   converter.target_spec.supported_types = [tf.float16]
   ```

## Opción 3: Usar API en la Nube (Alternativa)

Si no quieres descargar el modelo, puedes usar:
- **Google Vision API**: $1.50 por 1000 imágenes
- **Azure Computer Vision**: $1 por 1000 transacciones
- **AWS Rekognition**: $1 por 1000 imágenes

Requiere conexión a internet pero no ocupa espacio en la app.

## Solución de Problemas

### "Modelo no encontrado"
- Verificar que el archivo esté en `assets/models/`
- Ejecutar `flutter clean && flutter pub get`

### "Out of Memory" en dispositivos antiguos
- Usar modelo más pequeño (MobileNetV1 en lugar de V2)
- Reducir tamaño de entrada a 160x160

### Precisión baja
- Asegurar buena iluminación al tomar la foto
- El plato debe ocupar más del 50% de la imagen
- Usar modelo con más clases o entrenar específicamente

## Recursos Adicionales

- **Food-101 Dataset**: http://data.vision.ee.ethz.ch/cvl/food-101.tar.gz
- **TensorFlow Lite Guide**: https://www.tensorflow.org/lite/guide
- **Modelos Pre-entrenados**: https://tfhub.dev/s?module-type=image-classification
- **Flutter TFLite**: https://pub.dev/packages/tflite_flutter

## Nota Importante

El servicio `FoodRecognitionService` incluye valores nutricionales aproximados para las 101 comidas del dataset Food-101. Estos valores son estimaciones por 100g de alimento y pueden variar según la preparación y los ingredientes específicos.
