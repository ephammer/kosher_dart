/// Tests for solar midnight (chatzos halayla), including days with daylight saving time changes.
library;

import 'package:kosher_dart/kosher_dart.dart';
import 'package:test/test.dart';

import 'zmanim_test_helpers.dart';

void main() {
  group('solar midnight', () {
    // Every day of 2026 in places that change to and from daylight saving time. It must be between sunset and the
    // next sunrise, and at the middle of them.
    void expectMidnightBetweenSunsetAndSunrise(
        ComplexZmanimCalendar Function(DateTime) at) {
      for (DateTime day = DateTime(2026, 1, 1);
          day.year == 2026;
          day = DateTime(day.year, day.month, day.day + 1)) {
        final ComplexZmanimCalendar today = at(day);
        final ComplexZmanimCalendar tomorrow =
            at(DateTime(day.year, day.month, day.day + 1));
        final DateTime sunset = today.getSeaLevelSunset()!;
        final DateTime sunrise = tomorrow.getSeaLevelSunrise()!;
        final DateTime? midnight = today.getSolarMidnight();
        expect(midnight, isNotNull, reason: '$day');
        final int expected =
            (sunset.millisecondsSinceEpoch + sunrise.millisecondsSinceEpoch) ~/
                2;
        expect((midnight!.millisecondsSinceEpoch - expected).abs(),
            lessThanOrEqualTo(1),
            reason: '$day');
        expect(midnight.isAfter(sunset), isTrue, reason: '$day');
        expect(midnight.isBefore(sunrise), isTrue, reason: '$day');
      }
    }

    test('Jerusalem', () => expectMidnightBetweenSunsetAndSunrise(jerusalem));
    test('Paris', () => expectMidnightBetweenSunsetAndSunrise(paris));
    test(
        'New York',
        () => expectMidnightBetweenSunsetAndSunrise(
            (DateTime day) => calendarAt('New York', 40.7128, -74.006, day)));

    test('chatzos halayla is the solar midnight', () {
      final ComplexZmanimCalendar day = jerusalem(DateTime(2026, 10, 25));
      expect(day.getChatzosHalayla(), day.getSolarMidnight());
    });
  });
}
