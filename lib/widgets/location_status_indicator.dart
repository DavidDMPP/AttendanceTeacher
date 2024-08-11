import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';

class LocationStatusIndicator extends StatelessWidget {
  const LocationStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: locationProvider.isWithinRange ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        locationProvider.isWithinRange ? 'Dalam Jangkauan' : 'Di Luar Jangkauan',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}