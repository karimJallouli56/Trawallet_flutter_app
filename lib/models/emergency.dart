class Emergency {
  final String countryCode;
  final String countryName;
  final List<String> police;
  final List<String> ambulance;
  final List<String> fireBrigade;
  final List<String> dispatch;
  final bool member112;

  Emergency({
    required this.countryCode,
    required this.countryName,
    required this.police,
    required this.ambulance,
    required this.fireBrigade,
    required this.dispatch,
    this.member112 = false,
  });

  factory Emergency.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    return Emergency(
      countryCode: data['country']['ISOCode'] ?? '',
      countryName: data['country']['name'] ?? '',
      police: _extractNumbers(data['police']),
      ambulance: _extractNumbers(data['ambulance']),
      fireBrigade: _extractNumbers(data['fire']),
      dispatch: _extractNumbers(data['dispatch']),
      member112: data['member_112'] ?? false,
    );
  }

  static List<String> _extractNumbers(Map<String, dynamic>? service) {
    if (service == null) return [];

    List<String> numbers = [];

    // Get 'all' numbers (work on all networks)
    if (service['all'] != null && service['all'] is List) {
      for (var num in service['all']) {
        if (num != null && num.toString().isNotEmpty) {
          numbers.add(num.toString());
        }
      }
    }

    // Get GSM (mobile) specific numbers if no 'all' numbers
    if (numbers.isEmpty && service['gsm'] != null && service['gsm'] is List) {
      for (var num in service['gsm']) {
        if (num != null && num.toString().isNotEmpty) {
          numbers.add(num.toString());
        }
      }
    }

    return numbers;
  }

  String get primaryPolice => police.isNotEmpty
      ? police.first
      : (dispatch.isNotEmpty ? dispatch.first : '112');
  String get primaryAmbulance => ambulance.isNotEmpty
      ? ambulance.first
      : (dispatch.isNotEmpty ? dispatch.first : '112');
  String get primaryFire => fireBrigade.isNotEmpty
      ? fireBrigade.first
      : (dispatch.isNotEmpty ? dispatch.first : '112');
  String get primaryDispatch => dispatch.isNotEmpty ? dispatch.first : '112';
}

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
