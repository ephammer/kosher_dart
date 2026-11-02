# Expected differences from KosherJava 3.1.0

What `tool/kosherjava/run.sh` still reports, and why. Anything not listed here is a difference to look at.
Rows are shown by the name they have in the report.

## Calendar

| Rows | Why they remain |
|---|---|
| `en.format`, `en.dow`, `he.format`, `he.dow`, `he.rc` | Spelling kept on purpose: `23 Teves 5760` without the comma, `Sun` for `Sunday`, `סיון`/`חשון` for `סיוון`/`חשוון`, `ששי` for `שישי`. |
| `en.parsha`, `he.parsha` | Dart's `formatWeeklyParsha` gives the parsha of the coming Shabbos on weekdays, KosherJava's `formatParshah` is empty except on Shabbos. |
| `getDafYomiYerushalmi` | On Yom Kippur and Tisha B'Av KosherJava returns null, this library returns `Daf(39, 0)`. All other days match. |

KosherJava only (not ported): `getInIsrael`, `getIsMukafChoma` (the Dart fields are `inIsrael` and `isMukafChoma`),
`getUpcomingParshah`, `isAlHanissimRecited`, `isBeHaB`, `isHoshanaRabba`, `isMizmorLesodaRecited`, `isPesach`,
`isRoshHashana`, `isShavuos`, `isShminiAtzeres`, `isSimchasTorah`, `isSuccos`, `isTishaBav`,
`isTonightMutarBemelacha`, `isYaalehVeyavoRecited`, `isYomKippur`, `isYomKippurKatan`.
They are convenience wrappers around `getYomTovIndex`; none was needed for a behaviour fix.

Dart only: `getGregorianCalendar`, `getGregorianDayOfMonth`, `getGregorianMonth`, `getGregorianYear`, `isMashivHaruach`,
`isShoavavimWeek`.

Numeric constants differ on purpose (`EREV_ROSH_CHODESH = 28` and so on). The tool compares `getYomTovIndex` by constant
name. `ISRU_CHAG` is 36 here and 35 in KosherJava; `SHUSHAN_PURIM_KATAN` is 35 here and 34 in KosherJava.

## Zmanim

### Chatzos is the middle of the day, not the sun's transit
`getChatzosHayom` (Dart `getChatzos`), `getSunTransit`, `getSolarMidnight`, `getChatzosHalayla` and what is built on
chatzos: `getMinchaGedola30Minutes`, `getSofZmanShma3HoursBeforeChatzos`, `getSofZmanTfila2HoursBeforeChatzos`,
`getMinchaGedolaGRAGreaterThan30`. This library keeps chatzos as the middle between sunrise and sunset (and
sunset and the next sunrise for midnight), which is what the app shows. KosherJava 3.x returns the astronomical
transit by default. Median 14 seconds, up to 12 minutes in Tromso.

### Chametz
`getSofZmanAchilas*` and `getSofZmanBiur*` (`...GRA`, `...MGA72Minutes`, `...MGA16Point1Degrees`, `...BaalHatanya`):
KosherJava returns null except on 14 Nissan, these return a time on every day.

### Candle lighting
`getCandleLighting` is intentionally different: it returns null on days without candle lighting and uses tzais on the
second night of Yom Tov. KosherJava calculates 18 minutes before sunset every day.

### Sunrise and sunset
Everything built on `getSunrise`, `getSunset` and their sea level versions (alos and tzais in minutes or zmanis, sof zman
shma and tfila, mincha gedola and ketana, plag, bain hashmashos, shaah zmanis, ...): up to 3.3 seconds at ordinary
latitudes and a mean of half a second early. Two causes:

- this library cuts the time to whole seconds, KosherJava keeps milliseconds. The rows for degree based times
  (`getAlos16Point1Degrees`, `getTzais...Degrees`) differ by less than a second for this reason alone and are not listed;
- KosherJava 3.x adjusts the sunrise and sunset zenith by the apparent solar radius of the day of the year instead of a
  fixed 16 arc minutes. That is a change of the model, not a bug fix, and moves every published sunrise and sunset by up to
  3 seconds, so it is not ported.

Zmanim that are a multiple of a temporal hour from sunrise or sunset (`getAlos120Zmanis`, `getTzais120Zmanis`, ...)
add up the two ends, up to about 4 seconds at ordinary latitudes.

### Tromso
The sun barely rises around 15 January and 27 November (the first and last days with a sunrise). A few seconds of change
in the zenith move sunrise by up to a minute there, so `getSunrise`, `getSunset`, `getShaahZmanis*`,
`getTemporalHour` and everything built on them differ by up to 70 seconds (up to 9 seconds for a shaah zmanis). Other
places are not affected.

### API that only one library has
KosherJava only: `getChatzosHayomAsHalfDay` (this library's `getChatzos`), `getFixedLocalChatzosHayom` (compared with
`getFixedLocalChatzos`), `getMinchaGedolaAhavatShalom`, `getMinchaKetanaAhavatShalom`, `getPlagAhavatShalom`,
`getPolar*BenIshChai`, `getPolar*TeshuvosVehanhagos`, `getSamuchLeMinchaKetana*`,
`getShaahZmanisAlos16Point1DegreesToTzais*`, `getSofZmanAchilasChametzMGA72MinutesZmanis`,
`getSofZmanBiurChametzMGA72MinutesZmanis`, `isUseAstronomicalChatzos`, `isUseAstronomicalChatzosForOtherZmanim`.
The Ahavat Shalom zmanim do not exist in this library, so there was nothing to guard.

Dart only: `getAdjustedCalendar`, `getCalendar`, `getElevationAdjustedSunrise`, `getElevationAdjustedSunset`, `getMidday`,
`getMidnightLastNight`, `getMidnightTonight`, `getMinchaGedolaBaalHatanyaGreaterThan30`, `getShabbosExitTime`,
`getShabbosStartTime`, `getSofZmanShmaFixedLocal`, `getSofZmanShmaKolEliyahu`, `getSofZmanTfilaFixedLocal`,
`getSunriseBaalHatanya`, `getSunsetBaalHatanya`, `getTaanisExitTime`, `getTaanisStartTime`, `getTallisAndTefillin`,
`getTzaisGeonim3Point65Degrees`, `getTzaisGeonim3Point676Degrees`, `getTzaisGeonim4Point37Degrees`,
`getTzaisGeonim4Point61Degrees`, `getTzaisGeonim5Point88Degrees`, `getYomTovExitTime`, `getYomTovStartTime`.

## Not covered by the comparison
- The time zone: `GeoLocation` takes it from the `DateTime` it is given. A plain `DateTime` has the zone of the machine,
  so the antimeridian adjustment and local mean time are only right for a location in that zone (see the comment on
  `GeoLocation.setLocation` and `test/geo_location_time_zone_test.dart`).
- `SunTimesCalculator` (not the default calculator) still clamps the hour angle and is not changed.
- Midnight for the kiddush levana window (`getMidnightLastNight`) is midnight in the zone of the machine, like the
  other times of this library.
