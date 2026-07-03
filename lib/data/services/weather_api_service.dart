import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../models/city_location.dart';
import '../models/forecast_data.dart';
import '../models/weather_data.dart';

class WeatherApiException implements Exception {
  final String message;
  final int? statusCode;

  WeatherApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class WeatherApiService {
  String get _apiKey => dotenv.env['OPENWEATHER_API_KEY'] ?? '';

  bool get hasApiKey =>
      _apiKey.isNotEmpty && _apiKey != 'your_api_key_here';

  Map<String, String> get _baseParams => {
        'appid': _apiKey,
        'units': ApiConstants.units,
      };

  void _ensureApiKey() {
    if (!hasApiKey) {
      throw WeatherApiException(
        'OpenWeatherMap API key is missing. Add it to your .env file.',
      );
    }
  }

  Future<WeatherData> getCurrentWeather({
    required double lat,
    required double lon,
  }) async {
    _ensureApiKey();
    final uri = Uri.parse('${ApiConstants.baseUrl}/weather').replace(
      queryParameters: {
        ..._baseParams,
        'lat': lat.toString(),
        'lon': lon.toString(),
      },
    );

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return WeatherData.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw _parseError(response);
  }

  Future<ForecastData> getForecast({
    required double lat,
    required double lon,
  }) async {
    _ensureApiKey();
    final uri = Uri.parse('${ApiConstants.baseUrl}/forecast').replace(
      queryParameters: {
        ..._baseParams,
        'lat': lat.toString(),
        'lon': lon.toString(),
      },
    );

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return ForecastData.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw _parseError(response);
  }

  Future<List<CityLocation>> searchCities(String query) async {
    _ensureApiKey();
    if (query.trim().length < 2) return [];

    final uri = Uri.parse('${ApiConstants.geoUrl}/direct').replace(
      queryParameters: {
        'q': query.trim(),
        'limit': '8',
        'appid': _apiKey,
      },
    );

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List;
      return list
          .map((e) => CityLocation.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw _parseError(response);
  }

  WeatherApiException _parseError(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final message = body['message'] as String? ?? 'Request failed';
      return WeatherApiException(message, statusCode: response.statusCode);
    } catch (_) {
      return WeatherApiException(
        'Request failed (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }
  }
}
