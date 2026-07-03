import 'package:get/get.dart';

import '../data/models/city_location.dart';
import '../data/repositories/weather_repository.dart';
import 'weather_controller.dart';

class FavoritesController extends GetxController {
  FavoritesController({WeatherRepository? repository})
      : _repository = repository ?? WeatherRepository();

  final WeatherRepository _repository;

  final RxList<CityLocation> favorites = <CityLocation>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    isLoading.value = true;
    favorites.value = await _repository.getFavorites();
    isLoading.value = false;
  }

  Future<void> removeFavorite(CityLocation city) async {
    await _repository.removeFavorite(city);
    await loadFavorites();
  }

  Future<void> setDefault(CityLocation city) async {
    await _repository.setDefaultFavorite(city);
    await loadFavorites();
    if (Get.isRegistered<WeatherController>()) {
      await Get.find<WeatherController>().loadWeatherForCity(city);
    }
  }

  void openCity(CityLocation city) {
    Get.back(result: city);
  }
}
