class WeatherUtils {
  static String weatherIconUrl(String iconCode, {int size = 4}) {
    return 'https://openweathermap.org/img/wn/$iconCode@${size}x.png';
  }

  static String locationKey(double lat, double lon) {
    return '${lat.toStringAsFixed(4)}_${lon.toStringAsFixed(4)}';
  }

  static bool isDayTime(int sunrise, int sunset, int current) {
    return current >= sunrise && current < sunset;
  }

  static String windDirection(double degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((degrees + 22.5) % 360 / 45).floor();
    return directions[index];
  }
}
