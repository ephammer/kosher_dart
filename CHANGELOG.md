## Unreleased (fork)
Aligned with KosherJava 3.1.0. `tool/kosherjava/run.sh` compares the two libraries and
`tool/kosherjava/EXPECTED_DIFFERENCES.md` lists what still differs on purpose.

Calendar
- `isYomTov()` is no longer true on erev Pesach, Shavuos, Rosh Hashana, Yom Kippur and Succos (operator precedence); `TefilaRules.isTachanunRecitedShacharis` checks `isErevYomTov()` itself and gives the same answers
- `getYomTovIndex()` returns `ISRU_CHAG` on Isru Chag (day after Pesach, Shavuos and Succos, in and out of Israel) instead of -1; `isIsruChag()` is true only then, `isYomTov()` is false, `formatYomTov` names it (`Isru Chag`, `אסרו חג`). `ISRU_CHAG` is now 36, it used to be 35 like `SHUSHAN_PURIM_KATAN`
- `isTaanisBechoros()` on Thursday 12 Nissan (was Tuesday); 17 Tammuz on Shabbos is no fast (was Friday)
- `isCholHamoedSuccos()` and `isCholHamoed()` include Hoshana Rabba
- `getSpecialShabbos()` also returns the new `Parsha` values `HAGADOL`, `CHAZON`, `NACHAMU`, `SHUVA` and `SHIRA`, with Hebrew and English names in `HebrewDateFormatter`. The values are added at the end of the enum
- `JewishCalendar.clone()` keeps `useModernHolidays` (tachanun before Yom Haatzmaut and Yom Yerushalayim was wrong) and the new `isMukafChoma`; added `isPurim()`
- `TefilaRules.isVeseinTalUmatarStartDate` and `isVeseinTalUmatarStartingTonight` match KosherJava in and out of Israel
- `getDafYomiYerushalmi` moves to the next masechta on its first daf (was the last daf plus one) and counts a Tisha B'Av that is pushed to Sunday; the date arithmetic no longer depends on the time zone
- Hebrew `formatYomTov` writes `שושן פורים` and `שושן פורים קטן`
- The molad fields of `JewishDate` start at 0 instead of throwing before `getMolad()`

Zmanim
- `getMoladAsDateTime()` returns the instant of the molad on any machine (it was hours off, and depended on the time zone of the machine); `getZmanMolad`, `getTchilasZmanKidushLevana3Days/7Days` and `getSofZmanKidushLevana*` build on it
- Kiddush levana zmanim in `ComplexZmanimCalendar` and `ZmanimCalendar.isAssurBemlacha` passed a 1-based month to `setGregorianDate` (0-based): wrong day, and an `ArgumentError` for `isAssurBemlacha` in December
- `getSolarMidnight()` steps to the next calendar date; on the day daylight saving time ends it returned solar noon. `getMidnightTonight()` was the same as `getMidnightLastNight()`
- The NOAA calculator no longer clamps the hour angle: a degree based alos (or any zman) the sun never reaches is `null` instead of solar midnight, and a zenith the sun only just reaches is found
- `getSofZmanShma`, `getSofZmanTfila`, `getMinchaGedola`, `getMinchaKetana`, `getPlagHamincha` and the zmanim built on them return `null` where a boundary of the day does not exist, instead of the GRA time or an endless recursion; `getTemporalHour` and `getShaahZmanis*` return `double.nan` instead of throwing. New `getTemporalHourBetween`
- Short polar days: `getMinchaGedola30Minutes`, `getMinchaGedolaGRAFixedLocalChatzos30Minutes`, `getSofZmanShma3HoursBeforeChatzos`, `getSofZmanTfila2HoursBeforeChatzos`, `getBainHasmashosYereim*Minutes`, `getMinchaKetanaAteretTorah`, `getPlagHaminchaAteretTorah` and `getFixedLocalChatzos` return `null` outside the day; `getMinchaGedolaGreaterThan30` falls back to `getMinchaGedola`
- Added `getChatzosHalayla`, `getMisheyakir12Point85Degrees`, `getTzaisGeonim4Point42Degrees`, `getTzaisGeonim4Point66Degrees` and `getSofZmanTfilaAteretTorah`
- `getChatzos` stays the middle of the day, not the sun's transit
- `GeoLocation` documents that its time zone comes from the `DateTime` it is given; pass a time zone aware `DateTime` for a place in another zone than the machine

## 2.0.20
- Improve runtime performance across core calculation functions
- Updated package description to be cleaner and more accurate

