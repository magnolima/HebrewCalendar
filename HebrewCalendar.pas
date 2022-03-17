(*
  Original javaScript functions for positional astronomy
  by John Walker -- September, MIM
  http://www.fourmilab.ch/
  This program is in the public domain.

  Conversion to Delphi: Magno Lima 2018/5778
  Revisited: 2022 / 5782
*)
unit HebrewCalendar;

interface

uses
  System.SysUtils, System.Math, System.DateUtils;

const
  J0000 = 1721424.5; // Julian date of Gregorian epoch: 0000-01-01
  J1970 = 2440587.5; // Julian date at Unix epoch: 1970-01-01
  JMJD = 2400000.5; // Epoch of Modified Julian Date system
  J1900 = 2415020.5; // Epoch (day 1) of Excel 1900 date system (PC)
  J1904 = 2416480.5;
  GREGORIAN_EPOCH = 1721425.5;
  JULIAN_EPOCH = 1721423.5;
  HEBREW_EPOCH = 347995.5;

var
  NormLeap: array of string = ['Normal year', 'Leap year'];
  HebrewMonth: array of string = ['Nisan', 'Iyar', 'Sivan', 'Tamuz', 'Av', 'Elul',
                                  'Tishrei', 'Cheshvan', 'Kislev', 'Tevet', 'Shevat',
                                  'Adar', 'Adar II'];

  HebrewMonthName: array of string = ['ניסן', 'אייר', 'סיון', 'תמוז', 'אב', 'אלול',
                                      'תשרי', 'חשון', 'כסלו', 'טבת', 'שבט', 'אדר', 'ב אדר'];


type
  TYearMonthDay = record
    Year, Month, Day, Week: integer;
    FullDate, HebrewMonth, HebrewMonthName: String;
  end;

function DateToHebrew(Year, Month, Day: integer): TYearMonthDay;
function DateTimeToHebrew(DateTime: TDateTime; ZeroHour: boolean = true): TYearMonthDay;
function AmountOfDaysHebrewInYear(Year: integer): single;
function JulianDateToHebrewDate(julianFloat: single): TYearMonthDay;
function JulianDateToGregorianDate(julianDay: single): TYearMonthDay;
function HebrewDateToJulianDate(Year, Month, Day: integer): single;
function JulianDateToISODate(julianDay: single): TYearMonthDay;

implementation

function ModFloat(Dividend, Divisor: single): single;
var
  Quotient: integer;
begin
  Quotient := Floor(Dividend / Divisor);
  result := Dividend - Divisor * Quotient;
end;

// Test for delay of start of new year and to avoid
// Sunday, Wednesday, and Friday as start of the new year.
function hebrew_delay_1(Year: integer): single;
var
  months, days, parts: integer;
begin
  months := Floor(((235 * Year) - 234) / 19);
  parts := 12084 + (13753 * months);
  days := (months * 29) + Floor(parts / 25920);

  if (ModFloat((3 * (days + 1)), 7) < 3) then
    days := days + 1;

  result := days;
end;

// Check for delay in start of new year due to length of adjacent years
function hebrew_delay_2(Year: integer): single;
var
  last, present, next: single;
  check: integer;
begin
  last := hebrew_delay_1(Year - 1);
  present := hebrew_delay_1(Year);
  next := hebrew_delay_1(Year + 1);

  result := IfThen((next - present) = 356, 2, IfThen((present - last) = 382, 1, 0));

end;

// HEBREW_TO_JD  --  Determine Julian day from Hebrew date
// Is a given Hebrew year a leap year ?
function HebrewDateLeap(Year: integer): boolean;
begin
  result := (((Year * 7) + 1) mod 19) < 7;
end;

// How many months are there in a Hebrew year (12 = normal, 13 = leap)
function AmountOfMonthsInHebrewYear(Year: integer): integer;
begin
  result := IfThen(HebrewDateLeap(Year), 13, 12);
end;

// JWDAY  --  Calculate day of week from Julian day
function DayOfWeekFromJulianDay(julianDay: single): integer;
begin
  result := Floor((julianDay + 1.5)) mod 7;
end;

// *  WEEKDAY_BEFORE  --  Return Julian date of given weekday (0 = Sunday)
// in the seven days ending on jd.  */
function WeekdayBefore(weekday: integer; julianDay: single): single;
begin
  result := julianDay - DayOfWeekFromJulianDay(julianDay - weekday);
