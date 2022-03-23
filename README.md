# HebrewCalendar
Hebrew Calendar mathematical functions lib

B"SD

Shalom aleichem!

These are a conversion from the original javaScript functions for *Positional Astronomy*, by John Walker -- September, MIM (http://www.fourmilab.ch/).
This program is in the public domain. [^1]

Not all functions are exposed, but mainly we have:
```pascal
- function DateToHebrew(Year, Month, Day: integer): TYearMonthDay;
- function DateTimeToHebrew(DateTime: TDateTime; ZeroHour: boolean = true): TYearMonthDay;
- function AmountOfDaysHebrewInYear(Year: integer): single;
- function JulianDateToHebrewDate(julianFloat: single): TYearMonthDay;
- function JulianDateToGregorianDate(julianDay: single): TYearMonthDay;
- function HebrewDateToJulianDate(Year, Month, Day: integer): single;
- function JulianDateToISODate(julianDay: single): TYearMonthDay;
```
This was a project I did to help a friend to make his application and he was struggling as Delphi doesn't have such functions and of course these are a bit hard to find.

Together the HebrewCalendar.pas I am also incluing an *Astromonical Calculator*, again from John Walker, but these one I just made the 1st pass from conversion, so the functions and methods are named same way the original software is. The Hebrew Calendar doesn't depends on this astronomical lib to be included.

Feel free to improve it.

[^1]: This library is licensed under Creative Commons CC-0 (aka CC Zero), which means that this a public dedication tool, which allows creators to give up their copyright and put their works into the worldwide public domain. You're allowed to distribute, remix, adapt, and build upon the material in any medium or format, with no conditions.
