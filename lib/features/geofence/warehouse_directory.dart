/// Warehouse locations — bundled once at build time, never fetched at
/// runtime. Used to answer "which warehouse am I at?" on the start-trip
/// screen today; the same data feeds real arrival prompts later (M3).
/// Pure Dart, no Flutter imports.
library;

import 'dart:math';

class Warehouse {
  const Warehouse({
    required this.name,
    required this.city,
    required this.state,
    required this.country,
    required this.lat,
    required this.lng,
  });

  final String name;
  final String city;
  final String state;
  final String country;
  final double lat;
  final double lng;

  factory Warehouse.fromJson(Map<String, dynamic> json) => Warehouse(
        name: json['name'] as String,
        city: json['city'] as String,
        state: json['state'] as String,
        country: json['country'] as String,
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
      );

  /// "Tampa, FL" — how the UI names a warehouse.
  String get label =>
      state.isEmpty ? city.toUpperCase() : '${city.toUpperCase()}, $state';
}

class NearestResult {
  const NearestResult(this.warehouse, this.miles);

  final Warehouse warehouse;
  final double miles;
}

class WarehouseDirectory {
  const WarehouseDirectory(this.warehouses);

  final List<Warehouse> warehouses;

  factory WarehouseDirectory.fromJson(Map<String, dynamic> json) =>
      WarehouseDirectory([
        for (final w in json['warehouses'] as List)
          Warehouse.fromJson(w as Map<String, dynamic>)
      ]);

  bool get isEmpty => warehouses.isEmpty;

  /// Great-circle distance in miles.
  static double milesBetween(
      double lat1, double lng1, double lat2, double lng2) {
    const earthRadiusMiles = 3958.8;
    double rad(double deg) => deg * pi / 180;
    final dLat = rad(lat2 - lat1);
    final dLng = rad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(rad(lat1)) * cos(rad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
    return earthRadiusMiles * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  NearestResult? nearestTo(double lat, double lng) {
    Warehouse? best;
    var bestMiles = double.infinity;
    for (final w in warehouses) {
      final d = milesBetween(lat, lng, w.lat, w.lng);
      if (d < bestMiles) {
        bestMiles = d;
        best = w;
      }
    }
    return best == null ? null : NearestResult(best, bestMiles);
  }

  /// The N closest warehouses — what M3 registers as arrival fences.
  List<NearestResult> nearest(double lat, double lng, {int count = 20}) {
    final all = [
      for (final w in warehouses)
        NearestResult(w, milesBetween(lat, lng, w.lat, w.lng))
    ]..sort((a, b) => a.miles.compareTo(b.miles));
    return all.take(count).toList();
  }
}
