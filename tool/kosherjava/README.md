# KosherJava comparison

This fork follows [KosherJava](https://github.com/KosherJava/zmanim). The tool runs
both libraries over the same inputs and lists every difference.

```bash
tool/kosherjava/run.sh        # compares with KosherJava 3.1.0
tool/kosherjava/run.sh 3.2.0  # or with another tag
```

It needs Java 11+ and Python 3, takes a few minutes, and writes
`build/kosherjava/report.txt`.

- **Zmanim:** every no-argument getter, each day of 2026, at the places in `places.txt`.
  Each place runs with `TZ` set to its own zone. Differences under a second are only counted.
- **Calendar:** every no-argument getter on `JewishCalendar`, the `TefilaRules` checks and
  the Hebrew and English formatters, each day of 2000–2050, in and out of Israel.

`compare.py` maps KosherJava 3.x method names back to the Dart names. The report ends
each section with the methods only one library has.
