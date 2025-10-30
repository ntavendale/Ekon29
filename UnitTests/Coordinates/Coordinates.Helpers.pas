unit Coordinates.Helpers;

interface

uses
  System.SysUtils, System.DateUtils, System.Classes, System.Math, Coordinates, Matrix;

type
  TEcefCoordinatesHelper = record helper for TEcefCoordinates
    function ToGeodeticCoordinates: TGeodeticCoordinates;
    function ToNEDCoordinates(AObservationPoint: TGeodeticCoordinates): TNEDCoordinates;
    function DistanceTo(ADestination: TEcefCoordinates): Double;
  end;

  TGeodeticCoordinatesHelper = record helper for TGeodeticCoordinates
    function ToEcefCoordinates: TEcefCoordinates;
    function AltitudeFeet: Double; // Military & civil aviation still use feet
  end;

  TRightAscensionHelper = record helper for TRightAscension
    function TotalDgrees: Double;
  end;

  TDeclenationHelper = record helper for TDeclenation
    function TotalDgrees: Double;
  end;

function MetersPerSecondToFeetPerSecond(AMetersPerSecond: Double): Double;
function FeetPerSecondToMetersPerSecond(AFeetPerSecond: Double): Double;
function MetersPerSecondToMilesPerHour(AMetersPerSecond: Double): Double;
function MilesPerHourToMetersPerSecond(AMilesPerHour: Double): Double;
function MetersPerSecondToKnots(AMetersPerSecond: Double): Double;
function KnotsToMetersPerSecond(AKnots: Double): Double;
function GetGlobalHourAngle(ADataTime: TDateTime; ATimeIsUTC: Boolean = FALSE): Double;

implementation

const
  EARTH_EQUATORIAL_RADIUS_METERS: Double = 6378137.0;
  EARTH_POLAR_RADIUS_METERS: Double = 6356752.3142;
  EARTH_ECCENTRICITY_SQUARED: Double = 6.69437999014E-3;
  SECOND_ECCENTRICITY_SQUARED: Double = 6.73949674228E-3;
  METERS_PER_FOOT: Double = 0.3048; // US International Foot (US Survey Fooot should now be obsolete).
  FEET_PER_MILE: Double = 5280;
  METERS_PER_NAUTICAL_MILE: Double = 1852;
  SECONDS_PER_HOUR: Double = 3600;
  RA_DEGREES_PER_HOUR: DOUBLE = 15.0;


// In Delphi, the standard Power function (from the Math unit) does not produce
// a real-valued result for a negative base raised to a fractional exponent,
// because it is designed to find the principal root in the complex number domain.
// To find the real-valued cube root of a negative number, we must account for
// the negative sign manually.
function RealCubeRoot(X: Extended): Extended;
begin
  if X >= 0 then
    Result := Power(X, 1.0 / 3.0)
  else
    Result := -Power(Abs(X), 1.0 / 3.0);
end;

function MetersPerSecondToFeetPerSecond(AMetersPerSecond: Double): Double;
begin
  Result := AMetersPerSecond / METERS_PER_FOOT;
end;

function FeetPerSecondToMetersPerSecond(AFeetPerSecond: Double): Double;
begin
  Result := AFeetPerSecond * METERS_PER_FOOT;
end;

function MetersPerSecondToMilesPerHour(AMetersPerSecond: Double): Double;
begin
  Result := (AMetersPerSecond / METERS_PER_FOOT) / FEET_PER_MILE * SECONDS_PER_HOUR;
end;

function MilesPerHourToMetersPerSecond(AMilesPerHour: Double): Double;
begin
  Result := AMilesPerHour/SECONDS_PER_HOUR * FEET_PER_MILE * METERS_PER_FOOT ;
end;

function MetersPerSecondToKnots(AMetersPerSecond: Double): Double;
begin
  Result := AMetersPerSecond / METERS_PER_NAUTICAL_MILE  * SECONDS_PER_HOUR;
end;

function KnotsToMetersPerSecond(AKnots: Double): Double;
begin
  Result := AKnots/SECONDS_PER_HOUR * METERS_PER_NAUTICAL_MILE;
end;

