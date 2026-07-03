class ForecastDay {
  final DateTime date;
  final double tempMin;
  final double tempMax;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;

  const ForecastDay({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>;
    final weather = (json['weather'] as List).first as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>? ?? {};

    return ForecastDay(
      date: DateTime.fromMillisecondsSinceEpoch(
        (json['dt'] as int) * 1000,
      ),
      tempMin: (main['temp_min'] as num).toDouble(),
      tempMax: (main['temp_max'] as num).toDouble(),
      description: weather['description'] as String,
      icon: weather['icon'] as String,
      humidity: main['humidity'] as int,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0,
    );
  }
}

class ForecastData {
  final List<ForecastDay> days;

  const ForecastData({required this.days});

  factory ForecastData.fromJson(Map<String, dynamic> json) {
    final list = json['list'] as List;
    final dailyMap = <String, ForecastDay>{};

    for (final item in list) {
      final day = ForecastDay.fromJson(item as Map<String, dynamic>);
      final key =
          '${day.date.year}-${day.date.month}-${day.date.day}';
      dailyMap.putIfAbsent(key, () => day);
    }

    return ForecastData(days: dailyMap.values.take(5).toList());
  }

  Map<String, dynamic> toJson() => {
        'list': days
            .map(
              (d) => {
                'dt': d.date.millisecondsSinceEpoch ~/ 1000,
                'main': {
                  'temp_min': d.tempMin,
                  'temp_max': d.tempMax,
                  'humidity': d.humidity,
                },
                'weather': [
                  {'description': d.description, 'icon': d.icon}
                ],
                'wind': {'speed': d.windSpeed},
              },
            )
            .toList(),
      };
}
