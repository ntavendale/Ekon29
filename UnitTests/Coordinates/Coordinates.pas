unit Coordinates;

interface

uses
  System.SysUtils, System.Math;

type
  PGeodeticCoordinates = ^TGeodeticCoordinates;
  PEcefCoordinates = ^TEcefCoordinates;

  TGeodeticCoordinates = record
    LatitudeDegrees: Double;
    LongitudeDegrees: Double;
    AltitudeMeters: Double;
    function LatitudeRadians: Double;
    function LongitudeRadians: Double;
    class function FromLlaDegrees(ALatitudeDegrees: Double; ALongitudeDegrees: Double; AAltitudeMeters: Double): TGeodeticCoordinates; static;
    class function FromLlaRadians(ALatitudeRadians: Double; ALongitudeRadians: Double; AAltitudeMeters: Double): TGeodeticCoordinates; static;
  end;

  TEcefCoordinates = record
    XMeters: Double;
    YMeters: Double;
    ZMeters: Double;
    class function Create(AXMeters: Double; AYMeters: Double; AZMeters: Double): TEcefCoordinates; static;
  end;

  TNEDCoordinates = record
    NorthMeters: Double;
    EastMeters: Double;
    DownMeters: Double;
    class function Create(ANorthMeters: Double; AEastMeters: Double; ADownMeters: Double): TNEDCoordinates; static;
  end;

  TRightAscension = record
    Hours: Double;
    Minutes: Double;
    Seconds: Double;
    class function Create(AHours: Double; Aminutes: Double; ASeconds: Double): TRightAscension; static;
  end;

  TDeclenation = record
    Degrees: Double;
    Minutes: Double;
    Seconds: Double;
    class function Create(ADegrees: Double; Aminutes: Double; ASeconds: Double): TDeclenation; static;
  end;

  TCelestiaCoordinates = record
    RightAscension: TRightAscension;
    Declenation: TDeclenation;
    class function Create(ARightAscension: TRightAscension; ADeclenation: TDeclenation): TCelestiaCoordinates; static;
  end;

implementation

// North Pole
const MAX_LATITUDE_DEGREES: DOUBLE  =  90.0;
// South Pole
const MIN_LATITUDE_DEGREES: DOUBLE  = -90.0;

// International Date Line
const MAX_LONGITUDE_DEGREES: DOUBLE =  180.0;
const MIN_LONGITUDE_DEGREES: DOUBLE = -180.0;

// Challenger Deep. Deepest point in the ocean at bottom of Mariana Trench.
const MIN_ALTITUDE: Double = 10920.0;

function GeodeticValuesWithingRange(ALatitudeDegrees: Double; ALongitudeDegrees: Double; AAltitudeMeters: Double): Boolean;
begin
  Result := InRange(ALatitudeDegrees, MIN_LATITUDE_DEGREES, MAX_LATITUDE_DEGREES) and
            InRange(ALongitudeDegrees, MIN_LONGITUDE_DEGREES, MAX_LONGITUDE_DEGREES) and
            (AAltitudeMeters > MIN_ALTITUDE);
end;

class function TGeodeticCoordinates.FromLlaDegrees(ALatitudeDegrees: Double; ALongitudeDegrees: Double; AAltitudeMeters: Double): TGeodeticCoordinates;
begin
  if GeodeticValuesWithingRange(ALatitudeDegrees, ALongitudeDegrees, AAltitudeMeters) then
    raise EArgumentException.Create(String.Format('Lat: %.3f, Long: %.3f, Alt: %.3f is invalid', [ALatitudeDegrees, ALongitudeDegrees, AAltitudeMeters]));

  Result.LatitudeDegrees := ALatitudeDegrees;
  Result.LongitudeDegrees := ALongitudeDegrees;
  Result.AltitudeMeters := AAltitudeMeters;
end;

class function TGeodeticCoordinates.FromLlaRadians(ALatitudeRadians: Double; ALongitudeRadians: Double; AAltitudeMeters: Double): TGeodeticCoordinates;
begin
  var LLatitudeDeg := RadToDeg(ALatitudeRadians);
  var LLongitudeDeg := RadToDeg(ALongitudeRadians);

  if GeodeticValuesWithingRange(LLatitudeDeg, LLongitudeDeg, AAltitudeMeters) then
    raise EArgumentException.Create(String.Format('Lat: %.3f, Long: %.3f, Alt: %.3f is invalid', [LLatitudeDeg, LLongitudeDeg, AAltitudeMeters]));

  Result.LatitudeDegrees := LLatitudeDeg;
  Result.LongitudeDegrees := LLongitudeDeg;
  Result.AltitudeMeters := AAltitudeMeters;
end;

function TGeodeticCoordinates.LatitudeRadians: Double;
begin
  Result := DegToRad(LatitudeDegrees);
end;

function TGeodeticCoordinates.LongitudeRadians: Double;
begin
  Result := DegToRad(LongitudeDegrees);
end;

class function TEcefCoordinates.Create(AXMeters: Double; AYMeters: Double; AZMeters: Double): TEcefCoordinates;
begin
  Result.XMeters := AXMeters;
  Result.YMeters := AYMeters;
  Result.ZMeters := AZMeters;
end;

class function TNEDCoordinates.Create(ANorthMeters: Double; AEastMeters: Double; ADownMeters: Double): TNEDCoordinates;
begin
  Result.NorthMeters := ANorthMeters;
  Result.EastMeters := AEastMeters;
  Result.DownMeters := ADownMeters;
end;

class function TRightAscension.Create(AHours: Double; Aminutes: Double; ASeconds: Double): TRightAscension;
begin
  Result.Hours := AHours;
  Result.Minutes := AMinutes;
  Result.Seconds := ASeconds;
end;

class function TDeclenation.Create(ADegrees: Double; AMinutes: Double; ASeconds: Double): TDeclenation;
begin
  Result.Degrees := ADegrees;
  Result.Minutes := AMinutes;
  Result.Seconds := ASeconds;
end;

class function TCelestiaCoordinates.Create(ARightAscension: TRightAscension; ADeclenation: TDeclenation): TCelestiaCoordinates;
begin
  Result.RightAscension := ARightAscension;
  Result.Declenation := ADeclenation;
end;

end.
