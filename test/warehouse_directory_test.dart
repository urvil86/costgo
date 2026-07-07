import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:cartgolf/features/geofence/warehouse_directory.dart';

void main() {
  late WarehouseDirectory directory;

  setUpAll(() {
    final json = jsonDecode(
            File('assets/costco_locations.json').readAsStringSync())
        as Map<String, dynamic>;
    directory = WarehouseDirectory.fromJson(json);
  });

  test('the bundled dataset is real, not a placeholder', () {
    expect(directory.warehouses.length, greaterThan(650));
    // Coordinates look like North America, not nulls or zeros.
    for (final w in directory.warehouses.take(50)) {
      expect(w.lat, inInclusiveRange(17.0, 65.0), reason: w.label);
      expect(w.lng, inInclusiveRange(-165.0, -52.0), reason: w.label);
    }
  });

  test('nearest lookup finds the Tampa warehouse from Tampa', () {
    // Raymond James Stadium, Tampa FL.
    final hit = directory.nearestTo(27.9759, -82.5033)!;
    expect(hit.warehouse.state, 'FL');
    expect(hit.miles, lessThan(15));
  });

  test('nearest-20 comes back sorted for fence registration', () {
    final fences = directory.nearest(47.6062, -122.3321); // Seattle
    expect(fences.length, 20);
    for (var i = 1; i < fences.length; i++) {
      expect(fences[i].miles, greaterThanOrEqualTo(fences[i - 1].miles));
    }
    // Seattle is warehouse country: the closest should be minutes away.
    expect(fences.first.miles, lessThan(10));
  });

  test('haversine sanity: LA to NYC is ~2450 miles', () {
    final d = WarehouseDirectory.milesBetween(
        34.0522, -118.2437, 40.7128, -74.0060);
    expect(d, closeTo(2450, 20));
  });
}
