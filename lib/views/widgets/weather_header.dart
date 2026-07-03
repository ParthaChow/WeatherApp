import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_strings.dart';
import '../../core/utils/weather_utils.dart';
import '../../data/models/weather_data.dart';

class WeatherHeader extends StatelessWidget {
  const WeatherHeader({
    super.key,
    required this.weather,
    required this.cityName,
    required this.isDay,
  });

  final WeatherData weather;
  final String cityName;
  final bool isDay;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMM d');

    return Column(
      children: [
        Text(
          cityName,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          dateFormat.format(
            DateTime.fromMillisecondsSinceEpoch(weather.dt * 1000),
          ),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
        ),
        const SizedBox(height: 16),
        Image.network(
          WeatherUtils.weatherIconUrl(weather.icon, size: 4),
          width: 120,
          height: 120,
          errorBuilder: (_, __, ___) => Icon(
            isDay ? Icons.wb_sunny : Icons.nights_stay,
            size: 80,
            color: Colors.amber,
          ),
        ),
        Text(
          '${weather.temp.round()}°',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.w300,
                color: Colors.white,
                height: 1,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          weather.description[0].toUpperCase() +
              weather.description.substring(1),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white70,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          '${AppStrings.feelsLike} ${weather.feelsLike.round()}°',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white60,
              ),
        ),
      ],
    );
  }
}
