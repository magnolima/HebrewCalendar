(*
  Original javaScript functions for positional astronomy
  by John Walker -- September, MIM
  http://www.fourmilab.ch/
  This program is in the public domain.

  Conversion to Delphi: Magno Lima 2018/5778

*)
unit AstronomicalCalc;

interface

uses System.Math;

const
  J2000 = 2451545.0; // Julian day of J2000 epoch
  JulianCentury = 36525.0; // Days in Julian century
  JulianMillennium = (JulianCentury * 10); // Days in Julian millennium
  AstronomicalUnit = 149597870.0; // Astronomical unit in kilometres
  TropicalYear = 365.24219878; // Mean solar tropical year

type
  TArrayOfFloat = array of Double;

var
  // -> unused here --> Weekdays: array of string = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  oterms: array of single = [-4680.93, -1.55, 1999.25, -51.38, -249.67, -39.05, 7.12, 27.87, 5.79, 2.45];

  // * Periodic terms for nutation in longiude (delta \Psi) and
  // obliquity(delta \ Epsilon) as given in table 21. a of Meeus, " Astronomical Algorithms ", first edition. * /

  nutArgMult: array of integer = [0, 0, 0, 0, 1, -2, 0, 0, 2, 2, 0, 0, 0, 2, 2, 0, 0, 0, 0, 2, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, -2, 1, 0, 2, 2,
    0, 0, 0, 2, 1, 0, 0, 1, 2, 2, -2, -1, 0, 2, 2, -2, 0, 1, 0, 0, -2, 0, 0, 2, 1, 0, 0, -1, 2, 2, 2, 0, 0, 0, 0, 0, 0, 1, 0, 1, 2, 0, -1,
    2, 2, 0, 0, -1, 0, 1, 0, 0, 1, 2, 1, -2, 0, 2, 0, 0, 0, 0, -2, 2, 1, 2, 0, 0, 2, 2, 0, 0, 2, 2, 2, 0, 0, 2, 0, 0, -2, 0, 1, 2, 2, 0, 0,
    0, 2, 0, -2, 0, 0, 2, 0, 0, 0, -1, 2, 1, 0, 2, 0, 0, 0, 2, 0, -1, 0, 1, -2, 2, 0, 2, 2, 0, 1, 0, 0, 1, -2, 0, 1, 0, 1, 0, -1, 0, 0, 1,
    0, 0, 2, -2, 0, 2, 0, -1, 2, 1, 2, 0, 1, 2, 2, 0, 1, 0, 2, 2, -2, 1, 1, 0, 0, 0, -1, 0, 2, 2, 2, 0, 0, 2, 1, 2, 0, 1, 0, 0, -2, 0, 2, 2,
    2, -2, 0, 1, 2, 1, 2, 0, -2, 0, 1, 2, 0, 0, 0, 1, 0, -1, 1, 0, 0, -2, -1, 0, 2, 1, -2, 0, 0, 0, 1, 0, 0, 2, 2, 1, -2, 0, 2, 0, 1, -2, 1,
    0, 2, 1, 0, 0, 1, -2, 0, -1, 0, 1, 0, 0, -2, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 2, 0, -1, -1, 1, 0, 0, 0, 1, 1, 0, 0, 0, -1, 1, 2, 2,
    2, -1, -1, 2, 2, 0, 0, -2, 2, 2, 0, 0, 3, 2, 2, 2, -1, 0, 2, 2];

  nutArgCoeff: Array of integer = [-171996, -1742, 92095, 89, // *  0,  0,  0,  0,  1 */
  -13187, -16, 5736, -31, // * -2,  0,  0,  2,  2 */
  -2274, -2, 977, -5, // *  0,  0,  0,  2,  2 */
  2062, 2, -895, 5, // *  0,  0,  0,  0,  2 */
  1426, -34, 54, -1, // *  0,  1,  0,  0,  0 */
  712, 1, -7, 0, // *  0,  0,  1,  0,  0 */
  -517, 12, 224, -6, // * -2,  1,  0,  2,  2 */
  -386, -4, 200, 0, // *  0,  0,  0,  2,  1 */
  -301, 0, 129, -1, // *  0,  0,  1,  2,  2 */
  217, -5, -95, 3, // * -2, -1,  0,  2,  2 */
  -158, 0, 0, 0, // * -2,  0,  1,  0,  0 */
  129, 1, -70, 0, // * -2,  0,  0,  2,  1 */
  123, 0, -53, 0, // *  0,  0, -1,  2,  2 */
  63, 0, 0, 0, // *  2,  0,  0,  0,  0 */
  63, 1, -33, 0, // *  0,  0,  1,  0,  1 */
  -59, 0, 26, 0, // *  2,  0, -1,  2,  2 */
  -58, -1, 32, 0, // *  0,  0, -1,  0,  1 */
  -51, 0, 27, 0, // *  0,  0,  1,  2,  1 */
  48, 0, 0, 0, // * -2,  0,  2,  0,  0 */
  46, 0, -24, 0, // *  0,  0, -2,  2,  1 */
  -38, 0, 16, 0, // *  2,  0,  0,  2,  2 */
  -31, 0, 13, 0, // *  0,  0,  2,  2,  2 */
  29, 0, 0, 0, // *  0,  0,  2,  0,  0 */
  29, 0, -12, 0, // * -2,  0,  1,  2,  2 */
  26, 0, 0, 0, // *  0,  0,  0,  2,  0 */
  -22, 0, 0, 0, // * -2,  0,  0,  2,  0 */
  21, 0, -10, 0, // *  0,  0, -1,  2,  1 */
  17, -1, 0, 0, // *  0,  2,  0,  0,  0 */
  16, 0, -8, 0, // *  2,  0, -1,  0,  1 */
  -16, 1, 7, 0, // * -2,  2,  0,  2,  2 */
  -15, 0, 9, 0, // *  0,  1,  0,  0,  1 */
  -13, 0, 7, 0, // * -2,  0,  1,  0,  1 */
  -12, 0, 6, 0, // *  0, -1,  0,  0,  1 */
  11, 0, 0, 0, // *  0,  0,  2, -2,  0 */
  -10, 0, 5, 0, // *  2,  0, -1,  2,  1 */
  -8, 0, 3, 0, // *  2,  0,  1,  2,  2 */
  7, 0, -3, 0, // *  0,  1,  0,  2,  2 */
  -7, 0, 0, 0, // * -2,  1,  1,  0,  0 */
  -7, 0, 3, 0, // *  0, -1,  0,  2,  2 */
  -7, 0, 3, 0, // *  2,  0,  0,  2,  1 */
  6, 0, 0, 0, // *  2,  0,  1,  0,  0 */
  6, 0, -3, 0, // * -2,  0,  2,  2,  2 */
  6, 0, -3, 0, // * -2,  0,  1,  2,  1 */
  -6, 0, 3, 0, // *  2,  0, -2,  0,  1 */
  -6, 0, 3, 0, // *  2,  0,  0,  0,  1 */
  5, 0, 0, 0, // *  0, -1,  1,  0,  0 */
  -5, 0, 3, 0, // * -2, -1,  0,  2,  1 */
  -5, 0, 3, 0, // * -2,  0,  0,  0,  1 */
  -5, 0, 3, 0, // *  0,  0,  2,  2,  1 */
  4, 0, 0, 0, // * -2,  0,  2,  0,  1 */
  4, 0, 0, 0, // * -2,  1,  0,  2,  1 */
  4, 0, 0, 0, // *  0,  0,  1, -2,  0 */
  -4, 0, 0, 0, // * -1,  0,  1,  0,  0 */
  -4, 0, 0, 0, // * -2,  1,  0,  0,  0 */
  -4, 0, 0, 0, // *  1,  0,  0,  0,  0 */
  3, 0, 0, 0, // *  0,  0,  1,  2,  0 */
  -3, 0, 0, 0, // * -1, -1,  1,  0,  0 */
  -3, 0, 0, 0, // *  0,  1,  1,  0,  0 */
  -3, 0, 0, 0, // *  0, -1,  1,  2,  2 */
  -3, 0, 0, 0, // *  2, -1, -1,  2,  2 */
  -3, 0, 0, 0, // *  0,  0, -2,  2,  2 */
  -3, 0, 0, 0, // *  0,  0,  3,  2,  2 */
  -3, 0, 0, 0 // *  2, -1,  0,  2,  2 */
    ];

  // *  DELTAT  --  Determine the difference, in seconds, between Dynamical time and Universal time.
  // *  Table of observed Delta T values at the beginning of even numbered years from 1620 through 2002. * /
  deltaTtab: array of single = [121, 112, 103, 95, 88, 82, 77, 72, 68, 63, 60, 56, 53, 51, 48, 46, 44, 42, 40, 38, 35, 33, 31, 29, 26, 24,
    22, 20, 18, 16, 14, 12, 11, 10, 9, 8, 7, 7, 7, 7, 7, 7, 8, 8, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12,
    12, 12, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16, 15, 15, 14, 13, 13.1, 12.5, 12.2, 12, 12, 12,
    12, 12, 12, 11.9, 11.6, 11, 10.2, 9.2, 8.2, 7.1, 6.2, 5.6, 5.4, 5.3, 5.4, 5.6, 5.9, 6.2, 6.5, 6.8, 7.1, 7.3, 7.5, 7.6, 7.7, 7.3, 6.2,
    5.2, 2.7, 1.4, -1.2, -2.8, -3.8, -4.8, -5.5, -5.3, -5.6, -5.7, -5.9, -6, -6.3, -6.5, -6.2, -4.7, -2.8, -0.1, 2.6, 5.3, 7.7, 10.4, 13.3,
    16, 18.2, 20.2, 21.1, 22.4, 23.5, 23.8, 24.3, 24, 23.9, 23.9, 23.7, 24, 24.3, 25.3, 26.2, 27.3, 28.2, 29.1, 30, 30.7, 31.4, 32.2, 33.1,
    34, 35, 36.5, 38.3, 40.2, 42.2, 44.5, 46.5, 48.5, 50.5, 52.2, 53.8, 54.9, 55.8, 56.9, 58.3, 60, 61.6, 63, 65, 66.6];

  // Periodic terms to obtain true time
  EquinoxpTerms: array of single = [485, 324.96, 1934.136, 203, 337.23, 32964.467, 199, 342.08, 20.186, 182, 27.85, 445267.112, 156, 73.14,
    45036.886, 136, 171.52, 22518.443, 77, 222.54, 65928.934, 74, 296.72, 3034.906, 70, 243.58, 9037.513, 58, 119.81, 33718.147, 52, 297.17,
    150.678, 50, 21.02, 2281.226, 45, 247.54, 29929.562, 44, 325.15, 31555.956, 29, 60.93, 4443.417, 18, 155.12, 67555.328, 17, 288.79,
    4562.452, 16, 198.04, 62894.029, 14, 199.76, 31436.921, 12, 95.39, 14577.848, 12, 287.11, 31931.756, 12, 320.81, 34777.259, 9, 227.73,
    1222.114, 8, 15.45, 16859.074];

  JDE0tab1000: array [0 .. 3, 0 .. 4] of Double = ((1721139.29189, 365242.13740, 0.06134, 0.00111, -0.00071),
    (1721233.25401, 365241.72562, -0.05323, 0.00907, 0.00025), (1721325.70455, 365242.49558, -0.11677, -0.00297, 0.00074),
    (1721414.39987, 365242.88257, -0.00769, -0.00933, -0.00006));

  JDE0tab2000: array [0 .. 3, 0 .. 4] of Double = ((2451623.80984, 365242.37404, 0.05169, -0.00411, -0.00057),
    (2451716.56767, 365241.62603, 0.00325, 0.00888, -0.00030), (2451810.21715, 365242.01767, -0.11575, 0.00337, 0.00078),
    (2451900.05952, 365242.74049, -0.06223, -0.00823, 0.00032));

