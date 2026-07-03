class CityLocation {
  final String name;
  final String country;
  final double lat;
  final double lon;
  final String? state;

  const CityLocation({
    required this.name,
    required this.country,
    required this.lat,
    required this.lon,
    this.state,
  });

  String get displayName {
    if (state != null && state!.isNotEmpty) {
      return '$name, $state, $country';
    }
    return '$name, $country';
  }

  String get shortName => '$name, $country';

  factory CityLocation.fromJson(Map<String, dynamic> json) {
    return CityLocation(
      name: json['name'] as String,
      country: json['country'] as String? ?? '',
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      state: json['state'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'country': country,
        'lat': lat,
        'lon': lon,
        'state': state,
      };

  factory CityLocation.fromMap(Map<String, dynamic> map) {
    return CityLocation(
      name: map['city_name'] as String,
      country: map['country'] as String? ?? '',
      lat: (map['lat'] as num).toDouble(),
      lon: (map['lon'] as num).toDouble(),
      state: map['state'] as String?,
    );
  }

  Map<String, dynamic> toFavoriteMap({bool isDefault = false}) => {
        'city_name': name,
        'country': country,
        'lat': lat,
        'lon': lon,
        'state': state,
        'is_default': isDefault ? 1 : 0,
      };
}
