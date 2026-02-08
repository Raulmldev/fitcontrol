import 'package:flutter/material.dart';
import '../Control/ai_coordinator.dart';
import '../Model/ai_message.dart';
import '../Model/user.dart';

/// Pantalla de recomendaciones personalizadas y dinámicas
class RecommendationsScreen extends StatefulWidget {
  final User user;

  const RecommendationsScreen({
    super.key,
    required this.user,
  });

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  final AIAgentCoordinator _coordinator = AIAgentCoordinator();
  List<AIAgentMessage> _aiRecommendations = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    
    _slideController.forward();
    _loadAIRecommendations();
  }

  Future<void> _loadAIRecommendations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _coordinator.initialize(user: widget.user);
      final recommendations = await _coordinator.generateAllRecommendations(perAgent: 2);
      if (mounted) {
        setState(() {
          _aiRecommendations = recommendations;
        });
      }
    } catch (e) {
      debugPrint('Error cargando recomendaciones: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recommendations = _getPersonalizedRecommendations();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Recomendaciones',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF6A11CB),
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshRecommendations,
        color: const Color(0xFF6A11CB),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card principal - Recomendación del día
              SlideTransition(
                position: _slideAnimation,
                child: _buildMainRecommendation(),
              ),

              const SizedBox(height: 24),

              // Sección de Recomendaciones de Expertos IA
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_aiRecommendations.isNotEmpty)
                _buildAIRecommendationsSection(),

              const SizedBox(height: 24),

              // Recomendaciones por categorías (Estáticas/Fallback)
              ...recommendations.map(
                (category) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _buildCategoryRecommendations(category),
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshRecommendations() async {
    await _loadAIRecommendations();
  }

  Widget _buildMainRecommendation() {
    final mainRecommendation = _getMainRecommendation();
    
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  mainRecommendation.color,
                  mainRecommendation.color.withValues(alpha: 0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: mainRecommendation.color.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Card(
              elevation: 0,
              color: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            mainRecommendation.icon,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mainRecommendation.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Recomendación principal',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      mainRecommendation.content,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        mainRecommendation.action,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryRecommendations(CategoryRecommendations category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                category.icon,
                color: category.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                category.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            Text(
              '${category.items.length}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...category.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return AnimatedContainer(
            duration: Duration(milliseconds: 300 + (index * 100)),
            curve: Curves.easeOutBack,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildRecommendationItem(
                item: item,
                categoryColor: category.color,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRecommendationItem({
    required RecommendationItem item,
    required Color categoryColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _onRecommendationTap(item),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: categoryColor.withValues(alpha: 0.1),
                  child: Icon(
                    item.icon,
                    color: categoryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (item.urgency != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: item.urgency!.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.urgency!.label,
                          style: TextStyle(
                            color: item.urgency!.color,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAIRecommendationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text(
              'Insights de tus Expertos IA',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _aiRecommendations.length,
            itemBuilder: (context, index) {
              final rec = _aiRecommendations[index];
              return _buildAIRecCard(rec);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAIRecCard(AIAgentMessage message) {
    final color = _getAgentColor(message.agentId);
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getAgentIcon(message.agentId), color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  message.agentName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                message.content,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, height: 1.4),
              ),
            ),
            const SizedBox(height: 8),
            if (message.suggestions != null && message.suggestions!.isNotEmpty)
              Text(
                message.suggestions!.first,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getAgentIcon(String agentId) {
    if (agentId.contains('nutrition')) return Icons.restaurant;
    if (agentId.contains('trainer')) return Icons.fitness_center;
    if (agentId.contains('health')) return Icons.favorite;
    return Icons.smart_toy;
  }

  Color _getAgentColor(String agentId) {
    if (agentId.contains('nutrition')) return Colors.green;
    if (agentId.contains('trainer')) return Colors.blue;
    if (agentId.contains('health')) return Colors.red;
    return Colors.deepPurple;
  }

  void _onRecommendationTap(RecommendationItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Acción: ${item.title}'),
        backgroundColor: const Color(0xFF6A11CB),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  MainRecommendation _getMainRecommendation() {
    final hour = DateTime.now().hour;
    final recommendations = [
      MainRecommendation(
        icon: Icons.fitness_center,
        title: '💪 ¡Entrena Ahora!',
        content: 'Tu meta diaria está a un paso. Un entrenamiento de 30 minutos mejorará tu energía y estado de ánimo.',
        action: '🏃 Comenzar entrenamiento de fuerza',
        color: Colors.blue,
      ),
      MainRecommendation(
        icon: Icons.restaurant,
        title: '🥗 Nutrición Optimizada',
        content: 'Tu cuerpo necesita nutrientes. Progédzalo con comidas balanceadas ricas en proteína.',
        action: '📱 Ver plan de comidas',
        color: Colors.green,
      ),
      MainRecommendation(
        icon: Icons.celebration,
        title: '🎉 ¡Excelente Progreso!',
        content: 'Has cumplido el 85% de tus metas esta semana. Tu consistencia está dando resultados.',
        action: '📊 Ver estadísticas',
        color: Colors.amber,
      ),
    ];
    
    return recommendations[hour % 3];
  }

  List<CategoryRecommendations> _getPersonalizedRecommendations() {
    return [
      CategoryRecommendations(
        title: 'Salud y Bienestar',
        icon: Icons.favorite,
        color: Colors.red,
        items: [
          RecommendationItem(
            icon: Icons.local_hospital,
            title: 'Control de Presión',
            description: 'Mide tu presión arterial matutina',
            urgency: RecommendationUrgency.medium,
          ),
          RecommendationItem(
            icon: Icons.opacity,
            title: 'Hidratación',
            description: 'Bebe 2.5L de agua durante el día',
            urgency: RecommendationUrgency.high,
          ),
          RecommendationItem(
            icon: Icons.bedtime,
            title: 'Descanso',
            description: 'Duerme 7-8 horas para recuperación',
            urgency: RecommendationUrgency.low,
          ),
        ],
      ),
      CategoryRecommendations(
        title: 'Entrenamiento',
        icon: Icons.fitness_center,
        color: Colors.blue,
        items: [
          RecommendationItem(
            icon: Icons.directions_run,
            title: 'Cardio',
            description: '20 minutos de cardio moderado',
            urgency: RecommendationUrgency.medium,
          ),
          RecommendationItem(
            icon: Icons.sports_gymnastics,
            title: 'Fuerza',
            description: 'Entrenamiento de torso: 3x10 repeticiones',
            urgency: RecommendationUrgency.high,
          ),
          RecommendationItem(
            icon: Icons.self_improvement,
            title: 'Flexibilidad',
            description: '10 minutos de estiramientos',
            urgency: RecommendationUrgency.low,
          ),
        ],
      ),
      CategoryRecommendations(
        title: 'Nutrición',
        icon: Icons.restaurant,
        color: Colors.green,
        items: [
          RecommendationItem(
            icon: Icons.breakfast_dining,
            title: 'Desayuno',
            description: 'Avena + frutas + proteína',
            urgency: RecommendationUrgency.high,
          ),
          RecommendationItem(
            icon: Icons.lunch_dining,
            title: 'Almuerzo',
            description: 'Pollo + arroz integral + vegetales',
            urgency: RecommendationUrgency.medium,
          ),
          RecommendationItem(
            icon: Icons.dinner_dining,
            title: 'Cena',
            description: 'Pescado + ensalada + quinoa',
            urgency: RecommendationUrgency.low,
          ),
        ],
      ),
    ];
  }
}

// Modelos de datos
class MainRecommendation {
  final IconData icon;
  final String title;
  final String content;
  final String action;
  final Color color;

  MainRecommendation({
    required this.icon,
    required this.title,
    required this.content,
    required this.action,
    required this.color,
  });
}

class CategoryRecommendations {
  final String title;
  final IconData icon;
  final Color color;
  final List<RecommendationItem> items;

  CategoryRecommendations({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });
}

class RecommendationItem {
  final IconData icon;
  final String title;
  final String description;
  final RecommendationUrgency? urgency;

  RecommendationItem({
    required this.icon,
    required this.title,
    required this.description,
    this.urgency,
  });
}

class RecommendationUrgency {
  final String label;
  final Color color;

  const RecommendationUrgency._(this.label, this.color);

  static const high = RecommendationUrgency._('Alta', Colors.red);
  static const medium = RecommendationUrgency._('Media', Colors.orange);
  static const low = RecommendationUrgency._('Baja', Colors.green);
}