// *****************************************
// exposed functions
//
//
function jwday(j: single): integer;

// ****************************************
//
//

implementation

// *  ASTOR  --  Arc-seconds to radians.  */

function astor(a: single): single;
begin

  result := a * (Pi / (180.0 * 3600.0));
end;

// *  DTR  --  Degrees to radians.  */
function dtr(d: single): single;
begin
  result := DegToRad(d);
end;

// *  RTD  --  Radians to degrees.  */
function rtd(r: single): single;
begin
  result := (r * 180.0) / Pi;
end;

// *  FIXANGLE  --  Range reduce angle in degrees.  */
function fixangle(a: single): single;
begin
  result := a - 360.0 * (Floor(a / 360.0));
end;

// *  FIXANGR  --  Range reduce angle in radians.  */
function fixangr(a: single): single;
begin
  result := a - (2 * Pi) * (Floor(a / (2 * Pi)));
end;

// DSIN  --  Sine of an angle in degrees
function dsin(d: single): single;
begin
  result := Sin(DegToRad(d));
end;

// DCOS  --  Cosine of an angle in degrees
function dcos(d: single): single;
begin
  result := Cos(DegToRad(d));
end;

// *  MOD  --  Modulus function which works for non-integers.  */
function modulus(a, b: single): single;
begin
  result := a - (b * Floor(a / b));
