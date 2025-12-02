import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/cinema.dart';

class GPSViewModel extends ChangeNotifier {
  Position? userPosition;

  Future<void> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      return;
    }

    userPosition = await Geolocator.getCurrentPosition();
    notifyListeners();
  }

  // Distance to cinema in KM
  double distanceToCinema(Cinema cinema) {
    if (userPosition == null) return 9999;

    final meters = Geolocator.distanceBetween(
      userPosition!.latitude,
      userPosition!.longitude,
      cinema.latitude,
      cinema.longitude,
    );

    return meters / 1000;
  }
}