function GetGlobalHourAngle(ADataTime: TDateTime; ATimeIsUTC: Boolean = FALSE): Double;
begin
  var LUTCTime := if ATimeIsUTC then ADataTime else TTimeZone.Local.ToUniversalTime(ADataTime);
  var LYear, LMonth, LDay, LHour, LMinute, LSecond, LMilliSecond: Word;
  DecodeDateTime(LUTCTime, LYear, LMonth, LDay, LHour, LMinute, LSecond, LMilliSecond);
  // 15/60 = 1/4
  var LArc := (LHour * 15) + (LMinute / 4) + (LSecond / 240);
  if LArc = 180 then
    Result := LArc
  else
    Result := if (LArc < 180) then LArc + 180 else LArc - 180;
end;

function GetDirectionCosineMatrix(ALatitudeRadians: Double; ALongitudeRadians: Double): IMatrix;
begin
  Result := TDoubleMatrix.Create(3,3);
  Result.SetRow(0,[-sin(ALatitudeRadians)*cos(ALongitudeRadians), -sin(ALatitudeRadians)*sin(ALongitudeRadians),  cos(ALatitudeRadians)]);
  Result.SetRow(1,[-sin(ALongitudeRadians),                        cos(ALongitudeRadians),                        0.0                  ]);
  Result.SetRow(2,[-cos(ALatitudeRadians)*cos(ALongitudeRadians), -cos(ALatitudeRadians)*sin(ALongitudeRadians), -sin(ALatitudeRadians)]);
end;

// Use Ferrari-based algorithm described by Zhu and Heikkinen.
// Closed form and more precise.
function TEcefCoordinatesHelper.ToGeodeticCoordinates: TGeodeticCoordinates;
var
  f, g, c, s, p, q, r0, u, v, z0: Double;
begin
  var LEquatorialHypotenuse := Sqrt(Self.XMeters*Self.XMeters + Self.YMeters*Self.YMeters);  // distance from Z-axis

  f := 54.0 * EARTH_POLAR_RADIUS_METERS * EARTH_POLAR_RADIUS_METERS * Self.ZMeters * Self.ZMeters;
  g := LEquatorialHypotenuse*LEquatorialHypotenuse +
       (1 - EARTH_ECCENTRICITY_SQUARED) * Self.ZMeters * Self.ZMeters -
       EARTH_ECCENTRICITY_SQUARED * (EARTH_EQUATORIAL_RADIUS_METERS*EARTH_EQUATORIAL_RADIUS_METERS - EARTH_POLAR_RADIUS_METERS*EARTH_POLAR_RADIUS_METERS);
  c := EARTH_ECCENTRICITY_SQUARED * EARTH_ECCENTRICITY_SQUARED * f * LEquatorialHypotenuse*LEquatorialHypotenuse / (g*g*g);

  var int1: Double := Sqrt(c*(c+2));
  var int2: Double := (1 + c + int1);
  s := RealCubeRoot(int2);
  p := f / (3 * Power((s + 1/s + 1), 2) * g*g);
  q := Sqrt(1 + 2 * EARTH_ECCENTRICITY_SQUARED * EARTH_ECCENTRICITY_SQUARED * p);

  r0 := -(p * EARTH_ECCENTRICITY_SQUARED * LEquatorialHypotenuse) / (1 + q) +
        Sqrt(0.5 * EARTH_EQUATORIAL_RADIUS_METERS * EARTH_EQUATORIAL_RADIUS_METERS * (1 + 1/q) -
             p*(1 - EARTH_ECCENTRICITY_SQUARED) * Self.ZMeters * Self.ZMeters / (q * (1 + q)) -
             0.5 * p * LEquatorialHypotenuse * LEquatorialHypotenuse);

  u := Sqrt(Sqr(LEquatorialHypotenuse - EARTH_ECCENTRICITY_SQUARED * r0) + Self.ZMeters*Self.ZMeters);
  v := Sqrt(Sqr(LEquatorialHypotenuse - EARTH_ECCENTRICITY_SQUARED * r0) + (1 - EARTH_ECCENTRICITY_SQUARED) * Self.ZMeters*Self.ZMeters);
  z0 := EARTH_POLAR_RADIUS_METERS * EARTH_POLAR_RADIUS_METERS * Self.ZMeters / (EARTH_EQUATORIAL_RADIUS_METERS * v);

  Result.AltitudeMeters := u * (1 - EARTH_POLAR_RADIUS_METERS * EARTH_POLAR_RADIUS_METERS / (EARTH_EQUATORIAL_RADIUS_METERS * v));
  var LLatitudeRadians := ArcTan((Self.ZMeters + SECOND_ECCENTRICITY_SQUARED * z0) / LEquatorialHypotenuse);
  var LLongitudeRadians := ArcTan2(Self.YMeters, Self.XMeters);

  Result.LatitudeDegrees := RadToDeg(LLatitudeRadians);
  Result.LongitudeDegrees := RadToDeg(LLongitudeRadians);