end;

// AMOD  --  Modulus function which returns numerator if modulus is zero
function amod(a, b: single): single;
begin
  result := modulus(a - 1, b) + 1;
end;

// *  JHMS  --  Convert Julian time to hour, minutes, and seconds,
// returned as a three - element array. * /

function jhms(j: single): TArrayOfFloat;
var
  ij: single;
  aof: TArrayOfFloat;
begin

  j := j + 0.5; // * Astronomical to civil */
  ij := ((j - Floor(j)) * 86400.0) + 0.5;
  SetLength(aof, 3);
  aof[0] := Floor(ij / 3600);
  aof[1] := Floor((ij / 60)) mod 60;
  aof[2] := Floor(ij) mod 60;
  result := aof;
  // return new Array (Math.Floor(ij / 3600), Math.Floor((ij / 60)% 60), Math.Floor(ij % 60));

end;

// JWDAY  --  Calculate day of week from Julian day
function jwday(j: single): integer;
begin
  result := Floor((j + 1.5)) mod 7;
end;

(* OBLIQEQ  --  Calculate the obliquity of the ecliptic for a given
  Julian date.This uses Laskar 's tenth-degree polynomial fit(j.Laskar, Astronomy and Astrophysics, Vol.157, page 68[1986]) which is accurate to within 0.01 arc
  second between AD 1000 and AD 3000, and within a few seconds of arc for + /
  -10000 years around AD 2000. If we 're outside the range in which This fit is valid(deep time)we simply return the J2000 value of the obliquity, which happens
  to be almost precisely the mean. *)
