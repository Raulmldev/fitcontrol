#!/bin/bash

# Script para ejecutar el descargador de modelo en Linux/Mac
# Uso: ./setup_model.sh [opciones]

echo "=========================================="
echo "🍕 FitControl - Setup Modelo TFLite"
echo "=========================================="
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verificar Python
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Error: Python 3 no está instalado${NC}"
    echo "   Por favor, instala Python 3 desde https://python.org"
    exit 1
fi

echo -e "${GREEN}✅ Python 3 detectado${NC}"

# Cambiar al directorio del script
cd "$(dirname "$0")"

# Verificar si existe requirements.txt
if [ ! -f "requirements.txt" ]; then
    echo -e "${YELLOW}⚠️  Creando archivo requirements.txt...${NC}"
    cat > requirements.txt << EOF
# Dependencias para el script de descarga de modelo
tensorflow>=2.13.0
numpy>=1.23.0
pillow>=9.0.0
requests>=2.28.0
EOF
fi

# Preguntar si instalar dependencias
echo ""
echo "📦 Este script necesita instalar dependencias de Python:"
echo "   - tensorflow (para crear/modelar el modelo)"
echo "   - numpy, pillow, requests (utilidades)"
echo ""
read -p "¿Deseas instalarlas ahora? (s/n): " install_deps

if [[ $install_deps =~ ^[Ss]$ ]]; then
    echo ""
    echo "⬇️  Instalando dependencias..."
    pip3 install -r requirements.txt
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Error al instalar dependencias${NC}"
        echo "   Intenta instalar manualmente:"
        echo "   pip3 install tensorflow numpy pillow requests"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Dependencias instaladas${NC}"
else
    echo -e "${YELLOW}⚠️  Continuando sin verificar dependencias...${NC}"
fi

echo ""
echo "🚀 Ejecutando script de descarga..."
echo ""

# Ejecutar script Python con todas las opciones pasadas
python3 download_food_model.py "$@"

EXIT_CODE=$?

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}🎉 ¡Modelo configurado exitosamente!${NC}"
    echo ""
    echo "📱 Siguientes pasos:"
    echo "   1. flutter pub get"
    echo "   2. flutter run"
    echo ""
    echo "🔍 Prueba la detección de comida en:"
    echo "   Nutrición → Registrar Comida → Detectar con IA"
else
    echo -e "${RED}❌ Hubo problemas configurando el modelo${NC}"
    echo ""
    echo "💡 Puedes intentar:"
    echo "   1. Descargar manualmente desde:"
    echo "      https://github.com/STMicroelectronics/stm32ai-modelzoo"
    echo "   2. Usar Teachable Machine:"
    echo "      https://teachablemachine.withgoogle.com/"
    echo ""
fi

exit $EXIT_CODE
