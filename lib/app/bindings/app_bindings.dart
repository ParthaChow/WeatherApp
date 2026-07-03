import 'package:get/get.dart';

import '../../controllers/favorites_controller.dart';
import '../../controllers/search_controller.dart';
import '../../controllers/weather_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WeatherController>(() => WeatherController());
  }
}

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CitySearchController>(() => CitySearchController());
  }
}

class FavoritesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FavoritesController>(() => FavoritesController());
  }
}