function obliqeq(jd: single): single;
var
  eps, u, v: single;
  i: integer;
begin

  u := (jd - J2000) / (JulianCentury * 100);
  v := u;

  eps := 23 + (26 / 60.0) + (21.448 / 3600.0);

  if (Abs(u) < 1.0) then
  begin
    for i := 0 to 10 do
    begin
      eps := eps + (oterms[i] / 3600.0) * v;
      v := v * u;
    end;
  end;

  result := eps;
end;

// *  NUTATION  --  Calculate the nutation in longitude, deltaPsi, and obliquity, deltaEpsilon
// for a given Julian date jd.Results are returned as a two element Array giving(deltaPsi, deltaEpsilon) in degrees.
function nutation(jd: single): TArrayOfFloat;
var
  deltaPsi, deltaEpsilon, t, t2, t3, to10, ang, dp, de: single;
  i, j: integer;
  ta: array of single;
  delta: TArrayOfFloat;
begin

  t := (jd - 2451545.0) / 36525.0;
  dp := 0;
  de := 0;

  t2 := power(t, 2); // t * t; //
  t3 := t * t2;

  (* Calculate angles.  The correspondence between the elements
    of our array and the terms cited in Meeus are:

    ta[0] = D  ta[0] = M  ta[2] = M'  ta[3] = F  ta[4] = \Omega

  *)
  SetLength(ta, 5);
  ta[0] := dtr(297.850363 + 445267.11148 * t - 0.0019142 * t2 + t3 / 189474.0);
  ta[1] := dtr(357.52772 + 35999.05034 * t - 0.0001603 * t2 - t3 / 300000.0);
  ta[2] := dtr(134.96298 + 477198.867398 * t + 0.0086972 * t2 + t3 / 56250.0);
  ta[3] := dtr(93.27191 + 483202.017538 * t - 0.0036825 * t2 + t3 / 327270);
  ta[4] := dtr(125.04452 - 1934.136261 * t + 0.0020708 * t2 + t3 / 450000.0);

  // Range reduce the angles in case the sine and cosine functions don't do it as accurately or quickly.

  for i := 0 to 4 do
    ta[i] := fixangr(ta[i]);

  to10 := t / 10.0;
  for i := 0 to 62 do
  begin
    ang := 0;
    for j := 0 to 4 do
    begin
      if (nutArgMult[(i * 5) + j] <> 0) then
        ang := ang + nutArgMult[(i * 5) + j] * ta[j];
    end;
    dp := dp + (nutArgCoeff[(i * 4) + 0] + nutArgCoeff[(i * 4) + 1] * to10) * Sin(ang);
    de := de + (nutArgCoeff[(i * 4) + 2] + nutArgCoeff[(i * 4) + 3] * to10) * Cos(ang);

  end;

  // * Return the result, converting from ten thousandths of arc seconds to radians in the process. * /
  deltaPsi := dp / (3600.0 * 10000.0);
  deltaEpsilon := de / (3600.0 * 10000.0);

  SetLength(delta, 2);
  delta[0] := deltaPsi;
  delta[1] := deltaEpsilon;
  result := delta;
