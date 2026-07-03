import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/favorites_controller.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/city_location.dart';
import '../widgets/loading_error_views.dart';

class FavoritesScreen extends GetView<FavoritesController> {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.favorites),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingView();
        }

        if (controller.favorites.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bookmark_border, size: 64, color: Colors.white38),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.noFavorites,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.noFavoritesSubtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white54,
                        ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: controller.favorites.length,
          itemBuilder: (context, index) {
            final city = controller.favorites[index];
            return _FavoriteTile(city: city, controller: controller);
          },
        );
      }),
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  const _FavoriteTile({
    required this.city,
    required this.controller,
  });

  final CityLocation city;
  final FavoritesController controller;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('${city.lat}_${city.lon}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.shade700,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => controller.removeFavorite(city),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.location_on, size: 20),
        ),
        title: Text(city.name),
        subtitle: Text(city.displayName),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'default':
                controller.setDefault(city);
              case 'open':
                controller.openCity(city);
              case 'remove':
                controller.removeFavorite(city);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'open',
              child: Text('View weather'),
            ),
            const PopupMenuItem(
              value: 'default',
              child: Text('Set as default'),
            ),
            const PopupMenuItem(
              value: 'remove',
              child: Text('Remove'),
            ),
          ],
        ),
        onTap: () => controller.openCity(city),
      ),
    );
  }
}
