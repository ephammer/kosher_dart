/// Tests for zmanim at places and times where the sun does not rise, set or get low enough, and for zmanim
/// added from KosherJava 3.1.0.
library;

import 'package:kosher_dart/kosher_dart.dart';
import 'package:test/test.dart';

import 'zmanim_test_helpers.dart';

void main() {
  group('polar night', () {
    final DateTime day = DateTime(2026, 1, 1);

    test('nothing is calculated and nothing throws', () {
      final ComplexZmanimCalendar c = tromso(day);
      expect(c.getSunrise(), isNull);
      expect(c.getChatzos(), isNull);
      expect(c.getSunTransit(), isNull);
      expect(c.getSofZmanShmaGRA(), isNull);
      expect(c.getSofZmanTfilaGRA(), isNull);
      expect(c.getMinchaGedola(), isNull);
      expect(c.getMinchaKetana(), isNull);
      expect(c.getPlagHamincha(), isNull);
      expect(c.getMinchaGedolaGreaterThan30(), isNull);
      expect(c.getSofZmanShma3HoursBeforeChatzos(), isNull);
      expect(c.getMinchaGedola30Minutes(), isNull);
      expect(c.getSolarMidnight(), isNull);
      expect(c.getMidday(), isNull);
      expect(c.getSofZmanBiurChametzGRA(), isNull);
      expect(c.getShaahZmanisGra().isNaN, isTrue);
      expect(c.getTemporalHour().isNaN, isTrue);
    });
  });

  group('degrees the sun does not reach', () {
    test('alos 16.1 in a London summer is null, not the GRA time', () {
      final ComplexZmanimCalendar c = london(DateTime(2026, 6, 4));
      expect(c.getAlos16Point1Degrees(), isNull);
      expect(c.getSofZmanShmaMGA16Point1Degrees(), isNull);
      expect(c.getSofZmanTfilaMGA16Point1Degrees(), isNull);
      expect(c.getMinchaGedola16Point1Degrees(), isNull);
      expect(c.getPlagHamincha16Point1Degrees(), isNull);
      expect(c.getShaahZmanis16Point1Degrees().isNaN, isTrue);
      expect(c.getSofZmanShma(null, null), isNull);
      expect(c.getSunrise(), isNotNull);
    });

    test('the day before it is calculated', () {
      expectNear(
          london(DateTime(2026, 6, 3)).getAlos16Point1Degrees(), 1780445784057);
    });

    test(
        'dusk 18 degrees is null on a Paris night that stays lighter, so are the zmanim of the MGA',
        () {
      final ComplexZmanimCalendar c = paris(DateTime(2026, 6, 12));
      expectNear(c.getAlos18Degrees(), 1781222073019);
      expect(c.getTzais18Degrees(), isNull);
      expect(c.getSofZmanShmaMGA18Degrees(), isNull);
      expect(c.getPlagHamincha18Degrees(), isNull);
    });

    test('nautical twilight in Tromso when the sun does not get low enough',
        () {
      expect(tromso(DateTime(2026, 4, 12)).getBeginNauticalTwilight(), isNull);
      expectNear(tromso(DateTime(2026, 4, 11)).getBeginNauticalTwilight(),
          1775862625896);
    });

    test('a zman the sun only just reaches is not missed', () {
      expectNear(
          paris(DateTime(2026, 8, 11)).getTzais26Degrees(), 1786491509831);
      expectNear(paris(DateTime(2026, 6, 30)).getEndAstronomicalTwilight(),
          1782863162319);
      expectNear(london(DateTime(2026, 7, 8)).getTzais16Point1Degrees(),
          1783555140853);
    });
  });

  group('very short days', () {
    final DateTime day = DateTime(2026, 1, 15);

    test('zmanim outside of the day are null', () {
      final ComplexZmanimCalendar c = tromso(day);
      expect(c.getSunrise(), isNotNull);
      expect(c.getMinchaGedola30Minutes(), isNull);
      expect(c.getSofZmanShma3HoursBeforeChatzos(), isNull);
      expect(c.getSofZmanTfila2HoursBeforeChatzos(), isNull);
      expect(c.getBainHasmashosYereim18Minutes(), isNull);
      expect(c.getMinchaKetanaAteretTorah(), isNull);
      expect(c.getPlagHaminchaAteretTorah(), isNull);
    });

    test('mincha gedola greater than 30 falls back to mincha gedola', () {
      final ComplexZmanimCalendar c = tromso(DateTime(2026, 11, 26));
      expect(c.getMinchaGedola30Minutes(), isNotNull);
      final ComplexZmanimCalendar shortDay = tromso(DateTime(2026, 11, 27));
      expect(shortDay.getMinchaGedola30Minutes(), isNull);
      expect(
          shortDay.getMinchaGedolaGreaterThan30(), shortDay.getMinchaGedola());
      expect(shortDay.getMinchaGedolaGreaterThan30(), isNotNull);
    });
  });

  group('zmanim added from KosherJava', () {
    test('degrees', () {
      final ComplexZmanimCalendar c = jerusalem(DateTime(2026, 3, 16));
      expect(c.getMisheyakir12Point85Degrees(), isNotNull);
      expect(
          c
              .getMisheyakir12Point85Degrees()!
              .isBefore(c.getMisheyakir11Point5Degrees()!),
          isTrue);
      expect(
          c
              .getTzaisGeonim4Point42Degrees()!
              .isBefore(c.getTzaisGeonim4Point66Degrees()!),
          isTrue);
      expect(
          c
              .getTzaisGeonim4Point66Degrees()!
              .isBefore(c.getTzaisGeonim5Point95Degrees()!),
          isTrue);
      expect(c.getSofZmanTfilaAteretTorah(), c.getSofZmanTfilahAteretTorah());
    });
  });
}
