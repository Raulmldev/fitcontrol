import 'package:flutter/material.dart';
import '../Control/food_scraping_service.dart';

/// Widget que muestra información nutricional con datos de web scraping
class FoodNutritionCard extends StatefulWidget {
  final String foodName;
  final FoodNutritionData? nutritionData;
  final VoidCallback? onRefresh;
  final bool isLoading;

  const FoodNutritionCard({
    super.key,
    required this.foodName,
    this.nutritionData,
    this.onRefresh,
    this.isLoading = false,
  });

  @override
  State<FoodNutritionCard> createState() => _FoodNutritionCardState();
}

class _FoodNutritionCardState extends State<FoodNutritionCard>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.nutritionData != null) {
      _slideController.forward();
      _fadeController.forward();
    }
  }

  @override
  void didUpdateWidget(FoodNutritionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.nutritionData != oldWidget.nutritionData) {
      if (widget.nutritionData != null) {
        _slideController.forward();
        _fadeController.forward();
      } else {
        _slideController.reverse();
        _fadeController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: _getPrimaryColor().withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              _getPrimaryColor().withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con nombre del alimento
            _buildHeader(),
            
            // Contenido principal
            if (widget.isLoading)
              _buildLoadingState()
            else if (widget.nutritionData != null)
              _buildNutritionContent()
            else
              _buildNotFoundState(),
            
            // Footer con acciones
            if (widget.nutritionData != null || widget.isLoading)
              _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_getPrimaryColor(), _getPrimaryColor().withValues(alpha: 0.8)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.restaurant,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.foodName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.nutritionData != null)
                      Text(
                        _getCategoryDisplay(),
                        style: TextStyle(
                           color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
          ),
          SizedBox(height: 16),
          Text(
            'Buscando información nutricional...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No encontramos información',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta con otro alimento o recarga',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionContent() {
    if (widget.nutritionData == null) return const SizedBox.shrink();
    
    final nutrition = widget.nutritionData!;
    
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Métricas principales
              _buildMacroNutrients(nutrition),
              
              const SizedBox(height: 24),
              
              // Información de confianza
              _buildConfidenceInfo(nutrition),
              
              const SizedBox(height: 20),
              
              // Tamaño de porción
              _buildServingInfo(nutrition),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroNutrients(FoodNutritionData nutrition) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información Nutricional',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),
        
        // Calorías grandes
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getPrimaryColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                nutrition.calories.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: _getPrimaryColor(),
                ),
              ),
              Text(
                'calorías',
                style: TextStyle(
                  fontSize: 14,
                  color: _getPrimaryColor().withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Macros en grid
        Row(
          children: [
            Expanded(child: _buildMacroItem('Proteína', nutrition.protein, Colors.blue)),
            const SizedBox(width: 12),
            Expanded(child: _buildMacroItem('Carbos', nutrition.carbs, Colors.orange)),
            const SizedBox(width: 12),
            Expanded(child: _buildMacroItem('Grasas', nutrition.fat, Colors.red)),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Fibra
        _buildMacroItem('Fibra', nutrition.fiber, Colors.green),
      ],
    );
  }

  Widget _buildMacroItem(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceInfo(FoodNutritionData nutrition) {
    final confidenceColor = _getConfidenceColor(nutrition.confidence);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: confidenceColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: confidenceColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            _getConfidenceIcon(nutrition.confidence),
            color: confidenceColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nutrition.confidenceLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: confidenceColor,
                  ),
                ),
                Text(
                  'Fuente: ${nutrition.source}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${(nutrition.confidence * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: confidenceColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServingInfo(FoodNutritionData nutrition) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.grey.shade600,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Porción',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  nutrition.servingSize,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Última actualización: ${_formatDate(nutrition.lastUpdated)}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    if (widget.onRefresh == null) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: widget.isLoading ? null : widget.onRefresh,
          icon: widget.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.refresh),
          label: Text(
            widget.isLoading ? 'Actualizando...' : 'Actualizar',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _getPrimaryColor(),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods
  Color _getPrimaryColor() {
    if (widget.nutritionData == null) return Colors.deepPurple;
    
    return switch (widget.nutritionData!.category) {
      'protein' => Colors.blue,
      'carbs' => Colors.orange,
      'fat' => Colors.red,
      'vegetable' => Colors.green,
      'fruit' => Colors.purple,
      'dairy' => Colors.indigo,
      _ => Colors.deepPurple,
    };
  }

  String _getCategoryDisplay() {
    if (widget.nutritionData == null) return '';
    
    return switch (widget.nutritionData!.category) {
      'protein' => '🥩 Proteína',
      'carbs' => '🍞 Carbohidratos',
      'fat' => '🥑 Grasas',
      'vegetable' => '🥗 Verdura',
      'fruit' => '🍎 Fruta',
      'dairy' => '🥛 Lácteos',
      'processed' => '🍕 Procesado',
      _ => '🍽️ Mixto',
    };
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.9) return Colors.green;
    if (confidence >= 0.7) return Colors.orange;
    return Colors.red;
  }

  IconData _getConfidenceIcon(double confidence) {
    if (confidence >= 0.9) return Icons.verified;
    if (confidence >= 0.7) return Icons.check_circle;
    return Icons.warning;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} días';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} horas';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} min';
    } else {
      return 'Ahora';
    }
  }
}