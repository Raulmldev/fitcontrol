# FitControl - Aplicación de Estilo de Vida Saludable con IA

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.7.2-blue.svg" alt="Flutter Version">
  <img src="https://img.shields.io/badge/Dart-3.0+-blue.svg" alt="Dart Version">
  <img src="https://img.shields.io/badge/IA-15%20Expertos-green.svg" alt="AI Experts">
  <img src="https://img.shields.io/badge/Experiencia-450%2B%20años-purple.svg" alt="Experience">
</p>

FitControl es una aplicación Flutter completa para gestionar un estilo de vida saludable, potenciada por un **equipo de 15 expertos de IA** con más de **450 años de experiencia combinada** en nutrición, entrenamiento personal y salud.

## ✨ Características Principales

### 🤖 Sistema Multi-Agente de IA

La aplicación cuenta con un equipo de 15 expertos de IA que trabajan coordinadamente:

#### Agentes Principales (3)

1. **Dra. Elena Martínez** - Nutricionista Clínica y Deportiva (32 años exp.)
   - Planificación de dietas personalizadas
   - Análisis de composición de alimentos
   - Gestión de listas de compras inteligentes
   - Coordinación con planes de entrenamiento

2. **Carlos "El Profesor" Rodríguez** - Entrenador Personal (35 años exp.)
   - Diseño de planes de entrenamiento personalizados
   - Periodización del entrenamiento
   - Análisis de técnica y progresión
   - Prevención de lesiones

3. **Dr. Antonio Vásquez** - Especialista en Salud (34 años exp.)
   - Monitoreo de parámetros vitales
   - Análisis de composición corporal
   - Medicina preventiva
   - Bienestar holístico

#### Especialistas de Apoyo (12)

4. **Dra. María Isabel Sánchez** - Psicología del Deporte (31 años exp.)
5. **Dr. Javier Morales** - Medicina del Sueño (33 años exp.)
6. **Dra. Patricia López** - Endocrinología Metabólica (30 años exp.)
7. **Dr. Roberto Gómez** - Cardiología del Ejercicio (32 años exp.)
8. **Dra. Carmen Fernández** - Nutrición Gastrointestinal (31 años exp.)
9. **Dr. Miguel Ángel Torres** - Rehabilitación Deportiva (35 años exp.)
10. **Ana "Shanti" González** - Yoga y Movilidad (30 años exp.)
11. **Chef Martín Benítez** - Cocina Saludable (32 años exp.)
12. **Dr. Fernando Ruiz** - Biomecánica (33 años exp.)
13. **Dra. Laura Mendoza** - Suplementación (31 años exp.)
14. **Dr. Alberto Vega** - Análisis de Datos de Salud (34 años exp.)
15. **Dra. Sofía Herrera** - Cambio de Hábitos (30 años exp.)

### 📱 Funcionalidades

- **Gestión de Comidas**: Planificación diaria, seguimiento calórico, análisis de macronutrientes
- **Ejercicios y Rutinas**: Planes personalizados, seguimiento de progreso, técnicas de ejercicio
- **Parámetros de Salud**: Monitoreo completo de signos vitales y composición corporal
- **Lista de Compras Inteligente**: Generada automáticamente basada en planes de comidas
- **Chat IA**: Interacción directa con los agentes para consultas personalizadas
- **Coordinación Inteligente**: Los agentes se comunican entre sí para ofrecer recomendaciones integrales

## 🏗️ Arquitectura

```
lib/
├── Control/                    # Controladores y lógica de negocio
│   ├── ai_agent_base.dart     # Clase base para agentes IA
│   ├── ai_coordinator.dart    # Coordinador del sistema multi-agente
│   ├── ai_expert_team.dart    # Definición del equipo de 15 expertos
│   ├── nutrition_agent.dart   # Agente nutricionista
│   ├── personal_trainer_agent.dart  # Agente entrenador
│   └── health_wellness_agent.dart   # Agente salud
├── Model/                      # Modelos de datos
│   ├── ai_message.dart        # Mensajes y conversaciones IA
│   ├── health_metrics.dart    # Parámetros de salud
│   ├── meal.dart              # Comidas y nutrición
│   ├── shopping_list.dart     # Lista de compras
│   ├── user.dart              # Usuario
│   └── workout.dart           # Ejercicios y rutinas
├── View/                       # Vistas de la aplicación
│   ├── ai_chat_screen.dart    # Chat con agentes IA
│   ├── ai_expert_team_screen.dart  # Vista del equipo
│   ├── dashboard_screen.dart  # Dashboard principal
│   ├── login.dart             # Pantalla de login
│   └── login_model.dart       # Modelo de login
└── main.dart                   # Punto de entrada
```

