import 'package:get/get.dart';

import '../data/models/city_location.dart';
import '../data/models/forecast_data.dart';
import '../data/models/weather_data.dart';
import '../data/repositories/weather_repository.dart';
import '../data/services/location_service.dart';

class WeatherController extends GetxController {
  WeatherController({
    WeatherRepository? repository,
    LocationService? locationService,
  })  : _repository = repository ?? WeatherRepository(),
        _locationService = locationService ?? LocationService();

  final WeatherRepository _repository;
  final LocationService _locationService;

  final Rxn<WeatherData> weather = Rxn<WeatherData>();
  final Rxn<ForecastData> forecast = Rxn<ForecastData>();
  final Rxn<CityLocation> currentCity = Rxn<CityLocation>();
  final RxBool isLoading = false.obs;
  final RxBool isFavorite = false.obs;
  final RxBool isFromCache = false.obs;
  final RxString errorMessage = ''.obs;

  bool get hasApiKey => _repository.hasApiKey;

  @override
  void onInit() {
    super.onInit();
    loadInitialWeather();
  }

  Future<void> loadInitialWeather() async {
    if (!hasApiKey) {
      errorMessage.value =
          'Add your OpenWeatherMap API key to the .env file.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final defaultFavorite = await _repository.getDefaultFavorite();
      if (defaultFavorite != null) {
        await loadWeatherForCity(defaultFavorite);
        return;
      }

      await loadWeatherFromGps();
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadWeatherFromGps() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final position = await _locationService.getCurrentPosition();
      final city = CityLocation(
        name: 'Current Location',
        country: '',
        lat: position.latitude,
        lon: position.longitude,
      );
      await _fetchWeather(city, forceRefresh: true);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadWeatherForCity(
    CityLocation city, {
    bool forceRefresh = false,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _fetchWeather(city, forceRefresh: forceRefresh);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchWeather(
    CityLocation city, {
    bool forceRefresh = false,
  }) async {
    final bundle = await _repository.getWeatherForLocation(
      lat: city.lat,
      lon: city.lon,
      forceRefresh: forceRefresh,
    );

    currentCity.value = city.copyWithNameIfNeeded(bundle.weather);
    weather.value = bundle.weather;
    forecast.value = bundle.forecast;
    isFromCache.value = bundle.fromCache;
    isFavorite.value = await _repository.isFavorite(city);
  }

  Future<void> refreshWeather() async {
    final city = currentCity.value;
    if (city == null) {
      await loadInitialWeather();
      return;
    }
    await loadWeatherForCity(city, forceRefresh: true);
  }

  Future<void> toggleFavorite() async {
    final city = currentCity.value;
    if (city == null) return;

    if (isFavorite.value) {
      await _repository.removeFavorite(city);
      isFavorite.value = false;
    } else {
      await _repository.addFavorite(city);
      isFavorite.value = true;
    }
  }
}

extension on CityLocation {
  CityLocation copyWithNameIfNeeded(WeatherData weather) {
    if (name == 'Current Location' && weather.cityName.isNotEmpty) {
      return CityLocation(
        name: weather.cityName,
        country: weather.country,
        lat: lat,
        lon: lon,
        state: state,
      );
    }
    return this;
  }
}