## 2.0.19
- Fixed Yom Ha'atzmaut and Yom Hazikaron postponement rules for years when they fall on Friday or Saturday
- Added `JewishDate.back()` support for `Calendar.MONTH` — backward Jewish month rolling with correct Tishrei/Nissan boundary handling
- Overhauled all source file documentation to use effective Dart doc style (`///`) instead of Javadoc (`/** */`), including proper cross-references, Markdown formatting and Dart-idiomatic conventions
- Fixed dangling library doc comments in `JewishDate`, `JewishCalendar` and `HebrewDateFormatter`
- Fixed all `dart analyze` lint warnings: removed unnecessary library name, converted to super parameters, replaced explicit null comparisons with null-aware operators (`?.`)
- Enabled `dangling_library_doc_comments` lint rule in `analysis_options.yaml`
- Added comprehensive unit tests covering Jewish date navigation, leap years, Gregorian month days, Parsha calculation, Yomi calculators and zmanim calendar
- Added GitHub Actions CI workflow to run unit tests on every push and pull request to master

## 2.0.18
- Updated intl dependency constraint from ^0.19.0 to ^0.20.1
- Updated the Dart SDK constraint to >=3.0.0 <4.0.0 to ensure compatibility with newer SDK
- Implemented missing JewishCalendar.initDate constructor body

## 2.0.17
- Update 'intl' to v0.19
- Update Dart SDK
- Fix bug on ZmanimCalendar.getCandleLighting() for erev yom tov sheni out side israel

## 2.0.16
- Bug fix

## 2.0.15
- Fixed syntax mistakes

## 2.0.14
- Replace method 'equals' to operator == on classes AstronomicalCalendar, GeoLocation, JewishCalendar, JewishDate
- Add hashCode() to classes GeoLocation, JewishCalendar, JewishDate
- Added Supporting on Dart 3
- Update 'intl' to v0.18.1

## 2.0.13
- Fix JewishDate.clone()
- Added tefila rules
- 
## 2.0.12
- Fix bug on HebrewDateFormatter.format()

## 2.0.11
- Bug fixed on formatWeeklyParsha();
- Remove  get & set for inIsrael variable.

## 2.0.10
- Fix bug on getShabbosStartTime()
- General syntax fix

## 2.0.9
- Added method isShoavavimWeek()
- Improved implementation of format() method with 'pattern' parameter for building date format
- Changes have been made base on KosherJava (last commit 28.12.2021)
  - Fix AstronomicalCalendar getSunriseSolarDipFromOffset() and getSunsetSolarDipFromOffset (they are still inefficient) to properly allow calculations before and after sun rise/set.
  - Simplify and reduce code duplication in ZmanimCalendar generic zmanim calculations.
  - Added Daf.setMasechtaTransliterated(List<String> masechtosBavliTransliterated) and Daf.setYerushlmiMasechtaTransliterated(List<String> masechtosYerushalmiTransliterated).
  - Added JewishCalendar.isTaanisBechoros().
  - Add seasonal davening based zmanim including Vesein Tal Umatar/ Vesein Berachah / Mashiv Haruach.
  - Fix an issue with sof zman kiddush levana being off by an hour when the molad is on one side of the DST change, and the sof zman on the other.

## 2.0.8
- Fix method getCandleLighting() for Chanukah

## 2.0.7
- Fix method getCandleLighting()

## 2.0.6
- Added method getTallisAndTefillin()
- Added Usage section on README.md file.

## 2.0.5
- Fixed _getSunHourAngleAtSunrise() always return null for same location.

## 2.0.4
- Fixed zmanim calculation on some time zone.

## 2.0.3
- Add support for null safety.
- Fixed Taanis times.

## 2.0.2

- Now only need to import kosher_dart.dart file
- Added method getEventsList() to hebrew_date_formatter.dart file. Return list of events for the day.
- Added method getEvent() to hebrew_date_formatter.dart file. Return event for the day.
- Added method for exit and entry Shabbos time of this week.
- Added method for exit and entry of the closer Yom Tov.
- Added method for exit and entry of the closer Taanis.
- Bugs fixed Based on [KosherJava Zmanim API commit f7e24ce](https://github.com/KosherJava/zmanim/tree/f7e24ce604e3fcd1c10824fc0d18bb7c8a0b7e99)
- Bug & Documentation fix

## 2.0.1

- Bug & Documentation fix.

## 2.0.0

- Added `formatWeeklyParsha` function for getting String of Parsha in given week.
- Bug fix Based on [KosherJava Zmanim API commit cb5977c](https://github.com/KosherJava/zmanim/tree/cb5977c9efa5396660f130eac0150d41b47613d2)

## 1.0.0

Completion of translation from [KosherJava Zmanim API](https://github.com/KosherJava/zmanim) 