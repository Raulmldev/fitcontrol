import 'package:flutter/material.dart';
import '../Model/user.dart';

class ConclusionScreen extends StatefulWidget {
  final User user;

  const ConclusionScreen({super.key, required this.user});

  @override
  State<ConclusionScreen> createState() => _ConclusionScreenState();
}

class _ConclusionScreenState extends State<ConclusionScreen> {
  String? _conclusionReport;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _generateConclusion();
  }

  Future<void> _generateConclusion() async {
    // Simulate complex analysis or call agents
    // In a real scenario, this would trigger a multi-agent analysis via Coordinator
    // For now, we simulate a delay and use a static detailed template that would come from AI

    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    setState(() {
      _conclusionReport = '''
# INFORME INTEGRAL DE PROGRESO

## RESUMEN EJECUTIVO
El usuario ${widget.user.name} ha demostrado un compromiso excepcional con su objetivo de "${widget.user.fitnessGoal}". Los indicadores biométricos y de comportamiento sugieren una adaptación positiva al régimen actual.

## ANÁLISIS POR ÁREAS

### 1. NUTRICIÓN (Dra. Elena Martínez)
La adherencia al déficit calórico ha sido del 85%, lo cual es sostenible y efectivo.
*   **Puntos Fuertes**: Consumo adecuado de proteínas matutinas.
*   **Áreas de Mejora**: Incrementar la ingesta de fibra en la cena.
*   **Recomendación**: Mantener el plan actual por 4 semanas más antes de ajustar macros.

### 2. ENTRENAMIENTO (Carlos Rodríguez)
Se observa una mejora del 15% en fuerza general.
*   **Rendimiento**: La recuperación entre series ha mejorado.
*   **Técnica**: La forma en sentadillas es sólida.
*   **Ajuste**: Aumentar el volumen en tren superior la próxima semana.

### 3. SALUD (Dr. Antonio Vásquez)
Los signos vitales están estables y en rangos óptimos.
*   **Cardiovascular**: FC en reposo ha bajado de 68 a 62 lpm.
*   **Descanso**: Calidad de sueño promedio 7.5h.
*   **Alerta**: Ninguna. Continuar monitoreo estándar.

## CONCLUSIÓN FINAL
El progreso es constante y saludable. No se requieren cambios drásticos en la estrategia. La coordinación entre nutrición y entrenamiento está funcionando para maximizar la pérdida de grasa mientras se preserva la masa muscular.

**Próxima revisión detallada sugerida**: En 30 días.
''';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conclusión y Reporte'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text('Generando análisis integral con 15 agentes...'),
                    Text(
                      'Por favor espere...',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.assessment,
                              size: 40,
                              color: Colors.deepPurple,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Reporte Generado: ${DateTime.now().toString().split(' ')[0]}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                        Text(
                          _conclusionReport ?? 'Error al generar reporte.',
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.check),
                            label: const Text('Entendido'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
