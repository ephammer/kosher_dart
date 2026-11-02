/// Tests for the calendar rules that were aligned with KosherJava 3.1.0.
///
/// Every expectation is a concrete date whose result was taken from KosherJava
/// (see tool/kosherjava). Dates are built from local year/month/day so the
/// tests do not depend on the time zone of the machine.
library;

import 'package:kosher_dart/kosher_dart.dart';
import 'package:test/test.dart';

JewishCalendar calendar(int year, int month, int day,
    {bool inIsrael = false, bool modern = false}) {
  final JewishCalendar jc = JewishCalendar.fromDateTime(DateTime(year, month, day));
  jc.inIsrael = inIsrael;
  jc.setUseModernHolidays(modern);
  return jc;
}

void main() {
  group('isYomTov', () {
    test('is false on erev Pesach, Shavuos, Rosh Hashana, Yom Kippur and Succos', () {
      expect(calendar(2024, 4, 22).isYomTov(), isFalse); // erev Pesach
      expect(calendar(2024, 6, 11).isYomTov(), isFalse); // erev Shavuos
      expect(calendar(2024, 10, 2).isYomTov(), isFalse); // erev Rosh Hashana
      expect(calendar(2024, 10, 11).isYomTov(), isFalse); // erev Yom Kippur
      expect(calendar(2024, 10, 16).isYomTov(), isFalse); // erev Succos
    });

    test('is true on Yom Tov, Chol Hamoed and Hoshana Rabba', () {
      expect(calendar(2024, 4, 29).isYomTov(), isTrue); // Pesach 7th day
      expect(calendar(2024, 10, 22).isYomTov(), isTrue); // Chol Hamoed Succos
      expect(calendar(2024, 10, 23).isYomTov(), isTrue); // Hoshana Rabba
    });

    test('Tachanun is still skipped on erev Yom Tov', () {
      final TefilaRules rules = TefilaRules();
      expect(rules.isTachanunRecitedShacharis(calendar(2024, 10, 2)), isFalse);
      expect(rules.isTachanunRecitedShacharis(calendar(2024, 10, 11)), isFalse);
      expect(rules.isTachanunRecitedShacharis(calendar(2024, 10, 16)), isFalse);
      expect(rules.isTachanunRecitedShacharis(calendar(2024, 6, 11)), isFalse);
    });
  });

  group('fast days', () {
    test('Taanis Bechoros is moved to Thursday 12 Nissan', () {
      expect(calendar(2001, 4, 5).isTaanisBechoros(), isTrue); // Thursday 12 Nissan
      expect(calendar(2001, 4, 7).isTaanisBechoros(), isFalse); // Shabbos 14 Nissan
      expect(calendar(2024, 4, 22).isTaanisBechoros(), isTrue); // Monday 14 Nissan
    });

    test('17 Tammuz on Shabbos is pushed to Sunday', () {
      final JewishCalendar shabbos = calendar(2029, 6, 30);
      expect(shabbos.getJewishDayOfMonth(), 17);
      expect(shabbos.isTaanis(), isFalse);
      expect(shabbos.getYomTovIndex(), -1);
      final JewishCalendar sunday = calendar(2029, 7, 1);
      expect(sunday.isTaanis(), isTrue);
      expect(sunday.getYomTovIndex(), JewishCalendar.SEVENTEEN_OF_TAMMUZ);
    });

    test('17 Tammuz on a weekday is a fast', () {
      final JewishCalendar tuesday = calendar(2024, 7, 23);
      expect(tuesday.getJewishDayOfMonth(), 17);
      expect(tuesday.getYomTovIndex(), JewishCalendar.SEVENTEEN_OF_TAMMUZ);
    });
  });

  group('Chol Hamoed', () {
    test('Hoshana Rabba is Chol Hamoed Succos', () {
      final JewishCalendar hoshanaRabba = calendar(2024, 10, 23);
      expect(hoshanaRabba.getYomTovIndex(), JewishCalendar.HOSHANA_RABBA);
      expect(hoshanaRabba.isCholHamoedSuccos(), isTrue);
      expect(hoshanaRabba.isCholHamoed(), isTrue);
      expect(calendar(2024, 10, 24).isCholHamoed(), isFalse); // Shemini Atzeres
    });
  });

  group('Isru Chag', () {
    test('the constant is unique', () {
      expect(JewishCalendar.ISRU_CHAG, isNot(JewishCalendar.SHUSHAN_PURIM_KATAN));
      expect(JewishCalendar.EREV_ROSH_CHODESH, 28);
    });

    test('out of Israel', () {
      for (final DateTime day in [
        DateTime(2024, 5, 1), // 23 Nissan
        DateTime(2024, 6, 14), // 8 Sivan
        DateTime(2024, 10, 26), // 24 Tishrei
      ]) {
        final JewishCalendar jc = calendar(day.year, day.month, day.day);
        expect(jc.getYomTovIndex(), JewishCalendar.ISRU_CHAG);
        expect(jc.isIsruChag(), isTrue);
        expect(jc.isYomTov(), isFalse);
      }
      expect(calendar(2024, 4, 30).isIsruChag(), isFalse); // 22 Nissan is Pesach
    });

    test('in Israel', () {
      for (final DateTime day in [
        DateTime(2024, 4, 30), // 22 Nissan
        DateTime(2024, 6, 13), // 7 Sivan
        DateTime(2024, 10, 25), // 23 Tishrei
      ]) {
        final JewishCalendar jc = calendar(day.year, day.month, day.day, inIsrael: true);
        expect(jc.getYomTovIndex(), JewishCalendar.ISRU_CHAG);
        expect(jc.isIsruChag(), isTrue);
        expect(jc.isYomTov(), isFalse);
      }
    });

    test('Shushan Purim Katan is not Isru Chag', () {
      final JewishCalendar jc = calendar(2024, 2, 24);
      expect(jc.getYomTovIndex(), JewishCalendar.SHUSHAN_PURIM_KATAN);
      expect(jc.isIsruChag(), isFalse);
      expect(jc.isYomTov(), isTrue);
    });

    test('formatYomTov names it', () {
      final HebrewDateFormatter english = HebrewDateFormatter();
      final HebrewDateFormatter hebrew = HebrewDateFormatter()..hebrewFormat = true;
      final JewishCalendar jc = calendar(2024, 10, 26);
      expect(english.formatYomTov(jc), 'Isru Chag');
      expect(hebrew.formatYomTov(jc), 'אסרו חג');
    });

    test('there is no Tachanun on Isru Chag', () {
      final TefilaRules rules = TefilaRules();
      for (final JewishCalendar jc in [
        calendar(2024, 10, 26),
        calendar(2024, 10, 25, inIsrael: true),
        calendar(2024, 6, 14),
        calendar(2024, 6, 13, inIsrael: true),
      ]) {
        expect(rules.isTachanunRecitedShacharis(jc), isFalse);
        expect(rules.isTachanunRecitedMincha(jc), isFalse);
      }
    });
  });

  group('clone', () {
    test('keeps inIsrael, modern holidays and isMukafChoma', () {
      final JewishCalendar jc = calendar(2024, 5, 13, inIsrael: true, modern: true);
      jc.isMukafChoma = true;
      final JewishCalendar copy = jc.clone();
      expect(copy.inIsrael, isTrue);
      expect(copy.isUseModernHolidays(), isTrue);
      expect(copy.isMukafChoma, isTrue);
      expect(copy, jc);
    });

    test('Tachanun at Mincha before Yom Haatzmaut', () {
      final TefilaRules rules = TefilaRules();
      // Monday 13 May 2024 is Yom Hazikaron, Yom Haatzmaut is the next day.
      expect(rules.isTachanunRecitedMincha(calendar(2024, 5, 13, inIsrael: true, modern: true)), isFalse);
      expect(rules.isTachanunRecitedShacharis(calendar(2024, 5, 14, inIsrael: true, modern: true)), isFalse);
      expect(rules.isTachanunRecitedShacharis(calendar(2024, 5, 14, inIsrael: true)), isTrue);
    });
  });

  group('Vesein Tal Umatar', () {
    final TefilaRules rules = TefilaRules();

    test('in Israel it starts on 7 Cheshvan only', () {
      expect(rules.isVeseinTalUmatarStartingTonight(calendar(2024, 11, 7, inIsrael: true)), isTrue);
      expect(rules.isVeseinTalUmatarStartDate(calendar(2024, 11, 8, inIsrael: true)), isTrue);
      for (final DateTime day in [DateTime(2024, 12, 4), DateTime(2024, 12, 5)]) {
        final JewishCalendar jc = calendar(day.year, day.month, day.day, inIsrael: true);
        expect(rules.isVeseinTalUmatarStartDate(jc), isFalse);
        expect(rules.isVeseinTalUmatarStartingTonight(jc), isFalse);
        expect(rules.isVeseinTalUmatarRecited(jc), isTrue);
      }
    });

    test('out of Israel it starts in December', () {
      expect(rules.isVeseinTalUmatarStartingTonight(calendar(2024, 12, 4)), isTrue);
      expect(rules.isVeseinTalUmatarStartDate(calendar(2024, 12, 5)), isTrue);
      expect(rules.isVeseinTalUmatarRecited(calendar(2024, 12, 4)), isFalse);
      expect(rules.isVeseinTalUmatarRecited(calendar(2024, 12, 5)), isTrue);
    });

    test('when the start falls on Shabbos it moves to Sunday', () {
      // Shabbos 5 December 2026: starting tonight, but not recited until Sunday.
      expect(rules.isVeseinTalUmatarStartingTonight(calendar(2026, 12, 5)), isTrue);
      expect(rules.isVeseinTalUmatarStartDate(calendar(2026, 12, 5)), isFalse);
      expect(rules.isVeseinTalUmatarStartDate(calendar(2026, 12, 6)), isTrue);
      expect(rules.isVeseinTalUmatarStartingTonight(calendar(2026, 12, 6)), isFalse);
      // Friday 5 December 2025: Friday night is not tonight.
      expect(rules.isVeseinTalUmatarStartDate(calendar(2025, 12, 5)), isTrue);
      expect(rules.isVeseinTalUmatarStartingTonight(calendar(2025, 12, 5)), isFalse);
    });
  });

  group('special Shabbasos', () {
    final HebrewDateFormatter english = HebrewDateFormatter();
    final HebrewDateFormatter hebrew = HebrewDateFormatter()..hebrewFormat = true;

    void expectSpecial(DateTime day, Parsha parsha, String en, String he) {
      final JewishCalendar jc = calendar(day.year, day.month, day.day);
      expect(jc.getSpecialShabbos(), parsha);
      expect(english.formatSpecialParsha(jc), en);
      expect(hebrew.formatSpecialParsha(jc), he);
    }

    test('the nine special Shabbasos of 5784', () {
      expectSpecial(DateTime(2024, 1, 27), Parsha.SHIRA, 'Shira', 'שירה');
      expectSpecial(DateTime(2024, 3, 9), Parsha.SHKALIM, 'Shekalim', 'שקלים');
      expectSpecial(DateTime(2024, 3, 23), Parsha.ZACHOR, 'Zachor', 'זכור');
      expectSpecial(DateTime(2024, 3, 30), Parsha.PARA, 'Parah', 'פרה');
      expectSpecial(DateTime(2024, 4, 6), Parsha.HACHODESH, 'Hachodesh', 'החדש');
      expectSpecial(DateTime(2024, 4, 20), Parsha.HAGADOL, 'Hagadol', 'הגדול');
      expectSpecial(DateTime(2024, 8, 10), Parsha.CHAZON, 'Chazon', 'חזון');
      expectSpecial(DateTime(2024, 8, 17), Parsha.NACHAMU, 'Nachamu', 'נחמו');
      expectSpecial(DateTime(2024, 10, 5), Parsha.SHUVA, 'Shuva', 'שובה');
    });

    test('an ordinary Shabbos and a weekday have none', () {
      expect(calendar(2024, 1, 20).getSpecialShabbos(), Parsha.NONE);
      expect(calendar(2024, 1, 26).getSpecialShabbos(), Parsha.NONE);
    });
  });

  group('Daf Yomi Yerushalmi', () {
    test('moves to the next masechta on the first daf', () {
      expect(_daf(2000, 1, 8), '25:1');
      expect(_daf(2000, 2, 24), '26:1');
      expect(_daf(2000, 4, 4), '27:1');
      expect(_daf(2000, 1, 7), '24:72');
    });
  });

  group('Hebrew Shushan Purim', () {
    test('word order', () {
      final HebrewDateFormatter hebrew = HebrewDateFormatter()..hebrewFormat = true;
      expect(hebrew.formatYomTov(calendar(2000, 3, 22)), 'שושן פורים');
      expect(hebrew.formatYomTov(calendar(2000, 2, 21)), 'שושן פורים קטן');
    });
  });
}

String _daf(int year, int month, int day) {
  final Daf daf = calendar(year, month, day).getDafYomiYerushalmi();
  return '${daf.getMasechtaNumber()}:${daf.getDaf()}';
}
