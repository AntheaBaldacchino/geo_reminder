import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import '../models/reminder.dart';
import '../services/notification_service.dart';

class RemindersProvider extends ChangeNotifier {
  RemindersProvider(this._analytics);

  final FirebaseAnalytics _analytics;
  late final Box<Reminder> _box;

  Position? _currentPosition;
  List<Reminder> _items = [];

  List<Reminder> get items => List.unmodifiable(_items);
  Position? get currentPosition => _currentPosition;

  // Call this method to initialize the provider
  Future<void> init() async {
    _box = Hive.box<Reminder>('reminders');
    _items = _box.values.toList();
    notifyListeners();
  }

  Future<void> refreshLocationAndCheck() async {
    final pos = await _getCurrentPosition();
    _currentPosition = pos;

    for (final r in _items) {
      if (r.notified) continue;

      final d = _distanceMeters(
        pos.latitude,
        pos.longitude,
        r.latitude,
        r.longitude,
      );

      if (d <= r.radiusMeters) {
        r.notified = true;
        await r.save();
        await NotificationService.instance.showNearbyReminder(r.title);

        await _analytics.logEvent(
          name: 'nearby_reminder_notified',
          parameters: {'id': r.id, 'title': r.title},
        );
      }
    }

    notifyListeners();
  }

  Future<void> addReminder(Reminder r) async {
    await _box.put(r.id, r);
    _items = _box.values.toList();

    await _analytics.logEvent(
      name: 'reminder_added',
      parameters: {'id': r.id, 'title': r.title},
    );

    notifyListeners();
  }

  Future<void> deleteReminder(Reminder r) async {
    await _box.delete(r.id);
    _items = _box.values.toList();

    await _analytics.logEvent(
      name: 'reminder_deleted',
      parameters: {'id': r.id},
    );
    // Notify listeners after analytics event to ensure UI updates after logging
    notifyListeners();
  }

  double? distanceTo(Reminder r) {
    final pos = _currentPosition;
    if (pos == null) return null;

    // Calculate distance
    return _distanceMeters(
      pos.latitude,
      pos.longitude,
      r.latitude,
      r.longitude,
    );
  }

  // Helper method to get current position with permission handling
  Future<Position> _getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied.');
    }

  // When we reach here, permissions are granted and we can get the position
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  double _distanceMeters(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371000.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  double _degToRad(double deg) => deg * (pi / 180.0);
}
