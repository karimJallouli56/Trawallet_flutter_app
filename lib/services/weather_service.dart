import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/weather.dart';

class WeatherService {
  final String _baseUrl = "https://api.openweathermap.org/data/2.5";
  final String _apiKey = "aea7259fde88fee8cf6d086989b01445";

  Future<Weather?> fetchWeather(String city) async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/weather?q=$city&appid=$_apiKey&units=metric"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Weather.fromJson(data);
      } else {
        throw Exception("Error loading weather data");
      }
    } catch (e) {
      debugPrint("Error fetchWeather: $e");
      return null;
    }
  }

  Future<Weather?> fetchWeatherByCoordinates(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse(
          "$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric",
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Weather.fromJson(data);
      } else {
        throw Exception("Error loading weather data");
      }
    } catch (e) {
      debugPrint("Error fetchWeatherByCoordinates: $e");
      return null;
    }
  }
}
