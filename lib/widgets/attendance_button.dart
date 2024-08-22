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

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
      height: MediaQuery.of(context).size.width *
          0.8, // Same as width to make it circular
      child: ElevatedButton(
        onPressed: () async {
          final user = authService.currentUser;
          if (user != null) {
            try {
              final position = await locationService.getCurrentLocation();
              final isWithinRange =
                  await locationService.isWithinAttendanceRange();

              if (isWithinRange) {
                final geoPoint =
                    GeoPoint(position.latitude, position.longitude);
                final attendanceType =
                    await databaseService.getNextAttendanceType(user.uid);

                await databaseService.addAttendance(
                  user.uid,
                  geoPoint,
                  attendanceType,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$attendanceType berhasil dicatat')),
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
                      content: Text('Anda berada di luar jangkauan absensi. '
                          'Jarak Anda: ${distance.toStringAsFixed(2)} meter. '
                          'Jarak maksimum yang diizinkan: $maxDistance meter.'),
                    ),
                  );
                }
              }
            } catch (e) {
              _logger.severe('Error saat mencatat absensi', e);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal mencatat absensi: $e')),
                );
              }
            }
          }
        },
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(20),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Klik Untuk Absensi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white
                    .withOpacity(0.8), // Sedikit transparan untuk perbedaan
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
