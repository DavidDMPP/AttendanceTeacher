import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/location_service.dart';
import 'package:logging/logging.dart';

final _logger = Logger('LocationProvider');

class LocationProvider with ChangeNotifier {
  final LocationService _locationService;
  bool _isWithinRange = false;
  Timer? _timer;

  LocationProvider(this._locationService) {
    _checkLocationStatus();
    // Check location status every 1 minute
    _timer = Timer.periodic(
        const Duration(minutes: 1), (_) => _checkLocationStatus());
  }

  bool get isWithinRange => _isWithinRange;

  Future<void> _checkLocationStatus() async {
    try {
      bool status = await _locationService.isWithinAttendanceRange();
      _logger.info('Checking location status. Within range: $status');
      if (status != _isWithinRange) {
        _isWithinRange = status;
        notifyListeners();
      }
    } catch (e) {
      _logger.severe('Error checking location status: $e');
    }
  }

  Future<void> forceLocationCheck() async {
    await _checkLocationStatus();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