end;

function TEcefCoordinatesHelper.ToNEDCoordinates(AObservationPoint: TGeodeticCoordinates): TNEDCoordinates;
begin
  var LReferenceEcef := AObservationPoint.ToEcefCoordinates;
  var LDCM := GetDirectionCosineMatrix(AObservationPoint.LatitudeRadians, AObservationPoint.LongitudeRadians);

  var LECEFMatrix: IMatrix := TDoubleMatrix.Create(1, 3); //Colums, Rows
  LECEFMatrix.SetColumn(0, [(Self.XMeters - LReferenceEcef.XMeters),
                            (Self.YMeters - LReferenceEcef.YMeters),
                            (Self.ZMeters - LReferenceEcef.ZMeters)]);

  var LNEDMatrix: IMatrix := LDCM.Mult(LECEFMatrix);
  if (1 <> LNEDMatrix.Width) or (3 <> LNEDMatrix.Height) then
    raise Exception.Create(String.Format('NED Matrix size (%d x %d) is invalid!', [LNEDMatrix.Height, LNEDMatrix.Width]));

  Result := TNEDCoordinates.Create(LNEDMatrix.Items[0,0], LNEDMatrix.Items[0,1], LNEDMatrix.Items[0,2]);
end;

function TEcefCoordinatesHelper.DistanceTo(ADestination: TEcefCoordinates): Double;
begin
  var xDiff := ADestination.XMeters - Self.XMeters;
  var yDiff := ADestination.YMeters - Self.YMeters;
  var zDiff := ADestination.ZMeters - Self.ZMeters;
  Result := Sqrt((xDiff * xDiff) + (yDiff * yDiff) + (zDiff * zDiff));
end;

function TGeodeticCoordinatesHelper.ToEcefCoordinates: TEcefCoordinates;
begin
  var LLatitudeRadians := Self.LatitudeRadians;
  var LLongitudeRadians := Self.LongitudeRadians;

  // Earth is an eplipsoid, not a sphere so, depending on the latitude, we need
  // to adjust the height since the distance of sea level from center of earth
  // varies with latitude.
  var LPrimeVerticalRadius: Double :=  EARTH_EQUATORIAL_RADIUS_METERS / Sqrt( 1.0 - EARTH_ECCENTRICITY_SQUARED * Sqr(Sin(LLatitudeRadians)));
  var LAdjustedHeight: Double := LPrimeVerticalRadius + Self.AltitudeMeters;

  var LXMeters: Double := LAdjustedHeight * Cos(LLatitudeRadians) * Cos(LLongitudeRadians);
  var LYMeters: Double := LAdjustedHeight * Cos(LLatitudeRadians) * Sin(LLongitudeRadians);
  var LZMeters: Double := ((1.0 - EARTH_ECCENTRICITY_SQUARED) * LPrimeVerticalRadius + Self.AltitudeMeters) * Sin(LLatitudeRadians);

  Result := TEcefCoordinates.Create(LXMeters, LYMeters, LZMeters);
end;

function TGeodeticCoordinatesHelper.AltitudeFeet: Double;
begin
  Result := Self.AltitudeMeters / METERS_PER_FOOT;
end;

function TRightAscensionHelper.TotalDgrees: Double;
begin
  Result := (Self.Hours * RA_DEGREES_PER_HOUR) +
            (Self.Minutes * RA_DEGREES_PER_HOUR/60) +
            (Self.Seconds * RA_DEGREES_PER_HOUR/3600);
end;

function TDeclenationHelper.TotalDgrees: Double;
begin
  Result := Self.Degrees + (Self.Minutes / 60) + (Self.Seconds / 3600);
end;

end.
