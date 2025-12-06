import 'package:flutter/material.dart';
import 'package:trawallet_final_version/models/weather.dart';
import 'package:trawallet_final_version/services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Weather?> weatherRequest;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = 'London';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    weatherRequest = WeatherService().fetchWeather(_searchQuery);
  }

  void searchWeather(String query) {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchQuery = query;
      weatherRequest = WeatherService().fetchWeather(query);
    });
  }

  void clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = 'London';
      weatherRequest = WeatherService().fetchWeather(_searchQuery);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Weather Alert System',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
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
                  fillColor: Colors.teal.shade50,
                  hintText: 'Search destination...',
                  hintStyle: TextStyle(color: Colors.teal.shade700),
                  prefixIcon: Icon(Icons.search, color: Colors.teal, size: 26),
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
              ),
            ),
          ),
          // if (_isSearching)
          //   Padding(
          //     padding: const EdgeInsets.only(bottom: 8.0),
          //     child: Text(
          //       'Weather for $_searchQuery',
          //       style: const TextStyle(
          //         color: Colors.teal,
          //         fontSize: 16,
          //         fontWeight: FontWeight.w500,
          //       ),
          //     ),
          //   ),
          Expanded(
            child: FutureBuilder<Weather?>(
              future: weatherRequest,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.teal),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 64),
                        SizedBox(height: 16),
                        Text(
                          "Error loading weather",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "${snapshot.error}",
                          style: const TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              weatherRequest = WeatherService().fetchWeather(
                                _searchQuery,
                              );
                            });
                          },
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
                        Icon(Icons.cloud_off, color: Colors.teal, size: 80),
                        const SizedBox(height: 16),
                        const Text(
                          'No weather data',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Try another city name',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  );
                }
                final isSuccess = weather.isWeatherNormal;
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                color: Colors.teal.shade900.withOpacity(0.35),
                                blurRadius: 25,
                                spreadRadius: 3,
                                offset: const Offset(0, 10),
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
                                    _WeatherDetail(
                                      icon: Icons.thermostat,
                                      label: 'Feels Like',
                                      value: '${weather.feelsLike.round()}°C',
                                    ),
                                    _WeatherDetail(
                                      icon: Icons.water_drop,
                                      label: 'Humidity',
                                      value: '${weather.humidity}%',
                                    ),
                                    _WeatherDetail(
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
                  ),
                );
              },
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

class _WeatherDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _WeatherDetail({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.teal.shade100),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white54),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