end;

(* SEARCH_WEEKDAY  --  Determine the Julian date for:

  weekday      Day of week desired, 0 = Sunday
  jd           Julian date to begin search
  direction    1 = next weekday, -1 = last weekday
  offset       Offset from jd to begin search
*)

function SearchWeekday(const weekday: integer; julianDay: single; direction, offset: integer): single;
begin
  result := WeekdayBefore(weekday, julianDay + (direction * offset));
end;

// Utility weekday functions, just wrappers for search_weekday
function NearestJulianWeekday(weekday, julianDay: integer): single;
begin
  result := SearchWeekday(weekday, julianDay, 1, 3);
end;

function NextJulianWeekday(weekday: integer; julianDay: single): single;
begin
  result := SearchWeekday(weekday, julianDay, 1, 7);
end;

function NextOrCurrentJulianWeekday(weekday, julianDay: integer): single;
begin
  result := SearchWeekday(weekday, julianDay, 1, 6);
end;

function PreviousJulianWeekday(weekday: integer; julianDay: single): single;
begin
  result := SearchWeekday(weekday, julianDay, -1, 1);
end;

function PreviousOrCurrentJulianweekday(weekday, julianDay: integer): single;
begin
  result := SearchWeekday(weekday, julianDay, 1, 0);
end;

// LEAP_GREGORIAN  --  Is a given year in the Gregorian calendar a leap year ?
function LeapGregorianDate(Year: integer): boolean;
begin
  // return ((year % 4) == 0) && (!(((year % 100) == 0) && ((year % 400) != 0)));
  result := ((Year mod 4) = 0) and (not(((Year mod 100) = 0) and ((Year and 400) <> 0)));
end;

// How many days are in a given month of a given year
function AmountOfDaysFromHebrewDate(Year, Month: integer): integer;
begin

  // Default... it's a 30 day month
  result := 30;

  // First of all, dispose of fixed-length 29 day months
  if (Month = 2) or (Month = 4) or (Month = 6) or (Month = 10) or (Month = 13) then
  begin
    result := 29;
    exit;
  end;

  // If it's not a leap year, Adar has 29 days
  if (Month = 12) and not(HebrewDateLeap(Year)) then
  begin
    result := 29;
    exit;
  end;

  // If it's Heshvan, days depend on length of year
  if (Month = 8) and not(ModFloat(AmountOfDaysHebrewInYear(Year), 10) = 5) then
  begin
    result := 29;
    exit;
  end;

  // Similarly, Kislev varies with the length of year
  if (Month = 9) and (ModFloat(AmountOfDaysHebrewInYear(Year), 10) = 3) then
    result := 29;

end;

// Finally, wrap it all up into...
function HebrewDateToJulianDate(Year, Month, Day: integer): single;
var
  julianDay: single;
  Mon, months: integer;
begin

  months := AmountOfMonthsInHebrewYear(Year);
  julianDay := HEBREW_EPOCH + hebrew_delay_1(Year) + hebrew_delay_2(Year) + Day + 1;

  if (Month < 7) then
  begin
    for Mon := 7 to months do
      julianDay := julianDay + AmountOfDaysFromHebrewDate(Year, Mon);

    for Mon := 1 to Month - 1 do
      julianDay := julianDay + AmountOfDaysFromHebrewDate(Year, Mon);

  end
  else
  begin
    for Mon := 7 to Month - 1 do
      julianDay := julianDay + AmountOfDaysFromHebrewDate(Year, Mon);

  end;

  result := julianDay;
end;

// How many days are in a Hebrew year ?
function AmountOfDaysHebrewInYear(Year: integer): single;
begin
  result := HebrewDateToJulianDate(Year + 1, 7, 1) - HebrewDateToJulianDate(Year, 7, 1);
end;

// GREGORIAN_TO_JD  --  Determine Julian day number from Gregorian calendar date
function GregorarianToJulianDate(Year, Month, Day: integer): single;
var
  ifix: integer;
  gjd, fix: single;
begin

  gjd := (GREGORIAN_EPOCH - 1) + (365 * (Year - 1)) + Floor((Year - 1) / 4) + (-Floor((Year - 1) / 100)) + Floor((Year - 1) / 400);

  fix := ((367 * Month) - 362) / 12;

  // O_o
  ifix := 0;
  if Month > 2 then
  begin
    if LeapGregorianDate(Year) then
      ifix := -1
    else
      ifix := -2;
  end;

  result := gjd + (Floor(fix + ifix) + Day);
