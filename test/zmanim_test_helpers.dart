/// Helpers for the tests of the zmanim: a [ComplexZmanimCalendar] for a place and day.
library;

import 'package:kosher_dart/kosher_dart.dart';
import 'package:test/test.dart';

ComplexZmanimCalendar calendarAt(
    String name, double latitude, double longitude, DateTime day) {
  final GeoLocation location =
      GeoLocation.setLocation(name, latitude, longitude, day);
  return ComplexZmanimCalendar.intGeoLocation(location)..setCalendar(day);
}

ComplexZmanimCalendar jerusalem(DateTime day) =>
    calendarAt('Jerusalem', 31.778, 35.2354, day);
ComplexZmanimCalendar tromso(DateTime day) =>
    calendarAt('Tromso', 69.6492, 18.9553, day);
ComplexZmanimCalendar london(DateTime day) =>
    calendarAt('London', 51.5074, -0.1278, day);
ComplexZmanimCalendar paris(DateTime day) =>
    calendarAt('Paris', 48.8566, 2.3522, day);

int? millis(DateTime? time) => time?.millisecondsSinceEpoch;

/// Expects [actual] to be within [toleranceMillis] of [expectedMillis].
void expectNear(DateTime? actual, int expectedMillis,
    {int toleranceMillis = 1500}) {
  expect(actual, isNotNull);
  expect((actual!.millisecondsSinceEpoch - expectedMillis).abs(),
      lessThanOrEqualTo(toleranceMillis));
}
