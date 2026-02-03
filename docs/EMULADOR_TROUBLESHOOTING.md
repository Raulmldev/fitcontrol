# Solución: "Emulator didn't connect within 60 seconds"

Guía práctica para resolver errores de conexión del emulador Android en Flutter.

---

## Causas Comunes

- **Emulador en estado congelado**: Quedó en segundo plano sin responder
- **Problemas de ADB**: El demonio ADB no está funcionando correctamente
- **Puerto ocupado**: Otro proceso usa el puerto que necesita el emulador
- **Memoria insuficiente**: El emulador no tiene recursos suficientes
- **Imagen del emulador corrupta**: Datos del dispositivo virtual dañados

---

## Solución Rápida (3 Pasos)

```bash
# 1. Matar todos los procesos del emulador y ADB
taskkill /F /IM qemu-system-x86_64.exe 2>nul
taskkill /F /IM adb.exe 2>nul

# 2. Reiniciar ADB
adb kill-server
adb start-server

# 3. Crear nuevo emulador limpio
flutter emulators --launch <id_emulador>
```

---

## Solución Detallada con Android Studio

### Paso 1: Eliminar emuladores conflictivos

1. Abre **Android Studio**
2. Ve a: `Tools` → `Device Manager`
3. Selecciona el emulador problemático
4. Haz clic en la flecha desplegable → **Delete**

### Paso 2: Crear nuevo emulador

1. En Device Manager, haz clic en **Create Device**
2. Selecciona **Pixel 4** (recomendado)
3. Descarga e instala: **API 33** o **API 34**
4. Selecciona imagen **x86_64** o **arm64-v8a**
5. Configuración recomendada:
   - **RAM**: 2048 MB (mínimo)
   - **Graphics**: Automatic o Hardware
   - **Boot option**: Cold boot

### Paso 3: Configurar aceleración de hardware

```bash
# Verificar que HAXM está instalado
sc query intelhaxm

# Si no está instalado, descargar desde:
# https://github.com/intel/haxm/releases
```

**Alternativa (Windows 10/11)**: Usar **Windows Hypervisor Platform**:
1. Panel de Control → Programas → Activar o desactivar características de Windows
2. Marcar: **Windows Hypervisor Platform**
3. Reiniciar

---

## Alternativa: Usar Dispositivo Físico

### Configuración en el teléfono

1. Activar **Opciones de desarrollador**:
   - Ajustes → Acerca del teléfono → Tocar "Número de compilación" 7 veces

2. Habilitar:
   - ✓ **Depuración USB**
   - ✓ **Instalar vía USB**

### Conectar al PC

```bash
# Verificar dispositivo conectado
adb devices

# Salida esperada:
# List of devices attached
# ABC123DEF456    device

# Ejecutar en dispositivo físico
flutter run -d <device_id>
```

---

## Alternativa: Usar Chrome

Para apps que no requieren funciones nativas específicas de Android:

```bash
# Listar dispositivos disponibles
flutter devices

# Ejecutar en Chrome
flutter run -d chrome

# Ejecutar en modo responsive
flutter run -d chrome --web-renderer html
```

**Ventajas**:
- Sin emulador pesado
- Hot reload más rápido
- Ideal para UI/UX testing

---

## Verificación de SDK de Android

### Variables de entorno necesarias

```bash
# Windows (PowerShell como Administrador)
[Environment]::SetEnvironmentVariable("ANDROID_HOME", "$env:LOCALAPPDATA\Android\Sdk", "User")
[Environment]::SetEnvironmentVariable("Path", "$env:Path;$env:LOCALAPPDATA\Android\Sdk\platform-tools", "User")
```

### Verificar instalación

```bash
# Flutter doctor
flutter doctor -v

# Verificar ruta de Android SDK
flutter config --android-sdk

# Listar emuladores disponibles
flutter emulators
```

### Instalar componentes faltantes

```bash
# Usando sdkmanager
sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0"

# Usando Android Studio
# SDK Manager → SDK Platforms → Android 13.0 (API 33)
# SDK Manager → SDK Tools → Android SDK Platform-Tools
```

---

## Limpieza de Caché

### Limpieza de Flutter

```bash
# Limpiar caché de build
flutter clean

# Limpiar caché de pub
flutter pub cache clean

# Obtener dependencias nuevamente
flutter pub get

# Precache para acelerar futuras compilaciones
flutter precache
```

### Limpieza de Gradle (Android)

```bash
# En la carpeta del proyecto
./gradlew clean        # Mac/Linux
.\gradlew.bat clean    # Windows

# O manualmente:
# Eliminar carpetas: android/.gradle y android/app/build
```

### Limpieza de emuladores

```bash
# Ubicación de datos del emulador (Windows)
%USERPROFILE%\.android\avd\

# Eliminar todos los datos del emulador
# ADVERTENCIA: Perderás todos los datos del emulador
rmdir /s /q %USERPROFILE%\.android\avd\

# Reiniciar ADB limpio
adb kill-server
adb start-server
```

---

## Diagnóstico Rápido

Ejecuta estos comandos para identificar el problema:

```bash
# 1. Verificar estado de Flutter
flutter doctor

# 2. Ver emuladores disponibles
flutter emulators

# 3. Ver dispositivos conectados
flutter devices

# 4. Logs detallados del emulador
flutter emulators --launch <emulator_id> --verbose

# 5. Ver logs de ADB
adb logcat -d > adb_logs.txt
```

---

## Comandos Útiles de Referencia

```bash
# Iniciar emulador específico
flutter emulators --launch Pixel_4_API_33

# Ejecutar en modo debug
flutter run --debug

# Ejecutar con logs detallados
flutter run --verbose

# Forzar reinicio de app
flutter run --hot-restart
```

---

## Notas Finales

- Si el problema persiste, intenta reiniciar el sistema
- Considera usar dispositivo físico para desarrollo diario
- Mantén Android Studio y Flutter actualizados
- Verifica que tu sistema tenga al menos 8GB de RAM disponibles para el emulador
