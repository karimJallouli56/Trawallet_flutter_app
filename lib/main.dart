import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trawallet_final_version/firebase_options.dart';
import 'package:trawallet_final_version/models/vault_item.dart';
import 'package:trawallet_final_version/services/vault_service.dart';
import 'package:trawallet_final_version/views/auth/auth_wrapper.dart';
import 'package:trawallet_final_version/views/auth/login_screen.dart';
import 'package:trawallet_final_version/views/community/posts_screen.dart';
import 'package:trawallet_final_version/views/emergency/emergency_screen.dart';
import 'package:trawallet_final_version/views/home/home_screen.dart';
import 'package:trawallet_final_version/views/profile/profile_details_screen.dart';
import 'package:trawallet_final_version/views/profile/profile_edit_screen.dart';
import 'package:trawallet_final_version/views/profile/profile_screen.dart';
import 'package:trawallet_final_version/views/transport/transport_screen.dart';
import 'package:trawallet_final_version/views/trip%20planner/travel_career_screen.dart';
import 'package:trawallet_final_version/views/trip%20planner/trip_screen.dart';
import 'package:trawallet_final_version/views/vault/vault_screen.dart';
import 'package:trawallet_final_version/views/weather/weather_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://nydkmuqxbdmosymchola.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im55ZGttdXF4YmRtb3N5bWNob2xhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ3ODkyMDcsImV4cCI6MjA4MDM2NTIwN30.LcGG1pxdT0sAdxt1TMbWFX6rwooMUGM5n-w2Nldw2B8',
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  Hive.registerAdapter(VaultItemAdapter());
  await Hive.openBox<VaultItem>('vaultBox');
  // Initialize VaultService singleton
  await VaultService.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trawallet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: AuthWrapper(),
      routes: {
        '/profile': (context) => ProfileScreen(),
        '/home': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/profileDetails': (context) => ProfileDetailsScreen(),
        '/profileEdit': (context) => ProfileEditScreen(),
        '/vault': (context) => VaultScreen(),
        '/community': (context) => TravelFeedScreen(),
        '/weather': (context) => WeatherScreen(),
        '/transport': (context) => TransportScreen(),
        '/sos': (context) => EmergencyScreen(),
        '/planner': (context) => TravelSchedulerScreen(),
        '/travelCareer': (context) => TravelCareerScreen(),
      },
    );
  }
}
