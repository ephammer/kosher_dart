/*
 * Zmanim Java API
 * Copyright (C) 2017 - 2018 Eliyahu Hershfeld
 *
 * This library is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General
 * Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
 * details.
 * You should have received a copy of the GNU Lesser General Public License along with this library; if not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA,
 * or connect to: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 */

import 'dart:core';

import 'package:kosher_dart/src/hebrewcalendar/daf.dart';
import 'package:kosher_dart/src/hebrewcalendar/jewish_calendar.dart';
import 'package:kosher_dart/src/hebrewcalendar/jewish_date.dart';

/// This class calculates the [Talmud Yerusalmi](https://en.wikipedia.org/wiki/Jerusalem_Talmud) [Daf Yomi]
/// (https://en.wikipedia.org/wiki/Daf_Yomi) page ([Daf]) for the a given date.
///
/// © elihaidv
/// © Eliyahu Hershfeld 2017 - 2018
class YerushalmiYomiCalculator {
  /// The start date of the first Daf Yomi Yerushalmi cycle of February 2, 1980 / 15 Shevat, 5740.

  static final DateTime dafYomiStartDay = DateTime(1980, 2, 2);

  /// The number of milliseconds in a day.
  static const int DAY_MILIS = 1000 * 60 * 60 * 24;

  /// he number of pages in the Talmud Yerushalmi.
  static const int WHOLE_SHAS_DAFS = 1554;

  /// The number of pages per _masechta_ (tractate).
  static const List<int> BLATT_PER_MASSECTA = [
    68,
    37,
    34,
    44,
    31,
    59,
    26,
    33,
    28,
    20,
    13,
    92,
    65,
    71,
    22,
    22,
    42,
    26,
    26,
    33,
    34,
    22,
    19,
    85,
    72,
    47,
    40,
    47,
    54,
    48,
    44,
    37,
    34,
    44,
    9,
    57,
    37,
    19,
    13
  ];

  /// Returns the [Daf Yomi](https://en.wikipedia.org/wiki/Daf_Yomi)
  /// [Yerusalmi](https://en.wikipedia.org/wiki/Jerusalem_Talmud) page ([Daf]) for a given date.
  /// The first Daf Yomi cycle started on 15 Shevat (Tu Bishvat), 5740 (February, 2, 1980) and calculations
  /// prior to this date will result in an IllegalArgumentException thrown.
  ///
  /// - [calendar]: 
  ///   the calendar date for calculation
  /// Returns the [Daf].
  ///
  /// Throws [ArgumentError] 
  ///             if the date is prior to the September 11, 1923 start date of the first Daf Yomi cycle
  static Daf getDafYomiYerushalmi(JewishCalendar calendar) {
    // All the date arithmetic is done on UTC calendar dates, so that daylight saving time can't shift a day.
    final DateTime requested = _toUtcDate(calendar.getGregorianCalendar());
    int masechta = 0;
    Daf dafYomi = Daf(0, 0);

    // There isn't Daf Yomi in Yom Kippur and Tisha Beav.
    if (calendar.getYomTovIndex() == JewishCalendar.YOM_KIPPUR ||
        calendar.getYomTovIndex() == JewishCalendar.TISHA_BEAV) {
      return Daf(39, 0);
    }

    final DateTime startDay = _toUtcDate(dafYomiStartDay);
    if (requested.isBefore(startDay)) {
      // TODO: should we return a null or throw an IllegalArgumentException?
      throw ArgumentError(
          "$requested is prior to organized Daf Yomi Yerushlmi cycles that started on $dafYomiStartDay");
    }

    // Go cycle by cycle, until we reach the cycle that includes the requested date
    DateTime prevCycle = startDay;
    DateTime nextCycle = _getNextCycleStart(prevCycle);
    while (!requested.isBefore(nextCycle)) {
      prevCycle = nextCycle;
      nextCycle = _getNextCycleStart(prevCycle);
    }

    // Get the number of days from cycle start until request, less the days without a daf.
    int total = _getDiffBetweenDays(prevCycle, requested) -
        _getNumOfSpecialDays(prevCycle, requested);

    // Finally find the daf.
    for (int j = 0; j < BLATT_PER_MASSECTA.length; j++) {
      if (total < BLATT_PER_MASSECTA[j]) {
        dafYomi = Daf(masechta, total + 1);
        break;
      }
      total -= BLATT_PER_MASSECTA[j];
      masechta++;
    }

    return dafYomi;
  }

  static DateTime _toUtcDate(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  static DateTime _addDays(DateTime date, int days) {
    return DateTime.utc(date.year, date.month, date.day + days);
  }

  /// The day after the last day of the cycle that starts on [cycleStart]. A cycle is a whole _Shas_ of
  /// [WHOLE_SHAS_DAFS] days, extended by the _Yom Kippur_ and _Tisha Beav_ days that have no daf.
  static DateTime _getNextCycleStart(DateTime cycleStart) {
    DateTime endDate = _addDays(cycleStart, WHOLE_SHAS_DAFS - 1);
    int specialDays = _getNumOfSpecialDays(cycleStart, endDate);
    while (specialDays > 0) {
      final DateTime newStart = _addDays(endDate, 1);
      endDate = _addDays(endDate, specialDays);
      specialDays = _getNumOfSpecialDays(newStart, endDate);
    }
    return _addDays(endDate, 1);
  }

  static int _getNumOfSpecialDays(DateTime start, DateTime end) {
    // Find the start and end Jewish years
    int startYear = _jewishYearOf(start);
    int endYear = _jewishYearOf(end);

    int specialDays = 0;
    for (int year = startYear; year <= endYear; year++) {
      final DateTime yomKippur = _toUtcDate(
          JewishCalendar.initDate(year, JewishDate.TISHREI, 10)
              .getGregorianCalendar());
      final JewishCalendar tishaBeavCalendar =
          JewishCalendar.initDate(year, JewishDate.AV, 9);
      DateTime tishaBeav = _toUtcDate(tishaBeavCalendar.getGregorianCalendar());
      // Tisha Beav is pushed off to Sunday when it is on Shabbos
      if (tishaBeavCalendar.getDayOfWeek() == JewishDate.saturday) {
        tishaBeav = _addDays(tishaBeav, 1);
      }
      if (_isBetween(start, yomKippur, end)) {
        specialDays++;
      }
      if (_isBetween(start, tishaBeav, end)) {
        specialDays++;
      }
    }
    return specialDays;
  }

  static int _jewishYearOf(DateTime utcDate) {
    return JewishCalendar.fromDateTime(
            DateTime(utcDate.year, utcDate.month, utcDate.day))
        .getJewishYear();
  }

  static bool _isBetween(DateTime start, DateTime date, DateTime end) {
    return !date.isBefore(start) && !end.isBefore(date);
  }

  static int _getDiffBetweenDays(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }
}
