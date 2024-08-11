import 'package:flutter/foundation.dart';
import '../services/location_service.dart';
import 'package:logging/logging.dart';

final _logger = Logger('LocationProvider');

class LocationProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();
  bool _isWithinRange = false;

  bool get isWithinRange => _isWithinRange;

  Future<void> checkLocationStatus() async {
    try {
      _isWithinRange = await _locationService.isWithinAttendanceRange();
      notifyListeners();
    } catch (e) {
      _logger.warning('Failed to check location status', e);
      _isWithinRange = false;
      notifyListeners();
    }
  }
}