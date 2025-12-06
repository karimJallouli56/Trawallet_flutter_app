import 'dart:ui';

class Weather {
  final String cityName;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String condition;
  final String description;
  final String icon;
  final int pressure;
  Weather({
    required this.cityName,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.condition,
    required this.description,
    required this.icon,
    required this.pressure,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'] ?? '',
      temperature: (json['main']['temp'] ?? 0).toDouble(),
      feelsLike: (json['main']['feels_like'] ?? 0).toDouble(),
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] ?? 0).toDouble(),
      condition: json['weather'][0]['main'] ?? '',
      description: json['weather'][0]['description'] ?? '',
      icon: json['weather'][0]['icon'] ?? '',
      pressure: json['main']['pressure'] ?? 0,
    );
  }
  bool get isWeatherNormal {
    final c = condition.toLowerCase();
    if (c == 'thunderstorm' ||
        c == 'snow' ||
        c == 'rain' ||
        temperature > 35 ||
        temperature < 0 ||
        windSpeed > 10) {
      return false;
    }
    return true;
  }

  String get weatherIcon {
    switch (condition.toLowerCase()) {
      case 'clear':
        return '☀️';
      case 'clouds':
        return '☁️';
      case 'rain':
      case 'drizzle':
        return '🌧️';
      case 'thunderstorm':
        return '⛈️';
      case 'snow':
        return '❄️';
      case 'mist':
      case 'fog':
        return '🌫️';
      default:
        return '🌤️';
    }
  }

  String get alertMessage {
    if (condition == 'Thunderstorm') {
      return '⚠️ Severe Weather Alert: Thunderstorm detected. Stay indoors!';
    } else if (condition == 'Snow') {
      return '❄️ Winter Alert: Snow conditions. Drive carefully!';
    } else if (temperature > 35) {
      return '🌡️ Heat Alert: Extremely hot weather. Stay hydrated!';
    } else if (temperature < 0) {
      return '🥶 Cold Alert: Freezing temperature. Dress warmly!';
    } else if (windSpeed > 10) {
      return '💨 Wind Alert: Strong winds detected. Secure loose items!';
    } else if (condition == 'Rain') {
      return '☔ Rain Alert: Bring an umbrella!';
    }
    return 'Weather conditions are normal. Enjoy your day!';
  }

  Color get alertColor {
    if (condition == 'Thunderstorm' || temperature > 35 || temperature < 0) {
      return const Color(0xFFFFCDD2); // Red shade
    } else if (condition == 'Snow' || condition == 'Rain' || windSpeed > 10) {
      return const Color(0xFFFFE0B2); // Orange shade
    }
    return Color(0xFF80CBC4); // Green shade
  }

  List<String> get travelTips {
    List<String> tips = [];

    if (condition == 'Rain' || condition == 'Drizzle') {
      tips.add('Carry an umbrella or raincoat');
      tips.add('Allow extra travel time due to wet roads');
    } else if (condition == 'Thunderstorm') {
      tips.add('Avoid outdoor activities');
      tips.add('Stay away from tall objects and water');
    } else if (condition == 'Snow') {
      tips.add('Wear warm, waterproof clothing');
      tips.add('Drive slowly and maintain distance');
    } else if (temperature > 30) {
      tips.add('Wear light, breathable clothing');
      tips.add('Apply sunscreen and wear sunglasses');
      tips.add('Stay hydrated throughout the day');
    } else if (temperature < 10) {
      tips.add('Wear layers and warm clothing');
      tips.add('Protect extremities with gloves and hat');
    }

    if (humidity > 80) {
      tips.add('High humidity may cause discomfort');
    }

    if (tips.isEmpty) {
      tips.add('Perfect weather for outdoor activities!');
      tips.add('Enjoy your trip!');
    }

    return tips;
  }
}