## 🚀 Instalación

1. **Clonar el repositorio**
```bash
git clone https://github.com/tuusuario/fitcontrol.git
cd fitcontrol
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Generar archivos Hive (opcional para persistencia)**
```bash
flutter pub run build_runner build
```

4. **Ejecutar la aplicación**
```bash
flutter run
```

## 📦 Dependencias Principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.1.2
  flutter_bloc: ^8.1.6
  
  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # UI Components
  fl_chart: ^0.69.0
  table_calendar: ^3.1.2
  percent_indicator: ^4.2.3
  flutter_slidable: ^3.1.1
  
  # Utilities
  intl: ^0.19.0
  uuid: ^4.5.1
```

## 🎯 Uso

### Iniciar Sesión
- Usa cualquier email y contraseña (demo) para acceder
- También puedes usar "Probar Asistente IA" para acceder directamente al chat

### Dashboard Principal
- Visualiza tu resumen diario de nutrición, ejercicio y salud
- Accede a los diferentes módulos desde el grid principal
- Conoce a tu equipo de expertos IA

### Chat con Agentes IA
- Escribe consultas sobre nutrición, ejercicio o salud
- Los agentes se coordinan automáticamente para darte la mejor respuesta
- Obtén recomendaciones personalizadas con un solo click

### Ver Equipo Completo
- Explora los perfiles de los 15 expertos de IA
- Conoce sus credenciales, experiencia y especializaciones
- Entiende cómo trabajan coordinadamente

## 🔧 Configuración Avanzada

### Integración con APIs de IA
Para integrar con APIs de IA reales (OpenAI, Google Gemini, etc.):

1. Configura tus API keys en un archivo `.env`
2. Modifica los agentes en `lib/Control/` para usar las APIs
3. Implementa los métodos `processQuery()` con llamadas reales a la API

### Personalización de Agentes
Puedes modificar las personalidades y conocimientos de los agentes editando:
- `lib/Control/nutrition_agent.dart`
- `lib/Control/personal_trainer_agent.dart`
- `lib/Control/health_wellness_agent.dart`

## 📊 Sistema de Coordinación Multi-Agente

El sistema utiliza un coordinador central (`AIAgentCoordinator`) que:

1. **Enruta consultas**: Determina qué agente es mejor para cada pregunta
2. **Gestiona coordinación**: Permite que los agentes soliciten información entre sí
3. **Consolida respuestas**: Combina recomendaciones de múltiples agentes
4. **Mantiene contexto**: Preserva el historial de conversaciones

### Ejemplo de Coordinación
```dart
// El nutricionista puede solicitar información al entrenador
await nutritionAgent.coordinateWithAgent(
  targetAgentId: 'trainer_expert_001',
  requestType: 'workout_nutrition',
  description: 'Necesito saber la intensidad del entrenamiento',
  data: {'intensity': 'high', 'duration': 60},
);
```

## 🧪 Testing

```bash
# Ejecutar tests
flutter test

# Ejecutar con coverage
flutter test --coverage
```

## 📱 Compilación

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🤝 Contribuir

1. Fork el repositorio
2. Crea una rama (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

## 📝 Licencia

Este proyecto está licenciado bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## 🙏 Agradecimientos

- Equipo de Flutter por el framework excepcional
- Comunidad de Dart por las librerías de código abierto
- Todos los expertos reales que inspiraron los agentes de IA

## 📞 Contacto

- **Email**: contacto@fitcontrol.app
- **Sitio Web**: https://fitcontrol.app
- **Twitter**: @FitControlApp

---

<p align="center">
  Desarrollado con ❤️ y 🤖 por el equipo de FitControl
</p>

<p align="center">
  <b>15 Expertos IA • 450+ Años de Experiencia • 1 Objetivo: Tu Salud</b>
</p>
