import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:trawallet_final_version/models/transport.dart';
import 'package:trawallet_final_version/services/transport_service.dart';
import 'package:trawallet_final_version/views/transport/transportInfo.dart';
import 'package:url_launcher/url_launcher.dart';

class TransportScreen extends StatefulWidget {
  TransportScreen({super.key});

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  late Future<List<Transport>> transportRequest;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  String _detectedType = '';

  @override
  void initState() {
    super.initState();
    transportRequest = Future.value([]);
  }

  void searchTransport(String query) {
    if (query.isEmpty) return;

    final type = TransportService().detectTransportType(query);

    setState(() {
      _isSearching = true;
      _searchQuery = query;
      _detectedType = type;
      transportRequest = TransportService().searchTransport(query);
    });
  }

  void clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _detectedType = '';
      _isSearching = false;
      transportRequest = Future.value([]);
    });
  }

  Future<void> openRoute(String location) async {
    final url = TransportService().getRouteUrl(location, null, null);
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open maps')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Flight & Transport Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[50],
        foregroundColor: Colors.teal,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.5),
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
                  hintText: 'Enter flight or train number...',
                  hintStyle: TextStyle(color: Colors.teal.shade700),
                  prefixIcon: Icon(Icons.search, color: Colors.teal, size: 26),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.teal.shade700),
                          onPressed: clearSearch,
                        )
                      : null,
                  contentPadding: EdgeInsets.symmetric(
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
                onSubmitted: searchTransport,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),

          if (_detectedType.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _detectedType == 'flight' ? Icons.flight : Icons.train,
                    color: Colors.teal.shade700,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Detected: ${_detectedType.toUpperCase()}',
                    style: TextStyle(
                      color: Colors.teal.shade700,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: FutureBuilder<List<Transport>>(
              future: transportRequest,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.teal.shade700,
                    ),
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
                          "Error loading data",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "${snapshot.error}",
                          style: TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              transportRequest = TransportService()
                                  .searchTransport(_searchQuery);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade700,
                          ),
                          child: Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }

                final transports = snapshot.data ?? [];

                if (!_isSearching || transports.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.flight_takeoff,
                          color: Colors.teal,
                          size: 80,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Track Your Journey',
                          style: TextStyle(
                            color: Colors.teal.shade500,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Enter flight or train number',
                          style: TextStyle(color: Colors.teal),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Examples: AA123, BA456, ICE789',
                          style: TextStyle(color: Colors.teal, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: transports.length,
                  itemBuilder: (context, index) {
                    final transport = transports[index];

                    return Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: Card(
                        elevation: 8,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
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
                                color: Colors.teal.shade700.withOpacity(0.35),
                                blurRadius: 18,
                                spreadRadius: 2,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          transport.typeIcon,
                                          color: Colors.teal.shade50,
                                          size: 40,
                                        ),
                                        SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              transport.number,
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              transport.airline,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white70.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.6),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            transport.status.toUpperCase(),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 24),
                                Text(
                                  transport.routeInfo,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TransportInfo(
                                        icon: Icons.flight_takeoff,
                                        label: 'Departure',
                                        airport: transport.departureAirport,
                                        time: transport.departureTime,
                                        terminal: transport.terminal,
                                        gate: transport.gate,
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: TransportInfo(
                                        icon: Icons.flight_land,
                                        label: 'Arrival',
                                        airport: transport.arrivalAirport,
                                        time: transport.arrivalTime,
                                      ),
                                    ),
                                  ],
                                ),
                                if (transport.isDelayed) ...[
                                  SizedBox(height: 16),
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade900.withOpacity(
                                        0.3,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.orange,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.warning_amber_rounded,
                                          color: Colors.orange,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Delayed by ${transport.delay} minutes',
                                          style: TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
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
