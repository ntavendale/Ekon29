unit DataProvider.EcefToLla;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.Rtti,
  System.IOUtils, System.Json, Rest.Json, DUnitX.Types, DUnitX.Attributes,
  DUnitX.TestDataProvider, DUnitX.TestFramework, DUnitX.InternalDataProvider,
  Coordinates, Attributes.Range;

const
  TOLERANCE: Double = 1.0E-2;

type
  TSampleState = record
    Lla: TGeodeticCoordinates;
    Ecef: TEcefCoordinates;
    class function Create(ALla: TGeodeticCoordinates; AEcef: TEcefCoordinates): TSampleState; static;
    class function FromJsonObject(AJsonObject: TJsonObject): TSampleState; static;
  end;
  TEcefToLlaDataProvider = class(TTestDataProvider)
  private
    FGUIDString: String;
    FStates: TList<TSampleState>;
    procedure InitFromFile(AFileNme: String);
    procedure InitStates;
  public
    constructor Create; override;
    destructor Destroy; override;
    function GetCaseCount(const MethodName: string): Integer; override;
    function GetCaseName(const MethodName: String; const CaseNumber : Integer): String; override;
    function GetCaseParams(const MethodName: string; const CaseNumber : Integer): TValueArray; override;
  end;

implementation

class function TSampleState.Create(ALla: TGeodeticCoordinates; AEcef: TEcefCoordinates): TSampleState;
begin
  Result.Lla := ALla;
  Result.Ecef := AEcef;
end;

class function TSampleState.FromJsonObject(AJsonObject: TJsonObject): TSampleState;
begin
  var Lla := AJsonObject.Values['Lla'] as TJsonObject;
  Result.Lla.LatitudeDegrees := Lla.Values['LatitudeDegrees'].AsType<Double>;
  Result.Lla.LongitudeDegrees := Lla.Values['LongitudeDegrees'].AsType<Double>;
  Result.Lla.AltitudeMeters := Lla.Values['AltitudeMeters'].AsType<Double>;

  var Ecef := AJsonObject.Values['Ecef'] as TJsonObject;
  Result.Ecef.XMeters := Ecef.Values['XMeters'].AsType<Double>;
  Result.Ecef.YMeters := Ecef.Values['YMeters'].AsType<Double>;
  Result.Ecef.ZMeters := Ecef.Values['ZMeters'].AsType<Double>;
end;

constructor TEcefToLlaDataProvider.Create;
var
  LGUID: TGUID;
begin
  CreateGUID(LGUID);
  // Convert the TGUID to a string
  FGUIDString := GUIDToString(LGUID);
  FStates := TList<TSampleState>.Create;
  InitFromFile('C:\Development\Ekon29\JsonData\TSampleState.json');
  //InitStates;
end;

destructor TEcefToLlaDataProvider.Destroy;
begin
  FStates.Free;
end;

procedure TEcefToLlaDataProvider.InitFromFile(AFileNme: String);
begin
  var LJsonString := TFile.ReadAllText(AFileNme); //TFile.ReadAllText('C:\Development\Ekon29\JsonData\TSampleState.json');
  var LArray := TJsonObject.ParseJSONValue(LJsonString) as TJsonArray;
  if nil <> LArray then
  begin
    try
      for var LObject in LArray do
        FStates.Add(TSampleState.FromJsonObject(LObject as TJsonObject));
    finally
      LArray.Free;
    end;
  end;
end;

procedure TEcefToLlaDataProvider.InitStates;
begin
  FStates.Add(TSampleState.Create(
    TGeodeticCoordinates.FromLlaDegrees(34.0522, -118.2437, 100.00000000031852),
    TEcefCoordinates.Create(-2503396.5198597223,-4660276.422746513,3551301.3540872796)
  ));
  FStates.Add(TSampleState.Create(
    TGeodeticCoordinates.FromLlaDegrees(42.051, -105.24, 1526.999999999722),
    TEcefCoordinates.Create(-1247110.7388627927, -4577497.307185983, 4250834.659784284)
  ));
end;

function TEcefToLlaDataProvider.GetCaseCount(const MethodName: string): Integer;
begin
  Result := FStates.Count;
end;

function TEcefToLlaDataProvider.GetCaseName(const MethodName: String; const CaseNumber : Integer): String;
begin
  if (MethodName = 'ToLla') then
    Result := 'Ecef To Lla'
  else if (MethodName = 'ToEcef') then
    Result := 'Lla To Ecef';
end;

function TEcefToLlaDataProvider.GetCaseParams(const MethodName: string; const CaseNumber : Integer): TValueArray;
begin
  var LTemp: Integer := 0;
  SetLength(Result, 0);
  if (CaseNumber >=0) and (CaseNumber < FStates.Count) then
  begin
    if (MethodName = 'ToLla') then
    begin
      SetLength(Result, 5);
      Result[0] := TValue.From<TEcefCoordinates>(FStates[CaseNumber].Ecef);
      Result[1] := TValue.From<TGeodeticCoordinates>(FStates[CaseNumber].Lla);
      Result[2] := TOLERANCE;
      Result[3] := FGUIDString;
    end
    else if (MethodName = 'ToEcef') then
    begin
      SetLength(Result, 5);
      Result[0] := TValue.From<TGeodeticCoordinates>(FStates[CaseNumber].Lla);
      Result[1] := TValue.From<TEcefCoordinates>(FStates[CaseNumber].Ecef);
      Result[2] := TOLERANCE;
      Result[3] := FGUIDString;
    end;
  end;
end;

end.