end;

// JD_TO_GREGORIAN  --  Calculate Gregorian calendar date from Julian day
function JulianDateToGregorianDate(julianDay: single): TYearMonthDay;
var
  dqc, wjd, depoch, dcent, dquad, dyindex, yearday, leapadj: single;
  Month, Day, Year, quadricent, quad, cent, yindex: integer;
begin

  wjd := Floor(julianDay - 0.5) + 0.5;
  depoch := wjd - GREGORIAN_EPOCH;
  quadricent := Floor(depoch / 146097);
  dqc := ModFloat(depoch, 146097);
  cent := Floor(dqc / 36524);
  dcent := ModFloat(dqc, 36524);
  quad := Floor(dcent / 1461);
  dquad := ModFloat(dcent, 1461);
  yindex := Floor(dquad / 365);
  Year := (quadricent * 400) + (cent * 100) + (quad * 4) + yindex;

  if (not((cent = 4) or (yindex = 4))) then
    inc(Year);

  yearday := wjd - GregorarianToJulianDate(Year, 1, 1);

  // leapadj := ((wjd < gregorian_to_jd(year, 3, 1))? 0: (leap_gregorian(year)? 1: 2));
  if wjd < GregorarianToJulianDate(Year, 3, 1) then
    leapadj := 0
  else if LeapGregorianDate(Year) then
    leapadj := 1
  else
    leapadj := 2;

  Month := Floor((((yearday + leapadj) * 12) + 373) / 367);
  Day := Round((wjd - GregorarianToJulianDate(Year, Month, 1)) + 1);

  result.Year := Year;
  result.Month := Month;
  result.Day := Day;
end;

// ISO_TO_JULIAN  --  Return Julian day of given ISO year, week, and day
function JulianDayFromISOYear(weekday: integer; julianDay: single; nthWeek: integer): single;
var
  j: single;
begin
  j := 7 * nthWeek;

  if (nthweek > 0) then
    j := j + PreviousJulianWeekday(weekday, julianDay)
  else
    j := NextJulianWeekday(weekday, julianDay);

  result := j;
end;

function ISODateToJulianDate(Year, Week, Day: integer): single;
begin
  result := Day + JulianDayFromISOYear(0, GregorarianToJulianDate(Year - 1, 12, 28), Week);
end;

// JD_TO_ISO  --  Return array of ISO (year, week, day) for Julian day
function JulianDateToISODate(julianDay: single): TYearMonthDay;
var
  Year, Week, Day: integer;
begin

  Year := JulianDateToGregorianDate(julianDay - 3).Year;
  if (julianDay >= ISODateToJulianDate(Year + 1, 1, 1)) then
    inc(Year);

  Week := Floor((julianDay - ISODateToJulianDate(Year, 1, 1)) / 7) + 1;
  Day := DayOfWeekFromJulianDay(julianDay);
  if (Day = 0) then
    Day := 7;

  result.Year := Year;
  result.Week := Week;
  result.Day := Day;

end;

// ISO_DAY_TO_JULIAN  --  Return Julian day of given ISO year, and day of year
function ISODayToJulianDay(Year, Day: integer): single;
begin
  result := (Day - 1) + GregorarianToJulianDate(Year, 1, 1);
end;

// JD_TO_ISO_DAY  --  Return array of ISO (year, day_of_year) for Julian day
function JulianDayToISODate(jd: single): TYearMonthDay;
var
  Year, Day: integer;
begin
  Year := JulianDateToGregorianDate(jd).Year;
  Day := Floor(jd - GregorarianToJulianDate(Year, 1, 1)) + 1;
  result.Year := Year;
  result.Day := Day;
end;

// PAD  --  Pad a string to a given length with a given fill character.  */
function PadString(str: string; howlong: integer; padwith: string): string;
var
  s: string;
begin
  while (s.Length < howlong) do
    s := padwith + s;

  result := s;
end;

// JULIAN_TO_JD  --  Determine Julian day number from Julian calendar date
function JulianDayFromJulianYear(Year: integer): boolean;
begin
  result := (Year mod 4) = (IfThen(Year > 0, 0, 3));
end;

