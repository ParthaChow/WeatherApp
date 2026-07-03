import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/utils/weather_utils.dart';
import '../../data/models/weather_data.dart';

class WeatherDetailsGrid extends StatelessWidget {
  const WeatherDetailsGrid({super.key, required this.weather});

  final WeatherData weather;

  @override
  Widget build(BuildContext context) {
    final items = [
      _DetailItem(
        icon: Icons.water_drop_outlined,
        label: AppStrings.humidity,
        value: '${weather.humidity}%',
      ),
      _DetailItem(
        icon: Icons.air,
        label: AppStrings.wind,
        value:
            '${weather.windSpeed.toStringAsFixed(1)} m/s ${WeatherUtils.windDirection(weather.windDeg)}',
      ),
      _DetailItem(
        icon: Icons.speed,
        label: AppStrings.pressure,
        value: '${weather.pressure} hPa',
      ),
      _DetailItem(
        icon: Icons.visibility_outlined,
        label: AppStrings.visibility,
        value: '${(weather.visibility / 1000).toStringAsFixed(1)} km',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, color: Colors.white70, size: 22),
                const Spacer(),
                Text(
                  item.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white54,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.value,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DetailItem {
  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}
