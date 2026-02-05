import 'package:flutter/material.dart';
import '../Control/food_recognition_service.dart';
import '../Control/food_api_service.dart';

/// Pantalla de demostración del Web Scraping de alimentos
class FoodScrapingDemoScreen extends StatefulWidget {
  const FoodScrapingDemoScreen({super.key});

  @override
  State<FoodScrapingDemoScreen> createState() => _FoodScrapingDemoScreenState();
}

class _FoodScrapingDemoScreenState extends State<FoodScrapingDemoScreen> {
  final FoodRecognitionService _recognitionService = FoodRecognitionService();
  final FoodAPIService _apiService = FoodAPIService();
  
  final TextEditingController _foodController = TextEditingController();
  String _currentFood = '';
  bool _isLoading = false;
  Map<String, dynamic>? _lastResult;
  Map<String, dynamic>? _systemStats;
  final List<String> _searchHistory = [];
  
  // Lista de alimentos de demostración
  final List<String> _demoFoods = [
    'pollo', 'arroz', 'manzana', 'broccoli', 'huevo',
    'banana', 'leche', 'pan', 'pasta', 'salmón',
    'pizza', 'hamburguesa', 'ensalada', 'sushi', 'aguacate'
  ];

  @override
  void initState() {
    super.initState();
    _loadSystemStats();
  }

  Future<void> _loadSystemStats() async {
    final stats = await _apiService.getSystemStats();
    if (mounted) {
      setState(() {
        _systemStats = stats;
      });
    }
  }

  Future<void> _searchFood(String foodName) async {
    if (foodName.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _currentFood = foodName.trim();
      _lastResult = null;
    });

    try {
      // Usar el servicio de reconocimiento mejorado con scraping
      final result = await _recognitionService.getFoodNutrition(foodName);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _lastResult = result?.toJson();
          
          if (!_searchHistory.contains(foodName.trim())) {
            _searchHistory.add(foodName.trim());
            if (_searchHistory.length > 10) {
              _searchHistory.removeAt(0);
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _lastResult = {'error': e.toString()};
        });
      }
    }
  }

  Future<void> _syncDatabase() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final syncedData = await _apiService.syncFoodDatabase(limit: 5);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Base sincronizada: ${syncedData.length} alimentos'),
            backgroundColor: Colors.green,
          ),
        );
        
        await _loadSystemStats();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en sincronización: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Web Scraping Demo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF6A11CB),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadSystemStats,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar estadísticas',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Búsqueda de alimentos
            _buildSearchSection(),
            
            const SizedBox(height: 24),
            
            // Estadísticas del sistema
            _buildSystemStatsSection(),
            
            const SizedBox(height: 24),
            
            // Resultado actual
            if (_currentFood.isNotEmpty)
              _buildCurrentResultSection(),
            
            const SizedBox(height: 24),
            
            // Alimentos de demostración
            _buildDemoFoodsSection(),
            
            const SizedBox(height: 24),
            
            // Acciones del sistema
            _buildSystemActionsSection(),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.search,
                  color: Colors.deepPurple,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Buscar Alimento',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _foodController,
                    decoration: InputDecoration(
                      hintText: 'Ej: pollo, arroz, manzana...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.restaurant),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (value) => _searchFood(value),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _isLoading 
                      ? null 
                      : () => _searchFood(_foodController.text),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.search),
                  label: const Text('Buscar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            
            if (_searchHistory.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Búsquedas recientes:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _searchHistory.map((food) => ActionChip(
                  label: Text(food),
                  onPressed: () {
                    _foodController.text = food;
                    _searchFood(food);
                  },
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSystemStatsSection() {
    if (_systemStats == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: Colors.blue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Estadísticas del Sistema',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Cache Local',
                    '${_systemStats!['localCacheSize'] ?? 0}',
                    Icons.storage,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Estado',
                    _systemStats!['status'] ?? 'unknown',
                    _systemStats!['status'] == 'healthy' 
                        ? Icons.check_circle 
                        : Icons.warning,
                    _systemStats!['status'] == 'healthy' 
                        ? Colors.green 
                        : Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentResultSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resultado: $_currentFood',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (_lastResult != null)
              _buildResultDetails(_lastResult!)
            else
              const Text('Realiza una búsqueda para ver resultados'),
          ],
        ),
      ),
    );
  }

  Widget _buildResultDetails(Map<String, dynamic> result) {
    if (result.containsKey('error')) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                result['error'],
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Calorías', '${result['calories']?.toStringAsFixed(0) ?? 'N/A'} kcal'),
        _buildDetailRow('Proteína', '${result['protein']?.toStringAsFixed(1) ?? 'N/A'} g'),
        _buildDetailRow('Carbohidratos', '${result['carbs']?.toStringAsFixed(1) ?? 'N/A'} g'),
        _buildDetailRow('Grasas', '${result['fat']?.toStringAsFixed(1) ?? 'N/A'} g'),
        _buildDetailRow('Fibra', '${result['fiber']?.toStringAsFixed(1) ?? 'N/A'} g'),
        _buildDetailRow('Fuente', result['source'] ?? 'N/A'),
        _buildDetailRow('Categoría', result['category'] ?? 'N/A'),
        _buildDetailRow('Confianza', '${((result['confidence'] ?? 0) * 100).toStringAsFixed(0)}%'),
        if (result['servingSize'] != null)
          _buildDetailRow('Porción', result['servingSize']),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const Text(': '),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildDemoFoodsSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.fastfood,
                  color: Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Alimentos de Demostración',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _demoFoods.map((food) => ActionChip(
                label: Text(food),
                onPressed: () {
                  _foodController.text = food;
                  _searchFood(food);
                },
                backgroundColor: Colors.orange.withValues(alpha: 0.1),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemActionsSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings,
                  color: Colors.purple,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Acciones del Sistema',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _syncDatabase,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.sync),
                label: const Text('Sincronizar Base de Datos'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _apiService.clearAllCaches();
                  _loadSystemStats();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cache limpiado'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Limpiar Caches'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}