import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/search_controller.dart';
import '../../data/models/city_location.dart';

class SearchScreen extends GetView<CitySearchController> {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search City'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search city...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: controller.search,
            ),
          ),
          Obx(() {
            if (controller.isSearching.value) {
              return const Expanded(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (controller.errorMessage.isNotEmpty) {
              return Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      controller.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                  ),
                ),
              );
            }

            if (controller.results.isEmpty) {
              return Expanded(child: _RecentSearches(controller: controller));
            }

            return Expanded(
              child: ListView.builder(
                itemCount: controller.results.length,
                itemBuilder: (context, index) {
                  final city = controller.results[index];
                  return _CityTile(
                    city: city,
                    onTap: () => controller.selectCity(
                      city,
                      controller.query.value,
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _RecentSearches extends StatelessWidget {
  const _RecentSearches({required this.controller});

  final CitySearchController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.recentSearches.isEmpty) {
      return Center(
        child: Text(
          'Type a city name to search',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white54,
              ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Recent searches',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white54,
                ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: controller.recentSearches.length,
            itemBuilder: (context, index) {
              final city = controller.recentSearches[index];
              return _CityTile(
                city: city,
                onTap: () => Get.back(result: city),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CityTile extends StatelessWidget {
  const _CityTile({required this.city, required this.onTap});

  final CityLocation city;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        child: Icon(Icons.location_city, size: 20),
      ),
      title: Text(city.name),
      subtitle: Text(city.displayName),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