end;

(* ECLIPTOEQ  --  Convert celestial (ecliptical) longitude and
  latitude into right ascension(in degrees) and declination.we must supply the time of the conversion in order to compensate correctly
  for the varying obliquity of
  the ecliptic over time.the right ascension and declination are returned as a two - element Array in that order. *)

function ecliptoeq(jd, Lambda, Beta: single): TArrayOfFloat;
var
  eps, Ra, Dc: single;

begin

  // * Obliquity of the ecliptic. */
  eps := dtr(obliqeq(jd));
  // log += "Obliquity: " + rtd(eps) + "\n";

  // Ra := rtd(ArcTan2((Cos(eps) * Sin(dtr(Lambda)) - (Tan(dtr(Beta)) * Sin(eps))), Cos(dtr(Lambda))));

  // log += "RA = " + Ra + "\n";
  Ra := fixangle(rtd(ArcTan2((Cos(eps) * Sin(dtr(Lambda)) - (Tan(dtr(Beta)) * Sin(eps))), Cos(dtr(Lambda)))));
  Dc := rtd(ArcSin((Sin(eps) * Sin(dtr(Lambda)) * Cos(dtr(Beta))) + (Sin(dtr(Beta)) * Cos(eps))));
  SetLength(result, 2);
  result[0] := Ra;
  result[1] := Dc;

end;

function deltat(year: integer): single;
var
  i: integer;
  dt, f, t: single;
begin

  if ((year >= 1620) and (year <= 2000)) then
  begin
    i := Floor((year - 1620) / 2);
    f := ((year - 1620) / 2) - i; // * Fractional part of year */
    dt := deltaTtab[i] + ((deltaTtab[i + 1] - deltaTtab[i]) * f);
  end
  else
  begin
    t := (year - 2000) / 100;
    if (year < 948) then
    begin
      dt := 2177 + (497 * t) + (44.1 * t * t);
    end
    else
    begin
      dt := 102 + (102 * t) + (25.3 * t * t);
      if ((year > 2000) and (year < 2100)) then
      begin
        dt := dt + 0.37 * (year - 2100);
      end;
    end;
  end;
  result := dt;
end;

