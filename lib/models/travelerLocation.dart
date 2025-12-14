class TravelerLocation {
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String country;
  final String countryCode;
  final DateTime timestamp;

  TravelerLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.country,
    required this.countryCode,
    required this.timestamp,
  });

  String get googleMapsUrl {
    return 'https://www.google.com/maps?q=$latitude,$longitude';
  }

  String get fullLocation {
    return '$address, $city, $country';
  }
}
