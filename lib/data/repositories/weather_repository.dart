import '../../core/utils/weather_utils.dart';
import '../database/database_helper.dart';
import '../models/city_location.dart';
import '../models/forecast_data.dart';
import '../models/weather_data.dart';
import '../services/weather_api_service.dart';

class WeatherBundle {
  final WeatherData weather;
  final ForecastData? forecast;
  final bool fromCache;

  const WeatherBundle({
    required this.weather,
    this.forecast,
    this.fromCache = false,
  });
}

class WeatherRepository {
  WeatherRepository({
    WeatherApiService? apiService,
    DatabaseHelper? databaseHelper,
  })  : _api = apiService ?? WeatherApiService(),
        _db = databaseHelper ?? DatabaseHelper.instance;

  final WeatherApiService _api;
  final DatabaseHelper _db;

  bool get hasApiKey => _api.hasApiKey;

  Future<WeatherBundle> getWeatherForLocation({
    required double lat,
    required double lon,
    bool forceRefresh = false,
  }) async {
    final locationKey = WeatherUtils.locationKey(lat, lon);

    if (!forceRefresh) {
      final cached = await _db.getCachedWeather(locationKey);
      if (cached != null) {
        return WeatherBundle(
          weather: WeatherData.fromJson(
            cached['weather'] as Map<String, dynamic>,
          ),
          forecast: cached['forecast'] != null
              ? ForecastData.fromJson(
                  cached['forecast'] as Map<String, dynamic>,
                )
              : null,
          fromCache: true,
        );
      }
    }

    try {
      final weather = await _api.getCurrentWeather(lat: lat, lon: lon);
      ForecastData? forecast;
      try {
        forecast = await _api.getForecast(lat: lat, lon: lon);
      } catch (_) {
        // Forecast is optional; current weather still useful.
      }

      await _db.cacheWeather(
        locationKey: locationKey,
        weatherJson: weather.toJson(),
        forecastJson: forecast?.toJson(),
      );

      return WeatherBundle(weather: weather, forecast: forecast);
    } on WeatherApiException {
      final cached = await _db.getCachedWeather(locationKey);
      if (cached != null) {
        return WeatherBundle(
          weather: WeatherData.fromJson(
            cached['weather'] as Map<String, dynamic>,
          ),
          forecast: cached['forecast'] != null
              ? ForecastData.fromJson(
                  cached['forecast'] as Map<String, dynamic>,
                )
              : null,
          fromCache: true,
        );
      }
      rethrow;
    }
  }

  Future<List<CityLocation>> searchCities(String query) {
    return _api.searchCities(query);
  }

  Future<List<CityLocation>> getFavorites() async {
    final rows = await _db.getFavorites();
    return rows.map(CityLocation.fromMap).toList();
  }

  Future<CityLocation?> getDefaultFavorite() async {
    final row = await _db.getDefaultFavorite();
    return row != null ? CityLocation.fromMap(row) : null;
  }

  Future<void> addFavorite(CityLocation city) async {
    final exists = await _db.isFavorite(city.lat, city.lon);
    if (exists) return;

    final favorites = await _db.getFavorites();
    await _db.insertFavorite(
      city.toFavoriteMap(isDefault: favorites.isEmpty),
    );
  }

  Future<void> removeFavorite(CityLocation city) async {
    final id = await _db.getFavoriteId(city.lat, city.lon);
    if (id != null) await _db.removeFavorite(id);
  }

  Future<bool> isFavorite(CityLocation city) {
    return _db.isFavorite(city.lat, city.lon);
  }

  Future<void> setDefaultFavorite(CityLocation city) async {
    final id = await _db.getFavoriteId(city.lat, city.lon);
    if (id != null) await _db.setDefaultFavorite(id);
  }

  Future<void> saveSearchHistory(String query, CityLocation city) {
    return _db.addSearchHistory(
      query: query,
      cityData: city.toFavoriteMap(),
    );
  }

  Future<List<CityLocation>> getSearchHistory() async {
    final rows = await _db.getSearchHistory();
    return rows.map(CityLocation.fromMap).toList();
  }
}