(* EQUINOX  --  Determine the Julian Ephemeris Day of an
  equinox or solstice.the " which " argument selects the item to be computed:
  0 March equinox 1 June solstice 2 September equinox 3 December solstice
*)
function equinox(year, which: integer): single;
var
  i, j: integer;
  s, deltaL, t, w, JDE0, JDE, Y: single;
  JDE0tab: array [0 .. 3, 0 .. 4] of Double;
begin

  // *  Initialise terms for mean equinox and solstices.  We have two sets:
  // one for years prior to 1000 and a second for subsequent years.

  if (year < 1000) then
  begin
    for i := 0 to 3 do
      for j := 0 to 4 do
        JDE0tab[i, j] := JDE0tab1000[i, j];

    Y := year / 1000;
  end
  else
  begin
    for i := 0 to 3 do
      for j := 0 to 4 do
        JDE0tab[i, j] := JDE0tab2000[i, j];
    Y := (year - 2000) / 1000;
  end;

  JDE0 := JDE0tab[which][0] + (JDE0tab[which][1] * Y) + (JDE0tab[which][2] * Y * Y) + (JDE0tab[which][3] * Y * Y * Y) +
    (JDE0tab[which][4] * Y * Y * Y * Y);

  // document.debug.log.value += "JDE0 = " + JDE0 + "\n";

  t := (JDE0 - 2451545.0) / 36525;
  // document.debug.log.value += "T = " + T + "\n";
  w := (35999.373 * t) - 2.47;
  // document.debug.log.value += "W = " + W + "\n";
  deltaL := 1 + (0.0334 * dcos(w)) + (0.0007 * dcos(2 * w));
  // document.debug.log.value += "deltaL = " + deltaL + "\n";

  // Sum the periodic terms for time T

  s := 0;
  j := 0;
  for i := 0 to 23 do
  begin
    s := s + EquinoxpTerms[j] * dcos(EquinoxpTerms[j + 1] + (EquinoxpTerms[j + 2] * t));
    j := j + 3;
  end;

  // document.debug.log.value += "S = " + S + "\n";
  // document.debug.log.value += "Corr = " + ((S * 0.00001) / deltaL) + "\n";

  JDE := JDE0 + ((s * 0.00001) / deltaL);

  result := JDE;
end;

// *  SUNPOS  --  Position of the Sun.  Please see the comments
// on the return statement at the end of This function which describe the array it returns.
// we return intermediate values because they are useful in a variety of other contexts.
function sunpos(jd: single): TArrayOfFloat;
var
  t, t2, L0, M, e, C, sunLong, sunAnomaly, sunR, Omega, Lambda, epsilon, epsilon0, Alpha, delta, AlphaApp, DeltaApp: single;
