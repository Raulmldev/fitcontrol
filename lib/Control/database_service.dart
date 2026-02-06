import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../Model/meal.dart';

/// Servicio de Base de Datos para persistencia local de datos de FitControl
/// 
/// Usa SQLite para almacenar comidas, alimentos y estadísticas nutricionales.
/// Implementa el patrón Singleton para acceso global.
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;
  static const String _databaseName = 'fitcontrol.db';
  static const int _databaseVersion = 1;

  /// Obtiene la instancia de la base de datos, inicializándola si es necesario
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Inicializa la base de datos y crea las tablas
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Crea las tablas iniciales
  Future<void> _onCreate(Database db, int version) async {
    // Tabla de comidas (meals)
    await db.execute('''
      CREATE TABLE meals (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        meal_type TEXT NOT NULL,
        date TEXT NOT NULL,
        total_calories REAL NOT NULL,
        total_protein REAL NOT NULL,
        total_carbs REAL NOT NULL,
        total_fat REAL NOT NULL,
        total_fiber REAL NOT NULL,
        notes TEXT,
        image_url TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Tabla de alimentos individuales (food_items)
    await db.execute('''
      CREATE TABLE food_items (
        id TEXT PRIMARY KEY,
        meal_id TEXT NOT NULL,
        name TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit TEXT NOT NULL,
        calories REAL NOT NULL,
        protein REAL NOT NULL,
        carbs REAL NOT NULL,
        fat REAL NOT NULL,
        fiber REAL NOT NULL,
        sugar REAL,
        sodium REAL,
        category TEXT,
        FOREIGN KEY (meal_id) REFERENCES meals(id) ON DELETE CASCADE
      )
    ''');

    // Índices para consultas eficientes
    await db.execute('''
      CREATE INDEX idx_meals_user_date ON meals(user_id, date)
    ''');
    
    await db.execute('''
      CREATE INDEX idx_food_items_meal ON food_items(meal_id)
    ''');
  }

  /// Maneja migraciones de la base de datos
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Aquí se agregarán migraciones futuras
    if (oldVersion < 2) {
      // Ejemplo: await db.execute('ALTER TABLE meals ADD COLUMN new_column TEXT');
    }
  }

  /// Guarda una comida en la base de datos (insert o update)
  Future<void> saveMeal(Meal meal) async {
    final db = await database;
    
    await db.transaction((txn) async {
      // Insertar o actualizar la comida
      await txn.insert(
        'meals',
        _mealToMap(meal),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Eliminar alimentos antiguos si es un update
      await txn.delete(
        'food_items',
        where: 'meal_id = ?',
        whereArgs: [meal.id],
      );

      // Insertar los alimentos nuevos
      for (final food in meal.foods) {
        await txn.insert(
          'food_items',
          _foodItemToMap(food, meal.id),
        );
      }
    });
  }

  /// Obtiene una comida por su ID
  Future<Meal?> getMeal(String mealId) async {
    final db = await database;
    
    final mealMaps = await db.query(
      'meals',
      where: 'id = ?',
      whereArgs: [mealId],
    );

    if (mealMaps.isEmpty) return null;

    final foodMaps = await db.query(
      'food_items',
      where: 'meal_id = ?',
      whereArgs: [mealId],
    );

    return _mapToMeal(mealMaps.first, foodMaps);
  }

  /// Obtiene todas las comidas de un usuario
  Future<List<Meal>> getMealsByUser(String userId) async {
    final db = await database;
    
    final mealMaps = await db.query(
      'meals',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC, created_at DESC',
    );

    return await Future.wait(
      mealMaps.map((mealMap) async {
        final foodMaps = await db.query(
          'food_items',
          where: 'meal_id = ?',
          whereArgs: [mealMap['id']],
        );
        return _mapToMeal(mealMap, foodMaps);
      }),
    );
  }

  /// Obtiene las comidas de un usuario en una fecha específica
  Future<List<Meal>> getMealsByDate(String userId, DateTime date) async {
    final db = await database;
    final dateString = _dateToString(date);
    
    final mealMaps = await db.query(
      'meals',
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, dateString],
      orderBy: 'created_at DESC',
    );

    return await Future.wait(
      mealMaps.map((mealMap) async {
        final foodMaps = await db.query(
          'food_items',
          where: 'meal_id = ?',
          whereArgs: [mealMap['id']],
        );
        return _mapToMeal(mealMap, foodMaps);
      }),
    );
  }

  /// Obtiene las comidas recientes de un usuario
  Future<List<Meal>> getRecentMeals(String userId, {int limit = 10}) async {
    final db = await database;
    
    final mealMaps = await db.query(
      'meals',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
      limit: limit,
    );

    return await Future.wait(
      mealMaps.map((mealMap) async {
        final foodMaps = await db.query(
          'food_items',
          where: 'meal_id = ?',
          whereArgs: [mealMap['id']],
        );
        return _mapToMeal(mealMap, foodMaps);
      }),
    );
  }

  /// Elimina una comida por su ID
  Future<void> deleteMeal(String mealId) async {
    final db = await database;
    
    await db.delete(
      'meals',
      where: 'id = ?',
      whereArgs: [mealId],
    );
    // Los food_items se eliminan automáticamente por CASCADE
  }

  /// Obtiene el resumen nutricional diario de un usuario
  Future<DailyNutritionSummary> getDailySummary(String userId, DateTime date) async {
    final db = await database;
    final dateString = _dateToString(date);
    
    final result = await db.rawQuery('''
      SELECT 
        SUM(total_calories) as total_calories,
        SUM(total_protein) as total_protein,
        SUM(total_carbs) as total_carbs,
        SUM(total_fat) as total_fat,
        SUM(total_fiber) as total_fiber,
        COUNT(*) as meal_count
      FROM meals
      WHERE user_id = ? AND date = ?
    ''', [userId, dateString]);

    final row = result.first;
    return DailyNutritionSummary(
      totalCalories: (row['total_calories'] as num?)?.toDouble() ?? 0,
      totalProtein: (row['total_protein'] as num?)?.toDouble() ?? 0,
      totalCarbs: (row['total_carbs'] as num?)?.toDouble() ?? 0,
      totalFat: (row['total_fat'] as num?)?.toDouble() ?? 0,
      totalFiber: (row['total_fiber'] as num?)?.toDouble() ?? 0,
      mealCount: (row['meal_count'] as num?)?.toInt() ?? 0,
    );
  }

  /// Obtiene estadísticas nutricionales de un rango de fechas
  Future<List<DailyNutritionSummary>> getNutritionHistory(
    String userId, 
    DateTime startDate, 
    DateTime endDate,
  ) async {
    final db = await database;
    final startString = _dateToString(startDate);
    final endString = _dateToString(endDate);
    
    final result = await db.rawQuery('''
      SELECT 
        date,
        SUM(total_calories) as total_calories,
        SUM(total_protein) as total_protein,
        SUM(total_carbs) as total_carbs,
        SUM(total_fat) as total_fat,
        SUM(total_fiber) as total_fiber,
        COUNT(*) as meal_count
      FROM meals
      WHERE user_id = ? AND date BETWEEN ? AND ?
      GROUP BY date
      ORDER BY date DESC
    ''', [userId, startString, endString]);

    return result.map((row) => DailyNutritionSummary(
      date: _stringToDate(row['date'] as String),
      totalCalories: (row['total_calories'] as num).toDouble(),
      totalProtein: (row['total_protein'] as num).toDouble(),
      totalCarbs: (row['total_carbs'] as num).toDouble(),
      totalFat: (row['total_fat'] as num).toDouble(),
      totalFiber: (row['total_fiber'] as num).toDouble(),
      mealCount: (row['meal_count'] as num).toInt(),
    )).toList();
  }

  /// Cierra la conexión con la base de datos
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Elimina todos los datos (útil para testing)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('food_items');
    await db.delete('meals');
  }

  // Métodos auxiliares de conversión

  Map<String, dynamic> _mealToMap(Meal meal) {
    return {
      'id': meal.id,
      'user_id': meal.userId,
      'name': meal.name,
      'meal_type': meal.mealType,
      'date': _dateToString(meal.date),
      'total_calories': meal.totalCalories,
      'total_protein': meal.totalProtein,
      'total_carbs': meal.totalCarbs,
      'total_fat': meal.totalFat,
      'total_fiber': meal.totalFiber,
      'notes': meal.notes,
      'image_url': meal.imageUrl,
      'created_at': meal.createdAt.toIso8601String(),
      'updated_at': meal.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _foodItemToMap(FoodItem food, String mealId) {
    return {
      'id': food.id,
      'meal_id': mealId,
      'name': food.name,
      'quantity': food.quantity,
      'unit': food.unit,
      'calories': food.calories,
      'protein': food.protein,
      'carbs': food.carbs,
      'fat': food.fat,
      'fiber': food.fiber,
      'sugar': food.sugar,
      'sodium': food.sodium,
      'category': food.category,
    };
  }

  Meal _mapToMeal(Map<String, dynamic> mealMap, List<Map<String, dynamic>> foodMaps) {
    final foods = foodMaps.map((foodMap) => FoodItem(
      id: foodMap['id'] as String,
      name: foodMap['name'] as String,
      quantity: (foodMap['quantity'] as num).toDouble(),
      unit: foodMap['unit'] as String,
      calories: (foodMap['calories'] as num).toDouble(),
      protein: (foodMap['protein'] as num).toDouble(),
      carbs: (foodMap['carbs'] as num).toDouble(),
      fat: (foodMap['fat'] as num).toDouble(),
      fiber: (foodMap['fiber'] as num).toDouble(),
      sugar: foodMap['sugar'] != null ? (foodMap['sugar'] as num).toDouble() : null,
      sodium: foodMap['sodium'] != null ? (foodMap['sodium'] as num).toDouble() : null,
      category: foodMap['category'] as String?,
    )).toList();

    return Meal(
      id: mealMap['id'] as String,
      userId: mealMap['user_id'] as String,
      name: mealMap['name'] as String,
      mealType: mealMap['meal_type'] as String,
      date: _stringToDate(mealMap['date'] as String),
      foods: foods,
      totalCalories: (mealMap['total_calories'] as num).toDouble(),
      totalProtein: (mealMap['total_protein'] as num).toDouble(),
      totalCarbs: (mealMap['total_carbs'] as num).toDouble(),
      totalFat: (mealMap['total_fat'] as num).toDouble(),
      totalFiber: (mealMap['total_fiber'] as num).toDouble(),
      notes: mealMap['notes'] as String?,
      imageUrl: mealMap['image_url'] as String?,
      createdAt: DateTime.parse(mealMap['created_at'] as String),
      updatedAt: DateTime.parse(mealMap['updated_at'] as String),
    );
  }

  String _dateToString(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  DateTime _stringToDate(String dateString) {
    final parts = dateString.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }
}

/// Clase para representar el resumen nutricional diario
class DailyNutritionSummary {
  final DateTime? date;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double totalFiber;
  final int mealCount;

  DailyNutritionSummary({
    this.date,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.totalFiber,
    required this.mealCount,
  });

  @override
  String toString() {
    return 'DailyNutritionSummary(date: $date, calories: $totalCalories, meals: $mealCount)';
  }
}
