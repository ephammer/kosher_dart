/// Shabbat begins at sunset, so a Friday's candle lighting is always before it,
/// even when that Friday is the last day of a Yom Tov outside Israel.
library;

import 'package:kosher_dart/kosher_dart.dart';
import 'package:test/test.dart';

void main() {
  ComplexZmanimCalendar calendarFor(DateTime date) {
    final GeoLocation location =
        GeoLocation.setLocation('Jerusalem', 31.778, 35.235, date);
    return ComplexZmanimCalendar.intGeoLocation(location)..setCalendar(date);
  }

  void expectEighteenMinutesBeforeSunset(DateTime date) {
    final ComplexZmanimCalendar calendar = calendarFor(date);
    expect(
      calendar.getCandleLighting(),
      calendar.getSeaLevelSunset()!.subtract(const Duration(minutes: 18)),
    );
  }

  test('Friday 6 Sivan', () {
    expectEighteenMinutesBeforeSunset(DateTime(2027, 6, 11));
  });

  test('Friday 21 Nisan', () {
    expectEighteenMinutesBeforeSunset(DateTime(2029, 4, 6));
  });

  test('every Friday from 2000 to 2050', () {
    for (DateTime day = DateTime(2000, 1, 7);
        day.year <= 2050;
        day = DateTime(day.year, day.month, day.day + 7)) {
      expectEighteenMinutesBeforeSunset(day);
    }
  });
}