begin

  t := (jd - J2000) / JulianCentury;
  // document.debug.log.value += "Sunpos.  T = " + T + "\n";
  t2 := t * t;
  L0 := 280.46646 + (36000.76983 * t) + (0.0003032 * t2);
  // document.debug.log.value += "L0 = " + L0 + "\n";
  L0 := fixangle(L0);
  // document.debug.log.value += "L0 = " + L0 + "\n";
  M := 357.52911 + (35999.05029 * t) + (-0.0001537 * t2);
  // document.debug.log.value += "M = " + M + "\n";
  M := fixangle(M);
  // document.debug.log.value += "M = " + M + "\n";
  e := 0.016708634 + (-0.000042037 * t) + (-0.0000001267 * t2);
  // document.debug.log.value += "e = " + e + "\n";
  C := ((1.914602 + (-0.004817 * t) + (-0.000014 * t2)) * dsin(M)) + ((0.019993 - (0.000101 * t)) * dsin(2 * M)) + (0.000289 * dsin(3 * M));
  // document.debug.log.value += "C = " + C + "\n";
  sunLong := L0 + C;
  // document.debug.log.value += "sunLong = " + sunLong + "\n";
  sunAnomaly := M + C;
  // document.debug.log.value += "sunAnomaly = " + sunAnomaly + "\n";
  sunR := (1.000001018 * (1 - (e * e))) / (1 + (e * dcos(sunAnomaly)));
  // document.debug.log.value += "sunR = " + sunR + "\n";
  Omega := 125.04 - (1934.136 * t);
  // document.debug.log.value += "Omega = " + Omega + "\n";
  Lambda := sunLong + (-0.00569) + (-0.00478 * dsin(Omega));
  // document.debug.log.value += "Lambda = " + Lambda + "\n";
  epsilon0 := obliqeq(jd);
  // document.debug.log.value += "epsilon0 = " + epsilon0 + "\n";
  epsilon := epsilon0 + (0.00256 * dcos(Omega));
  // document.debug.log.value += "epsilon = " + epsilon + "\n";
  Alpha := rtd(ArcTan2(dcos(epsilon0) * dsin(sunLong), dcos(sunLong)));
  // document.debug.log.value += "Alpha = " + Alpha + "\n";
  Alpha := fixangle(Alpha);
  /// /document.debug.log.value += "Alpha = " + Alpha + "\n";
  delta := rtd(ArcSin(dsin(epsilon0) * dsin(sunLong)));
  /// /document.debug.log.value += "Delta = " + Delta + "\n";
  AlphaApp := rtd(ArcTan2(dcos(epsilon) * dsin(Lambda), dcos(Lambda)));
  // document.debug.log.value += "AlphaApp = " + AlphaApp + "\n";
  AlphaApp := fixangle(AlphaApp);
  // document.debug.log.value += "AlphaApp = " + AlphaApp + "\n";
  DeltaApp := rtd(ArcSin(dsin(epsilon) * dsin(Lambda)));
  // document.debug.log.value += "DeltaApp = " + DeltaApp + "\n";

  SetLength(result, 12);

  // Angular quantities are expressed in decimal degrees
  result[0] := L0; // [0] Geometric mean longitude of the Sun
  result[1] := M; // [1] Mean anomaly of the Sun
  result[2] := e; // [2] Eccentricity of the Earth's orbit
  result[3] := C; // [3] Sun's equation of the Centre
  result[4] := sunLong; // [4] Sun's true longitude
  result[5] := sunAnomaly; // [5] Sun's true anomaly
  result[6] := sunR; // [6] Sun's radius vector in AU
  result[7] := Lambda; // [7] Sun's apparent longitude at true equinox of the date
  result[8] := Alpha; // [8] Sun's true right ascension
  result[9] := delta; // [9] Sun's true declination
  result[10] := AlphaApp; // [10] Sun's apparent right ascension
  result[11] := DeltaApp; // [11] Sun's apparent declination

end;

// *  EQUATIONOFTIME  --  Compute equation of time for a given moment.
// returns the equation of time as a fraction of a day. * /
function equationOfTime(jd: single): single;
var
  Alpha, deltaPsi, e, epsilon, L0, tau: single;
begin

  tau := (jd - J2000) / JulianMillennium;
  // document.debug.log.value += "equationOfTime.  tau = " + tau + "\n";
  L0 := 280.4664567 + (360007.6982779 * tau) + (0.03032028 * tau * tau) + ((tau * tau * tau) / 49931) + (-((tau * tau * tau * tau) / 15300))
    + (-((tau * tau * tau * tau * tau) / 2000000));
  // document.debug.log.value += "L0 = " + L0 + "\n";
  L0 := fixangle(L0);
  // document.debug.log.value += "L0 = " + L0 + "\n";
  Alpha := sunpos(jd)[10];
  // document.debug.log.value += "alpha = " + alpha + "\n";
  deltaPsi := nutation(jd)[0];
  // document.debug.log.value += "deltaPsi = " + deltaPsi + "\n";
  epsilon := obliqeq(jd) + nutation(jd)[1];
  // document.debug.log.value += "epsilon = " + epsilon + "\n";
  e := L0 + (-0.0057183) + (-Alpha) + (deltaPsi * dcos(epsilon));
  // document.debug.log.value += "E = " + E + "\n";
  e := e - 20.0 * (Floor(e / 20.0));
  // document.debug.log.value += "Efixed = " + E + "\n";
  e := e / (24 * 60);
  // document.debug.log.value += "Eday = " + E + "\n";

  result := e;
end;

end.
