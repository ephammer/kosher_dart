/// Tests for the molad and the kiddush levana zmanim, with the values of KosherJava 3.1.0.
library;

import 'package:kosher_dart/kosher_dart.dart';
import 'package:test/test.dart';

import 'zmanim_test_helpers.dart';

void main() {
  group('molad', () {
    DateTime moladOf(int year, int month, int day) =>
        JewishCalendar.fromDateTime(DateTime(year, month, day))
            .getMoladAsDateTime();

    test('is the instant of the molad in Yerushalayim local mean time', () {
      expect(millis(moladOf(2000, 1, 1)), 944624143504);
      expect(millis(moladOf(2024, 2, 24)), 1707505700170);
      expect(millis(moladOf(2026, 11, 2)), 1791703330170);
    });

    test('kiddush levana is a fixed time after the molad', () {
      final JewishCalendar jc =
          JewishCalendar.fromDateTime(DateTime(2026, 11, 2));
      final int molad = millis(jc.getMoladAsDateTime())!;
      expect(
          millis(jc.getTchilasZmanKidushLevana3Days()), molad + 72 * 3600000);
      expect(
          millis(jc.getTchilasZmanKidushLevana7Days()), molad + 168 * 3600000);
      expect(millis(jc.getSofZmanKidushLevana15Days()), molad + 360 * 3600000);
      expect(
          millis(jc.getSofZmanKidushLevanaBetweenMoldos()), molad + 1275721666);
    });
  });

  group('kiddush levana zmanim', () {
    test('on the day of the zman', () {
      expect(millis(jerusalem(DateTime(2026, 1, 18)).getZmanMolad()),
          1768740340170);
      expect(
          millis(jerusalem(DateTime(2026, 1, 21))
              .getTchilasZmanKidushLevana3Days()),
          1768999540170);
      expect(
          millis(jerusalem(DateTime(2026, 1, 25))
              .getTchilasZmanKidushLevana7Days()),
          1769345140170);
      expect(
          millis(
              jerusalem(DateTime(2026, 2, 2)).getSofZmanKidushLevana15Days()),
          1770036340170);
      expect(
          millis(jerusalem(DateTime(2026, 2, 2))
              .getSofZmanKidushLevanaBetweenMoldos()),
          1770016061836);
      expect(
          millis(jerusalem(DateTime(2026, 3, 3))
              .getSofZmanKidushLevanaBetweenMoldos()),
          1772567505170);
    });

    test('on other days there is none', () {
      expect(jerusalem(DateTime(2026, 1, 19)).getZmanMolad(), isNull);
      expect(jerusalem(DateTime(2026, 1, 22)).getTchilasZmanKidushLevana3Days(),
          isNull);
      expect(jerusalem(DateTime(2026, 2, 3)).getSofZmanKidushLevana15Days(),
          isNull);
    });

    test('a zman during the day moves to the night', () {
      final ComplexZmanimCalendar tchila = jerusalem(DateTime(2026, 1, 21));
      expect(
          tchila.getTchilasZmanKidushLevana3Days(
              tchila.getAlos16Point1Degrees(), tchila.getTzais72()),
          tchila.getTzais72());
      final ComplexZmanimCalendar sof = jerusalem(DateTime(2026, 2, 2));
      expect(
          sof.getSofZmanKidushLevana15Days(
              sof.getAlos16Point1Degrees(), sof.getTzais72()),
          sof.getAlos16Point1Degrees());
    });

    test(
        'midnights are the calendar dates, 23 or 25 hours apart on a daylight saving change',
        () {
      final ComplexZmanimCalendar day = jerusalem(DateTime(2026, 3, 1));
      expect(day.getMidnightLastNight(), DateTime(2026, 3, 1));
      expect(day.getMidnightTonight(), DateTime(2026, 3, 2));
    });
  });

  group('melacha on a Friday in December', () {
    test('isAssurBemlacha uses the right date', () {
      final DateTime friday = DateTime(2026, 12, 4);
      final ComplexZmanimCalendar c = jerusalem(friday);
      final DateTime sunset = c.getSeaLevelSunset()!;
      final DateTime tzais = c.getTzais72()!;
      expect(
          c.isAssurBemlacha(
              sunset.add(const Duration(minutes: 1)), tzais, true),
          isTrue);
      expect(
          c.isAssurBemlacha(
              sunset.subtract(const Duration(minutes: 1)), tzais, true),
          isFalse);
    });
  });
}
