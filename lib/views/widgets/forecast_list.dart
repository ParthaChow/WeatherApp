import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_strings.dart';
import '../../core/utils/weather_utils.dart';
import '../../data/models/forecast_data.dart';

class ForecastList extends StatelessWidget {
  const ForecastList({super.key, required this.forecast});

  final ForecastData forecast;

  @override
  Widget build(BuildContext context) {
    if (forecast.days.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.forecast,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 12),
        ...forecast.days.map((day) => _ForecastTile(day: day)),
      ],
    );
  }
}

class _ForecastTile extends StatelessWidget {
  const _ForecastTile({required this.day});

  final ForecastDay day;

  @override
  Widget build(BuildContext context) {
    final dayFormat = DateFormat('EEE, MMM d');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                dayFormat.format(day.date),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),
            Image.network(
              WeatherUtils.weatherIconUrl(day.icon, size: 2),
              width: 40,
              height: 40,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.cloud, color: Colors.white70),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${day.tempMax.round()}° / ${day.tempMin.round()}°',
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
