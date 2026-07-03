import 'package:get/get.dart';

import '../data/models/city_location.dart';
import '../data/repositories/weather_repository.dart';

class CitySearchController extends GetxController {
  CitySearchController({WeatherRepository? repository})
      : _repository = repository ?? WeatherRepository();

  final WeatherRepository _repository;

  final RxList<CityLocation> results = <CityLocation>[].obs;
  final RxList<CityLocation> recentSearches = <CityLocation>[].obs;
  final RxBool isSearching = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString query = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadRecentSearches();
  }

  Future<void> loadRecentSearches() async {
    recentSearches.value = await _repository.getSearchHistory();
  }

  Future<void> search(String queryText) async {
    query.value = queryText;
    if (queryText.trim().length < 2) {
      results.clear();
      return;
    }

    isSearching.value = true;
    errorMessage.value = '';

    try {
      results.value = await _repository.searchCities(queryText);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      results.clear();
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> selectCity(CityLocation city, String query) async {
    await _repository.saveSearchHistory(query, city);
    await loadRecentSearches();
    Get.back(result: city);
  }
}
