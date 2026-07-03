import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _dbName = 'weather_app.db';
  static const _dbVersion = 1;

  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        city_name TEXT NOT NULL,
        country TEXT NOT NULL,
        lat REAL NOT NULL,
        lon REAL NOT NULL,
        state TEXT,
        is_default INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE weather_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        location_key TEXT NOT NULL UNIQUE,
        weather_json TEXT NOT NULL,
        forecast_json TEXT,
        updated_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE search_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        query TEXT NOT NULL,
        city_name TEXT NOT NULL,
        country TEXT NOT NULL,
        lat REAL NOT NULL,
        lon REAL NOT NULL,
        state TEXT,
        searched_at INTEGER NOT NULL
      )
    ''');
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final db = await database;
    return db.query('favorites', orderBy: 'created_at DESC');
  }

  Future<Map<String, dynamic>?> getDefaultFavorite() async {
    final db = await database;
    final results = await db.query(
      'favorites',
      where: 'is_default = ?',
      whereArgs: [1],
      limit: 1,
    );
    return results.isEmpty ? null : results.first;
  }

  Future<int> insertFavorite(Map<String, dynamic> data) async {
    final db = await database;
    data['created_at'] = DateTime.now().millisecondsSinceEpoch;
    return db.insert('favorites', data);
  }

  Future<void> removeFavorite(int id) async {
    final db = await database;
    await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> isFavorite(double lat, double lon) async {
    final db = await database;
    final results = await db.query(
      'favorites',
      where: 'lat = ? AND lon = ?',
      whereArgs: [lat, lon],
      limit: 1,
    );
    return results.isNotEmpty;
  }

  Future<int?> getFavoriteId(double lat, double lon) async {
    final db = await database;
    final results = await db.query(
      'favorites',
      where: 'lat = ? AND lon = ?',
      whereArgs: [lat, lon],
      limit: 1,
    );
    return results.isEmpty ? null : results.first['id'] as int;
  }

  Future<void> setDefaultFavorite(int id) async {
    final db = await database;
    await db.update('favorites', {'is_default': 0});
    await db.update(
      'favorites',
      {'is_default': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> cacheWeather({
    required String locationKey,
    required Map<String, dynamic> weatherJson,
    Map<String, dynamic>? forecastJson,
  }) async {
    final db = await database;
    await db.insert(
      'weather_cache',
      {
        'location_key': locationKey,
        'weather_json': jsonEncode(weatherJson),
        'forecast_json':
            forecastJson != null ? jsonEncode(forecastJson) : null,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getCachedWeather(String locationKey) async {
    final db = await database;
    final results = await db.query(
      'weather_cache',
      where: 'location_key = ?',
      whereArgs: [locationKey],
      limit: 1,
    );
    if (results.isEmpty) return null;

    final row = results.first;
    return {
      'weather': jsonDecode(row['weather_json'] as String),
      'forecast': row['forecast_json'] != null
          ? jsonDecode(row['forecast_json'] as String)
          : null,
      'updated_at': row['updated_at'],
    };
  }

  Future<void> addSearchHistory({
    required String query,
    required Map<String, dynamic> cityData,
  }) async {
    final db = await database;
    await db.insert('search_history', {
      'query': query,
      'city_name': cityData['city_name'],
      'country': cityData['country'],
      'lat': cityData['lat'],
      'lon': cityData['lon'],
      'state': cityData['state'],
      'searched_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<Map<String, dynamic>>> getSearchHistory({int limit = 10}) async {
    final db = await database;
    return db.query(
      'search_history',
      orderBy: 'searched_at DESC',
      limit: limit,
    );
  }

  Future<void> clearSearchHistory() async {
    final db = await database;
    await db.delete('search_history');
  }
}
