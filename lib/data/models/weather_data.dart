class WeatherData {
  final String description;
  final String icon;
  final double temp;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final double windDeg;
  final int pressure;
  final int visibility;
  final int sunrise;
  final int sunset;
  final int dt;
  final String cityName;
  final String country;

  const WeatherData({
    required this.description,
    required this.icon,
    required this.temp,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.windDeg,
    required this.pressure,
    required this.visibility,
    required this.sunrise,
    required this.sunset,
    required this.dt,
    required this.cityName,
    required this.country,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final weather = (json['weather'] as List).first as Map<String, dynamic>;
    final main = json['main'] as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>? ?? {};
    final sys = json['sys'] as Map<String, dynamic>? ?? {};

    return WeatherData(
      description: weather['description'] as String,
      icon: weather['icon'] as String,
      temp: (main['temp'] as num).toDouble(),
      feelsLike: (main['feels_like'] as num).toDouble(),
      humidity: main['humidity'] as int,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0,
      windDeg: (wind['deg'] as num?)?.toDouble() ?? 0,
      pressure: main['pressure'] as int,
      visibility: json['visibility'] as int? ?? 10000,
      sunrise: sys['sunrise'] as int? ?? 0,
      sunset: sys['sunset'] as int? ?? 0,
      dt: json['dt'] as int,
      cityName: json['name'] as String? ?? '',
      country: sys['country'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'weather': [
          {'description': description, 'icon': icon}
        ],
        'main': {
          'temp': temp,
          'feels_like': feelsLike,
          'humidity': humidity,
          'pressure': pressure,
        },
        'wind': {'speed': windSpeed, 'deg': windDeg},
        'visibility': visibility,
        'sys': {
          'sunrise': sunrise,
          'sunset': sunset,
          'country': country,
        },
        'dt': dt,
        'name': cityName,
      };
}