function JulianDateToJulianFloat(Year, Month, Day: integer): single;
begin
  // * Adjust negative common era years to the zero-based notation we use.  */
  if (Year < 1) then
    inc(Year);

  // * Algorithm as given in Meeus, Astronomical Algorithms, Chapter 7, page 61 */
  if (Month <= 2) then
  begin
    dec(Year);
    Month := Month + 12;
  end;

  result := ((Floor((365.25 * (Year + 4716))) + Floor((30.6001 * (Month + 1))) + Day) - 1524.5);
end;

// JD_TO_JULIAN  --  Calculate Julian calendar date from Julian day
function JulianFloatToJulianDate(julianFloat: single): TYearMonthDay;
var
  z, a, alpha, b, c, D, e, Year, Month, Day: integer;
begin

  julianFloat := julianFloat + 0.5;
  z := Floor(julianFloat);

  a := z;
  b := a + 1524;
  c := Floor((b - 122.1) / 365.25);
  D := Floor(365.25 * c);
  e := Floor((b - D) / 30.6001);

  Month := Floor(IfThen(e < 14, e - 1, e - 13));
  Year := Floor(IfThen(Month > 2, c - 4716, c - 4715));
  Day := b - D - Floor(30.6001 * e);

  (* If year is less than 1, subtract one to convert from
    a zero based date system to the common era system in
    which the year -1 (1 B.C.E) is followed by year 1 (1 C.E.). *)

  if (Year < 1) then
    dec(Year);
  result.Year := Year;
  result.Month := Month;
  result.Day := Day;

end;

function JulianDateToHebrewDate(julianFloat: single): TYearMonthDay;
var
  first, count, Year, Month, Day, i: integer;
  njd: single;
  test: boolean;
begin
  count := Floor(((julianFloat - HEBREW_EPOCH) * 98496.0) / 35975351.0);
  Year := count - 1;

  i := count;

  test := julianFloat >= HebrewDateToJulianDate(i, 7, 1);

  while (test) do
  begin
    inc(i);
    inc(Year);
    test := julianFloat >= HebrewDateToJulianDate(i, 7, 1);
  end;

  first := 1;
  if (julianFloat < HebrewDateToJulianDate(Year, 1, 1)) then
    first := 7;

  Month := first;
  i := first;

  repeat
    inc(i);
    inc(Month);
  until (julianFloat <= HebrewDateToJulianDate(Year, i, AmountOfDaysFromHebrewDate(Year, i)));

  Day := Round(julianFloat - HebrewDateToJulianDate(Year, Month, 1)) + 1;

  result.Year := Year;
  result.Month := Month;
  result.Day := Day;
  result.HebrewMonth := HebrewMonth[Month - 1];
  result.HebrewMonthName := HebrewMonthName[Month - 1];
  result.FullDate := Format('%d, %s %d', [result.Day, result.HebrewMonthName, result.Year]);
end;

function DateToHebrew(Year, Month, Day: integer): TYearMonthDay;
var
  Hour, Min, Sec: word;
  j: single;
begin
  // default for error
  result.Year := 0;
  result.Month := 0;
  result.Day := 0;
  Hour := 0;
  Min := 0;
  Sec := 0;
  if (Day < 1) or (Day > 31) then
    exit;
  if (Month < 1) or (Month > 12) then
    exit;
  // Year, you take care of it.
  j := GregorarianToJulianDate(Round(Year), Round(Month), Round(Day)) + ((Sec + 60 * (Min + 60 * Hour) + 0.5) / 86400.0);

  result := JulianDateToHebrewDate(j);
end;

// Return Hebrew date
function DateTimeToHebrew(DateTime: TDateTime; ZeroHour: boolean = true): TYearMonthDay;
var
  Year, Month, Day, leap, Hour, Min, Sec, MSec: word;
  julianFloat: single;
begin
  DecodeDate(DateTime, Year, Month, Day);

  if ZeroHour then
  begin
    Hour := 0;
    Min := 0;
    Sec := 0;
  end
  else
  begin
    DecodeTime(DateTime, Hour, Min, Sec, MSec);
  end;

  julianFloat := GregorarianToJulianDate(Round(Year), Round(Month + 1), Round(Day)) + ((Sec + 60 * (Min + 60 * Hour) + 0.5) / 86400.0);

  result := JulianDateToHebrewDate(julianFloat);
end;

end.
