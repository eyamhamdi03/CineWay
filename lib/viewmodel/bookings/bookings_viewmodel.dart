import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/booking.dart';
import '../../services/local_storage.dart';

class BookingsViewModel extends ChangeNotifier {
  final LocalStorage storage;
  BookingsViewModel(this.storage);

  final List<Booking> _bookings = [];
  List<Booking> get bookings => List.unmodifiable(_bookings);

  Future<void> load() async {
    final list = await storage.getStringList(storage.kBookings);
    _bookings.clear();
    for (final s in list) {
      try {
        _bookings.add(Booking.fromJson(json.decode(s)));
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> addBooking(Booking booking) async {
    _bookings.add(booking);
    await _save();
    notifyListeners();
  }

  Future<void> clearBookings() async {
    _bookings.clear();
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final list = _bookings.map((b) => json.encode(b.toJson())).toList();
    await storage.setStringList(storage.kBookings, list);
  }
}
