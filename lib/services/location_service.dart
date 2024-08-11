import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> isWithinAttendanceRange() async {
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
      throw Exception('Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition();
    
    DocumentSnapshot schoolDoc = await _firestore
        .collection('settings')
        .doc('school_location')
        .get();
    
    if (!schoolDoc.exists) {
      throw Exception('School location settings not found');
    }

    GeoPoint schoolLocation = schoolDoc['location'];
    double maxDistance = schoolDoc['max_distance'].toDouble();

    double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      schoolLocation.latitude,
      schoolLocation.longitude,
    );

    return distance <= maxDistance;
  }

  Future<void> updateSchoolLocation(GeoPoint location, double maxDistance) async {
    await _firestore.collection('settings').doc('school_location').set({
      'location': location,
      'max_distance': maxDistance,
    });
  }
}