# Solución Express: Modelo en 5 Minutos (Teachable Machine)

## 🎯 La Forma Más Fácil (100% Gratis, Sin Instalar Nada)

Google Teachable Machine crea el modelo por ti **sin código** y lo exporta listo para usar en tu app.

---

## 📱 PASO 1: Ir a Teachable Machine (2 minutos)

**URL:** https://teachablemachine.withgoogle.com/

Haz clic en: **"Get Started"** → **"Image Project"**

---

## 📸 PASO 2: Crear Clases de Comida (2 minutos)

Verás una pantalla con "Class 1", "Class 2", etc.

**Añade 5-10 comidas que comas frecuentemente:**

### Ejemplo práctico:
```
Class 1: Pizza
  → Arrastra 10-20 fotos de pizza
  
Class 2: Hamburguesa  
  → Arrastra 10-20 fotos de hamburguesas

Class 3: Sushi
  → Arrastra 10-20 fotos de sushi

Class 4: Ensalada
  → Arrastra 10-20 fotos de ensaladas

Class 5: Pasta
  → Arrastra 10-20 fotos de pasta
```

**Consejo:** Busca fotos en Google Images y las arrastras directamente.

---

## 🎓 PASO 3: Entrenar (30 segundos)

Haz clic en el botón grande: **"Train Model"**

- Espera 30-60 segundos
- ¡Listo! El modelo se entrena automáticamente

---

## 💾 PASO 4: Exportar a TFLite (30 segundos)

1. Haz clic en: **"Export Model"** (arriba derecha)
2. Selecciona pestaña: **"Tensorflow Lite"**
3. Cambia: **"Floating point"** (no quantized)
4. Clic en: **"Download my model"**

Se descargará un archivo ZIP con:
- `model.tflite` ← Este es el que necesitas
- `labels.txt` ← Las etiquetas (pizza, hamburguesa, etc.)

---

## 📁 PASO 5: Colocar en tu Proyecto (1 minuto)

1. **Descomprime** el ZIP descargado
2. **Renombra** `model.tflite` → `food_classifier.tflite`
3. **Copia** el archivo a tu proyecto:
   ```
   fitcontrol/assets/models/food_classifier.tflite
   ```
4. **Copia** también `labels.txt` (opcional, ya tienes uno)

---

## 🚀 PASO 6: Probar (1 minuto)

```bash
cd fitcontrol
flutter pub get
flutter run
```

Ve a: **Nutrición → Registrar Comida → Detectar con IA**

¡Ahora detectará las comidas que entrenaste!

---

## ✅ Ventajas de Esta Solución

- ✅ **Gratis** - No cuesta nada
- ✅ **Sin código** - Todo visual
- ✅ **Tú eliges** - Entrenas con TUS comidas
- ✅ **Privacidad** - Todo en tu dispositivo
- ✅ **Tamaño pequeño** - ~5-15 MB dependiendo de clases
- ✅ **Funciona offline** - 100%

---

## 🎨 Personalización Avanzada

### ¿Quieres más precisión?
- Usa **30-50 fotos** por comida en lugar de 10-20
- Varía ángulos: arriba, lado, lejos, cerca
- Diferentes presentaciones del mismo plato

### ¿Quieres más comidas?
- Teachable Machine soporta **hasta 100 clases**
- Pero recomendado: **5-15 comidas** para mejor precisión
- Ejemplo completo:
  ```
  Pizza, Hamburguesa, Sushi, Ensalada, Pasta,
  Tacos, Pollo, Steak, Sandwich, Sopa,
  Desayuno, Postre, Fruta
  ```

---

## 📊 Tamaño del Modelo

| Número de Comidas | Tamaño Aproximado | Precisión |
|-------------------|-------------------|-----------|
| 5 comidas         | ~8 MB            | 85-90%    |
| 10 comidas        | ~12 MB           | 80-85%    |
| 20 comidas        | ~18 MB           | 75-80%    |

---

## 🆘 Solución de Problemas

### "No tengo suficientes fotos"
- Busca en Google Images: "pizza top view", "hamburger plate"
- Descarga 10-15 fotos de cada uno
- ¡Listo para arrastrar!

### "El modelo no detecta bien"
- Añade más fotos (objetivo: 30 por comida)
- Asegúrate de que el plato ocupe la mayor parte de la foto
- Entrena de nuevo (clic en "Train Model" otra vez)

### "No encuentro Exportar"
- Busca el botón "Export Model" arriba derecha
- Asegúrate de haber entrenado primero
- Debe aparecer después de "Train Model"

---

## ⏱️ Tiempo Total Estimado

- Ir a Teachable Machine: 1 min
- Crear 5-10 clases: 3 min
- Entrenar: 1 min
- Exportar: 1 min
- Colocar en proyecto: 1 min

**Total: ~7 minutos** 🎉

---

## 🎥 Video Tutorial

Si prefieres ver paso a paso:
- Busca en YouTube: "Teachable Machine tutorial TensorFlow Lite"
- Hay videos de 5-10 minutos muy claros

---

## 📝 Resumen Visual

```
1. teachablemachine.withgoogle.com → Image Project
2. Class 1: Pizza → 20 fotos
   Class 2: Hamburguesa → 20 fotos
   Class 3: Sushi → 20 fotos
   ...
3. [Train Model] ⏳ 30 segundos
4. [Export Model] → TensorFlow Lite → Download
5. Copiar model.tflite a assets/models/
6. ¡Listo! 🎉
```

---

## ✅ ¿Listo para hacerlo?

Te recomiendo empezar con **5 comidas** que comas frecuentemente:
1. Pizza
2. Hamburguesa  
3. Sushi
4. Ensalada
5. Pasta

Así tendrás un modelo pequeño (~8 MB), rápido y preciso.

**¿Te animas a hacerlo ahora?** Solo necesitas tu navegador y arrastrar fotos.
