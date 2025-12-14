import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:trawallet_final_version/models/weather.dart';
import 'package:trawallet_final_version/services/weather_service.dart';
import 'package:trawallet_final_version/views/weather/weatherDetail.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Future<Weather?>? weatherRequest;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoadingLocation = false;
  String? _currentCity;

  @override
  void initState() {
    super.initState();
    _loadLocationAndWeather();
  }

  Future<void> _loadLocationAndWeather() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final city = await _getCurrentCity();

      setState(() {
        _currentCity = city;
        _searchQuery = city ?? '';
        _isLoadingLocation = false;
        _searchController.clear();
        weatherRequest = WeatherService().fetchWeather(_searchQuery);
      });
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
        _searchQuery = '';
        weatherRequest = WeatherService().fetchWeather(_searchQuery);
      });
      _showMessage('Could not get your location. Showing default city.');
    }
  }

  Future<String?> _getCurrentCity() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showMessage('Location services are disabled');
        return null;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showMessage('Location permissions denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showMessage('Location permissions are permanently denied');
        return null;
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final cityName =
            place.locality ??
            place.subAdministrativeArea ??
            place.administrativeArea ??
            'Unknown';
        return cityName;
      }
    } catch (e) {
      print('Error getting location: $e');
    }
    return null;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.teal.shade700,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void searchWeather(String query) {
    if (query.isEmpty) return;

    setState(() {
      _searchQuery = query;
      weatherRequest = WeatherService().fetchWeather(query);
    });
  }

  void clearSearch() {
    _searchController.clear();
    _loadLocationAndWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Weather Alert System',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[50],
        foregroundColor: Colors.teal,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.6),
                    blurRadius: 2,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: _isLoadingLocation
                      ? 'Detecting location...'
                      : 'Search destination...',
                  hintStyle: TextStyle(color: Colors.teal),
                  prefixIcon: _isLoadingLocation
                      ? Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.teal,
                            ),
                          ),
                        )
                      : Icon(Icons.search, color: Colors.teal, size: 26),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.teal.shade700),
                          onPressed: clearSearch,
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Colors.teal,
                      width: 1.5,
                    ),
                  ),
                ),
                style: const TextStyle(color: Colors.black),
                cursorColor: Colors.teal,
                onSubmitted: searchWeather,
                onChanged: (_) => setState(() {}),
                enabled: !_isLoadingLocation,
              ),
            ),
          ),

          Expanded(
            child: weatherRequest == null
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.teal),
                  )
                : RefreshIndicator(
                    onRefresh: _loadLocationAndWeather,
                    color: Colors.teal,
                    backgroundColor: Colors.white,
                    child: FutureBuilder<Weather?>(
                      future: weatherRequest,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.teal,
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 64,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  "Error loading weather",
                                  style: TextStyle(
                                    color: Colors.grey.shade800,
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    "${snapshot.error}",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: _loadLocationAndWeather,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                  ),
                                  child: const Text('Try Again'),
                                ),
                              ],
                            ),
                          );
                        }

                        final weather = snapshot.data;

                        if (weather == null) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cloud_off,
                                  color: Colors.teal,
                                  size: 80,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No weather data',
                                  style: TextStyle(
                                    color: Colors.grey.shade800,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try another city name',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          );
                        }
                        final isSuccess = weather.isWeatherNormal;
                        return ListView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 0,
                          ),
                          children: [
                            // Alert Card
                            Card(
                              color: weather.alertColor,
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSuccess
                                          ? Icons.check_circle_outline
                                          : Icons.warning_amber_rounded,
                                      size: 32,
                                      color: Colors.grey.shade800,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        weather.alertMessage,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Main Weather Card
                            Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.teal.shade400,
                                      Colors.teal.shade600,
                                      Colors.teal.shade800,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.teal.shade900.withOpacity(
                                        0.3,
                                      ),
                                      blurRadius: 25,
                                      spreadRadius: 3,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        weather.cityName,
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        weather.weatherIcon,
                                        style: const TextStyle(fontSize: 80),
                                      ),
                                      Text(
                                        '${weather.temperature.round()}°C',
                                        style: const TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        weather.description.toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.white70,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          WeatherDetail(
                                            icon: Icons.thermostat,
                                            label: 'Feels Like',
                                            value:
                                                '${weather.feelsLike.round()}°C',
                                          ),
                                          WeatherDetail(
                                            icon: Icons.water_drop,
                                            label: 'Humidity',
                                            value: '${weather.humidity}%',
                                          ),
                                          WeatherDetail(
                                            icon: Icons.air,
                                            label: 'Wind',
                                            value: '${weather.windSpeed} m/s',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Travel Tips Card
                            Card(
                              elevation: 4,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(
                                          Icons.tips_and_updates,
                                          color: Colors.teal,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Travel Tips',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.teal,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    ...weather.travelTips.map(
                                      (tip) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4.0,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '• ',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey.shade800,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                tip,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.grey.shade800,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
