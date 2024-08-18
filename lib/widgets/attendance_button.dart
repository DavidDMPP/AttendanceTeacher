import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';

final _logger = Logger('AttendanceButton');

class AttendanceButton extends StatelessWidget {
  const AttendanceButton({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final databaseService = Provider.of<DatabaseService>(context);
    final locationService = Provider.of<LocationService>(context);

    return ElevatedButton(
      child: const Text('Record Attendance'),
      onPressed: () async {
        final user = authService.currentUser;
        if (user != null) {
          try {
            final position = await locationService.getCurrentLocation();
            final isWithinRange =
                await locationService.isWithinAttendanceRange();

            if (isWithinRange) {
              final geoPoint = GeoPoint(position.latitude, position.longitude);
              final attendanceType =
                  await databaseService.getNextAttendanceType(user.uid);

              await databaseService.addAttendance(
                user.uid,
                geoPoint,
                attendanceType,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('$attendanceType recorded successfully')),
                );
              }
            } else {
              // Fetch the school location and max distance for detailed info
              DocumentSnapshot schoolDoc = await FirebaseFirestore.instance
                  .collection('settings')
                  .doc('school_location')
                  .get();
              GeoPoint schoolLocation = schoolDoc['location'];
              double maxDistance = schoolDoc['max_distance'].toDouble();

              double distance = Geolocator.distanceBetween(
                position.latitude,
                position.longitude,
                schoolLocation.latitude,
                schoolLocation.longitude,
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('You are not within the attendance range. '
                          'Your distance: ${distance.toStringAsFixed(2)} meters. '
                          'Max allowed: $maxDistance meters.')),
                );
              }
            }
          } catch (e) {
            _logger.severe('Error recording attendance', e);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to record attendance: $e')),
              );
            }
          }
        }
      },
    );
  }
}
