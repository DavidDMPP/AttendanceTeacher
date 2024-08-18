import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';

final _logger = Logger('LocationService');

class LocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<bool> isWithinAttendanceRange() async {
    Position position = await getCurrentLocation();
    _logger
        .info('Current position: ${position.latitude}, ${position.longitude}');

    DocumentSnapshot schoolDoc =
        await _firestore.collection('settings').doc('school_location').get();

    if (!schoolDoc.exists) {
      throw Exception('School location settings not found');
    }

    GeoPoint schoolLocation = schoolDoc['location'];
    double maxDistance = schoolDoc['max_distance'].toDouble();

    _logger.info(
        'School location: ${schoolLocation.latitude}, ${schoolLocation.longitude}');
    _logger.info('Max distance: $maxDistance');

    double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      schoolLocation.latitude,
      schoolLocation.longitude,
    );

    _logger.info('Calculated distance: $distance meters');

    bool isWithin = distance <= maxDistance;
    _logger.info('Is within range: $isWithin');

    return isWithin;
  }

  Future<void> updateSchoolLocation(
      GeoPoint location, double maxDistance) async {
    await _firestore.collection('settings').doc('school_location').set({
      'location': location,
      'max_distance': maxDistance,
    }, SetOptions(merge: true));
    _logger.info(
        'Updated school location: ${location.latitude}, ${location.longitude}');
    _logger.info('Updated max distance: $maxDistance');
  }
}
