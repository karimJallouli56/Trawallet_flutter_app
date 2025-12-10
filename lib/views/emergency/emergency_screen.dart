import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trawallet_final_version/models/emergency.dart';
import 'package:trawallet_final_version/services/emergency_service.dart';

class EmergencyScreen extends StatefulWidget {
  EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final EmergencyService _sosService = EmergencyService();
  TravelerLocation? _currentLocation;
  Emergency? _emergencyServices;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLocationAndServices();
  }

  Future<void> _loadLocationAndServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final location = await _sosService.getTravelerLocation();

      if (location == null) {
        setState(() {
          _errorMessage = 'Could not get your location. Please enable GPS.';
          _isLoading = false;
        });
        return;
      }

      final services = await _sosService.fetchEmergencyNumbers(
        location.countryCode,
      );

      setState(() {
        _currentLocation = location;
        _emergencyServices = services;
        _isLoading = false;
      });

      if (services == null) {
        _showMessage('Could not load emergency numbers for this country');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.teal.shade700),
    );
  }

  Future<void> _callEmergencyService(String serviceName, String number) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade100,
        title: Row(
          children: [
            Icon(Icons.phone, color: Colors.red, size: 32),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Call $serviceName?',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are about to call:',
              style: TextStyle(color: Colors.grey.shade800),
            ),
            SizedBox(height: 8),
            Text(
              number,
              style: TextStyle(
                color: Colors.teal.shade700,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            if (_currentLocation != null) ...[
              Text(
                'Your location:',
                style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
              ),
              SizedBox(height: 4),
              Text(
                _currentLocation!.fullLocation,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              'CALL NOW',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _sosService.makeEmergencyCall(number);
        _showMessage('Calling $serviceName...');
      } catch (e) {
        _showMessage('Error: Could not make call');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Emergency SOS',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.teal,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadLocationAndServices,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: Colors.teal.shade700),
            )
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 64),
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _loadLocationAndServices,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade700,
                    ),
                    child: Text('Try Again'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Current Location Card
                  if (_currentLocation != null)
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Card(
                        elevation: 8,
                        color: Color(0xFF1E1E1E),
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
                                color: Colors.teal.shade900.withOpacity(0.35),
                                blurRadius: 25,
                                spreadRadius: 3,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.teal.shade50,
                                      size: 32,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Your Current Location',
                                            style: TextStyle(
                                              color: Colors.white54,
                                              fontSize: 14,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            _currentLocation!.city,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),

                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.white.withOpacity(
                                                0.4,
                                              ), // light shadow
                                              blurRadius: 6,
                                              spreadRadius: 1,
                                              offset: Offset(
                                                0,
                                                1,
                                              ), // subtle downward shadow
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),

                                          child: SvgPicture.network(
                                            _sosService.getCountryFlag(
                                              _currentLocation!.countryCode,
                                            ),
                                            width: 40,
                                            height: 30,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Text(
                                  _currentLocation!.country,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  _currentLocation!.address,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Emergency Alert
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade200.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red, width: 2),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red,
                            size: 32,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'For life-threatening emergencies only',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24),

                  // Local Emergency Services
                  if (_emergencyServices != null)
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Local Emergency Services',
                                    style: TextStyle(
                                      color: Colors.teal.shade700,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    _emergencyServices!.countryName,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              if (_emergencyServices!.member112)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade900.withOpacity(
                                      0.3,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.blue,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.blue,
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        '112 Available',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 20),

                          // Police
                          if (_emergencyServices!.primaryPolice.isNotEmpty)
                            _EmergencyServiceCard(
                              icon: Icons.local_police,
                              serviceName: 'Police',
                              number: _emergencyServices!.primaryPolice,
                              color: Colors.blue,
                              onTap: () => _callEmergencyService(
                                'Police',
                                _emergencyServices!.primaryPolice,
                              ),
                            ),

                          SizedBox(height: 12),

                          // Civil Protection / Dispatch
                          if (_emergencyServices!.primaryDispatch.isNotEmpty)
                            _EmergencyServiceCard(
                              icon: Icons.security,
                              serviceName: 'Civil Protection',
                              number: _emergencyServices!.primaryDispatch,
                              color: Colors.orange,
                              onTap: () => _callEmergencyService(
                                'Civil Protection',
                                _emergencyServices!.primaryDispatch,
                              ),
                            ),

                          SizedBox(height: 12),

                          // Ambulance
                          if (_emergencyServices!.primaryAmbulance.isNotEmpty)
                            _EmergencyServiceCard(
                              icon: Icons.local_hospital,
                              serviceName: 'Ambulance',
                              number: _emergencyServices!.primaryAmbulance,
                              color: Colors.red,
                              onTap: () => _callEmergencyService(
                                'Ambulance',
                                _emergencyServices!.primaryAmbulance,
                              ),
                            ),

                          SizedBox(height: 12),

                          // Fire Brigade
                          if (_emergencyServices!.primaryFire.isNotEmpty)
                            _EmergencyServiceCard(
                              icon: Icons.fire_truck,
                              serviceName: 'Fire Brigade',
                              number: _emergencyServices!.primaryFire,
                              color: Colors.deepOrange,
                              onTap: () => _callEmergencyService(
                                'Fire Brigade',
                                _emergencyServices!.primaryFire,
                              ),
                            ),
                        ],
                      ),
                    ),

                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}

class _EmergencyServiceCard extends StatelessWidget {
  final IconData icon;
  final String serviceName;
  final String number;
  final Color color;
  final VoidCallback onTap;

  _EmergencyServiceCard({
    required this.icon,
    required this.serviceName,
    required this.number,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Card(
        elevation: 2,
        color: Colors.grey.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: color, width: 2),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceName,
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      number,
                      style: TextStyle(
                        color: color,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(Icons.phone, color: Colors.white, size: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
