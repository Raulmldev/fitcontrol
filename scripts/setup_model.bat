@echo off
chcp 65001 >nul

REM Script para ejecutar el descargador de modelo en Windows
REM Uso: setup_model.bat [opciones]

echo ==========================================
echo 🍕 FitControl - Setup Modelo TFLite
echo ==========================================
echo.

REM Verificar Python
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Error: Python no está instalado o no está en el PATH
    echo    Por favor, instala Python desde https://python.org
    echo    Asegúrate de marcar "Add Python to PATH" durante la instalación
    pause
    exit /b 1
)

echo ✅ Python detectado

REM Cambiar al directorio del script
cd /d "%~dp0"

REM Verificar si existe requirements.txt
if not exist "requirements.txt" (
    echo ⚠️  Creando archivo requirements.txt...
    (
        echo # Dependencias para el script de descarga de modelo
        echo tensorflow>=2.13.0
        echo numpy>=1.23.0
        echo pillow>=9.0.0
        echo requests>=2.28.0
    ) > requirements.txt
)

REM Preguntar si instalar dependencias
echo.
echo 📦 Este script necesita instalar dependencias de Python:
echo    - tensorflow ^(para crear/modelar el modelo^)
echo    - numpy, pillow, requests ^(utilidades^)
echo.
set /p install_deps="¿Deseas instalarlas ahora? (s/n): "

if /i "%install_deps%"=="s" (
    echo.
    echo ⬇️  Instalando dependencias...
    echo    ^(Esto puede tomar varios minutos la primera vez...^)
    pip install -r requirements.txt
    
    if errorlevel 1 (
        echo ❌ Error al instalar dependencias
        echo    Intenta instalar manualmente:
        echo    pip install tensorflow numpy pillow requests
        pause
        exit /b 1
    )
    
    echo ✅ Dependencias instaladas
) else (
    echo ⚠️  Continuando sin verificar dependencias...
)

echo.
echo 🚀 Ejecutando script de descarga...
echo.

REM Ejecutar script Python con todas las opciones pasadas
python download_food_model.py %*

set EXIT_CODE=%ERRORLEVEL%

echo.
if %EXIT_CODE% == 0 (
    echo 🎉 ¡Modelo configurado exitosamente!
    echo.
    echo 📱 Siguientes pasos:
    echo    1. flutter pub get
    echo    2. flutter run
    echo.
    echo 🔍 Prueba la detección de comida en:
    echo    Nutrición → Registrar Comida → Detectar con IA
    echo.
    echo Presiona cualquier tecla para salir...
    pause >nul
) else (
    echo ❌ Hubo problemas configurando el modelo
    echo.
    echo 💡 Puedes intentar:
    echo    1. Descargar manualmente desde:
    echo       https://github.com/STMicroelectronics/stm32ai-modelzoo
    echo    2. Usar Teachable Machine:
    echo       https://teachablemachine.withgoogle.com/
    echo.
    echo Presiona cualquier tecla para salir...
    pause >nul
)

exit /b %EXIT_CODE%
