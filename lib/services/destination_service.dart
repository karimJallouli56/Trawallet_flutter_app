import 'package:trawallet_final_version/data/mock_destinations.dart';
import 'package:trawallet_final_version/models/destination.dart';

class DestinationsService {
  Future<List<Destination>> fetchDestinations() async {
    return getMockDestinations();
  }
}
