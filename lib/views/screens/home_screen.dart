import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../controllers/weather_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/weather_utils.dart';
import '../widgets/forecast_list.dart';
import '../widgets/loading_error_views.dart';
import '../widgets/weather_details_grid.dart';
import '../widgets/weather_header.dart';

class HomeScreen extends GetView<WeatherController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Weather'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: 'Use my location',
            onPressed: controller.loadWeatherFromGps,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search city',
            onPressed: _openSearch,
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            tooltip: 'Favorites',
            onPressed: _openFavorites,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.weather.value == null) {
          return Container(
            decoration: BoxDecoration(
              gradient: AppTheme.backgroundGradient(true),
            ),
            child: const LoadingView(message: 'Fetching weather...'),
          );
        }

        if (controller.errorMessage.isNotEmpty &&
            controller.weather.value == null) {
          return Container(
            decoration: BoxDecoration(
              gradient: AppTheme.backgroundGradient(true),
            ),
            child: ErrorView(
              message: controller.errorMessage.value,
              onRetry: controller.loadInitialWeather,
            ),
          );
        }

        final weather = controller.weather.value;
        if (weather == null) {
          return const SizedBox.shrink();
        }

        final isDay = WeatherUtils.isDayTime(
          weather.sunrise,
          weather.sunset,
          weather.dt,
        );
        final cityName =
            controller.currentCity.value?.displayName ?? weather.cityName;

        return Container(
          decoration: BoxDecoration(
            gradient: AppTheme.backgroundGradient(isDay),
          ),
          child: SafeArea(
            child: Column(
              children: [
                if (controller.isFromCache.value) const OfflineBanner(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: controller.refreshWeather,
                    color: Colors.white,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      child: Column(
                        children: [
                          WeatherHeader(
                            weather: weather,
                            cityName: cityName,
                            isDay: isDay,
                          ),
                          const SizedBox(height: 24),
                          WeatherDetailsGrid(weather: weather),
                          if (controller.forecast.value != null) ...[
                            const SizedBox(height: 24),
                            ForecastList(
                              forecast: controller.forecast.value!,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: Obx(() {
        if (controller.weather.value == null) return const SizedBox.shrink();
        return FloatingActionButton(
          onPressed: controller.toggleFavorite,
          tooltip: controller.isFavorite.value
              ? 'Remove from favorites'
              : 'Add to favorites',
          child: Icon(
            controller.isFavorite.value
                ? Icons.favorite
                : Icons.favorite_border,
          ),
        );
      }),
    );
  }

  Future<void> _openSearch() async {
    final city = await Get.toNamed(AppRoutes.search);
    if (city != null) {
      await controller.loadWeatherForCity(city, forceRefresh: true);
    }
  }

  Future<void> _openFavorites() async {
    final city = await Get.toNamed(AppRoutes.favorites);
    if (city != null) {
      await controller.loadWeatherForCity(city);
    }
  }
}
