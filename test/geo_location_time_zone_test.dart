/// [GeoLocation] takes the time zone of a location from the `timeZoneOffset` of the `DateTime` it is given. A plain
/// `DateTime` can only be UTC or the zone of the machine, so a time zone aware subclass (such as the `TZDateTime`
/// of the `timezone` package) has to be passed for a location in another zone. These tests use a `DateTime` with
/// a fixed offset to show what the local mean time offset and the antimeridian adjustment depend on.
@TestOn('vm')
library;

import 'dart:mirrors';

import 'package:kosher_dart/kosher_dart.dart';
import 'package:test/test.dart';

/// A [DateTime] that reports a fixed offset from UTC and delegates everything else.
class FixedOffsetDateTime implements DateTime {
  FixedOffsetDateTime(this._dateTime, this._offset);

  final DateTime _dateTime;
  final Duration _offset;

  @override
  Duration get timeZoneOffset => _offset;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      reflect(_dateTime).delegate(invocation);
}

void main() {
  final DateTime day = DateTime(2018, 2, 3);

  GeoLocation location(double latitude, double longitude, Duration offset) =>
      GeoLocation.setLocation(
          'test', latitude, longitude, FixedOffsetDateTime(day, offset));

  test('local mean time offset of Yerushalayim in standard time', () {
    final GeoLocation jerusalem =
        location(31.778, 35.2354, const Duration(hours: 2));
    // 35.2354 degrees * 4 minutes is 140:56.496, 2 hours of which is the zone.
    expect(jerusalem.getLocalMeanTimeOffset(), 1256496);
    expect(jerusalem.getAntimeridianAdjustment(), 0);
  });

  test('Apia uses UTC+14 across the antimeridian, so the date goes back a day',
      () {
    final GeoLocation apia =
        location(-13.83, -171.75, const Duration(hours: 14));
    expect(apia.getAntimeridianAdjustment(), -1);
  });

  test(
      'the same longitude with the offset of the wrong zone gets no adjustment',
      () {
    final GeoLocation apia =
        location(-13.83, -171.75, const Duration(hours: -11));
    expect(apia.getAntimeridianAdjustment(), 0);
  });
}
