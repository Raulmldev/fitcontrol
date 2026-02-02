import 'package:flutter/material.dart';
import '../Model/user.dart';

class NutritionScreen extends StatelessWidget {
  final User user;

  const NutritionScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Responsive layout helper
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrición'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            if (isWide)
              _buildWideLayout(context)
            else
              _buildMobileLayout(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implement meal logging
        },
        icon: const Icon(Icons.add),
        label: const Text('Registrar Comida'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.green,
              radius: 30,
              child: Icon(Icons.restaurant, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Plan Nutricional',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Objetivo: ${user.targetCalories} kcal/día',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildDailyProgress(context)),
        const SizedBox(width: 24),
        Expanded(child: _buildMealList(context)),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _buildDailyProgress(context),
        const SizedBox(height: 24),
        _buildMealList(context),
      ],
    );
  }

  Widget _buildDailyProgress(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progreso Diario',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildMacroBar(
              'Calorías',
              1200.0,
              user.targetCalories.toDouble(),
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildMacroBar('Proteínas', 80.0, 150.0, Colors.blue),
            const SizedBox(height: 12),
            _buildMacroBar('Carbohidratos', 150.0, 200.0, Colors.orange),
            const SizedBox(height: 12),
            _buildMacroBar('Grasas', 40.0, 70.0, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroBar(
    String label,
    double current,
    double target,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text('${current.toInt()} / ${target.toInt()} g/kcal'),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: (current / target).clamp(0.0, 1.0),
          backgroundColor: color.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation(color),
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
        ),
      ],
    );
  }

  Widget _buildMealList(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Comidas de Hoy',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to chat with Nutritionist context
                  },
                  child: const Text('Consultar a Nutricionista'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildMealItem('Desayuno', 'Avena con frutas y nueces', 450),
            const Divider(),
            _buildMealItem('Almuerzo', 'Pechuga de pollo con ensalada', 650),
            const Divider(),
            _buildMealItem('Merienda', 'Yogurt griego', 150),
            const Divider(),
            _buildMealItem('Cena', 'Pendiente', 0, isPending: true),
          ],
        ),
      ),
    );
  }

  Widget _buildMealItem(
    String title,
    String description,
    int calories, {
    bool isPending = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        isPending ? Icons.radio_button_unchecked : Icons.check_circle,
        color: isPending ? Colors.grey : Colors.green,
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(description),
      trailing: Text('$calories kcal'),
    );
  }
}
