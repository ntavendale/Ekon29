unit Attributes.Range;

interface

uses
  System.SysUtils, System.Classes, DUnitX.Attributes, System.Rtti, Coordinates;

type
  TValueRange = record
    Start: Double;
    Stop: Double;
    Step: Double;
    class function Create(AStart: Double; AStop: Double; AStep: Double): TValueRange; static;
  end;

  TEcefTestData = record
    XMeters: Double;
    YMeters: Double;
    ZMeters: Double;
    class function Create(AXMeters: Double; AYMeters: Double; AZMeters: Double): TEcefTestData; static;
  end;

  TTestCaseRangeAttribute = class(CustomTestCaseSourceAttribute)
  private
    FTestCaseInfo: TestCaseInfoArray;
    FCaseName: String;
    FRangeX: TValueRange;
    FRangeY: TValueRange;
    FRangeZ: TValueRange;
    procedure ValidateRanges;
    procedure AddSequentially;
  protected
    function GetCaseInfoArray: TestCaseInfoArray; override;
  public
    constructor Create(const ACaseName : string; const ARanges: String; const ARangeSeparator: string = ','; const AValueSeparator: String = ':');
    destructor Destroy; override;
  end;

  TestCaseRangeAttribute = TTestCaseRangeAttribute;

implementation

class function TValueRange.Create(AStart: Double; AStop: Double; AStep: Double): TValueRange;
begin
  Result.Start := AStart;
  Result.Stop :=  AStop;
  Result.Step :=  AStep;
end;

class function TEcefTestData.Create(AXMeters: Double; AYMeters: Double; AZMeters: Double): TEcefTestData;
begin
  Result.XMeters := AXMeters;
  Result.YMeters := AYMeters;
  Result.ZMeters := AZMeters;
end;

constructor TTestCaseRangeAttribute.Create(const ACaseName : string; const ARanges: String; const ARangeSeparator: string = ','; const AValueSeparator: String = ':');
begin
  FCaseName := ACaseName;
  var LRanges := ARanges.Split([',']);
  var LRangesLen := Length(LRanges);
  Assert(3 = LRangesLen, String.Format('Invalid number of ranges: %d', [LRangesLen]) );
  for var i := 0 to LRangesLen - 1 do
  begin
    var LValues := LRanges[i].Split([':']);
    var LValuesLen := Length(LValues);
    Assert(3 = LRangesLen, String.Format('Invalid number of values: %d (Range %d)', [LValuesLen, i]));
    case i of
      0: FRangeX := TValueRange.Create(LValues[0].ToDouble, LValues[1].ToDouble, LValues[2].ToDouble);
      1: FRangeY := TValueRange.Create(LValues[0].ToDouble, LValues[1].ToDouble, LValues[2].ToDouble);
      2: FRangeZ := TValueRange.Create(LValues[0].ToDouble, LValues[1].ToDouble, LValues[2].ToDouble);
    end;
  end;

  ValidateRanges;

  AddSequentially;
end;

destructor TTestCaseRangeAttribute.Destroy;
begin
  for var i := 0 to (Length(FTestCaseInfo) -1) do
    SetLength(FTestCaseInfo[0].Values, 0);
  SetLength(FTestCaseInfo, 0);
  inherited Destroy;
end;

procedure TTestCaseRangeAttribute.ValidateRanges;
begin
  if (FRangeX.Step = 0.0) and (FRangeX.Start <> FRangeX.Stop) then
    raise EArgumentException.Create(String.Format('Invlid X Step: %.3f. Infinite Loop.', [FRangeX.Step]));

  if (FRangeY.Step = 0.0) and (FRangeY.Start <> FRangeY.Stop) then
    raise EArgumentException.Create(String.Format('Invlid Y Step: %.3f. Infinite Loop.', [FRangeY.Step]));

  if (FRangeZ.Step = 0.0) and (FRangeZ.Start <> FRangeZ.Stop) then
    raise EArgumentException.Create(String.Format('Invlid Y Step: %.3f. Infinite Loop.', [FRangeZ.Step]));

  if (FRangeX.Start > FRangeX.Stop) and (FRangeX.Step >= 0.0) then
    raise EArgumentException.Create(String.Format('Envlid X Start and End: %.3f, %.3f, Alt: %.3f is invalid', [FRangeX.Start, FRangeX.Stop, FRangeX.Step]));

  if (FRangeY.Start > FRangeY.Stop) and (FRangeY.Step >= 0.0) then
    raise EArgumentException.Create(String.Format('Envlid Y Start and End: %.3f, %.3f, Alt: %.3f is invalid', [FRangeY.Start, FRangeY.Stop, FRangeY.Step]));

  if (FRangeZ.Start > FRangeZ.Stop) and (FRangeZ.Step >= 0.0) then
    raise EArgumentException.Create(String.Format('Envlid Z Start and End: %.3f, %.3f, Alt: %.3f is invalid', [FRangeZ.Start, FRangeZ.Stop, FRangeZ.Step]));

  if (FRangeX.Start < FRangeX.Stop) and (FRangeX.Step <= 0.0) then
    raise EArgumentException.Create(String.Format('Envlid X Start and End: %.3f, %.3f, Alt: %.3f is invalid', [FRangeX.Start, FRangeX.Stop, FRangeX.Step]));

  if (FRangeY.Start < FRangeY.Stop) and (FRangeY.Step <= 0.0) then
    raise EArgumentException.Create(String.Format('Envlid Y Start and End: %.3f, %.3f, Alt: %.3f is invalid', [FRangeY.Start, FRangeY.Stop, FRangeY.Step]));

  if (FRangeZ.Start < FRangeZ.Stop) and (FRangeZ.Step <= 0.0) then
    raise EArgumentException.Create(String.Format('Envlid  Z Start and End: %.3f, %.3f, Alt: %.3f is invalid', [FRangeZ.Start, FRangeZ.Stop, FRangeZ.Step]));
end;

procedure TTestCaseRangeAttribute.AddSequentially;
begin
  var LNextX := FRangeX.Start;
  while LNextX <= FRangeX.Stop do
  begin
    var LNextY := FRangeY.Start;
    while LNextY <= FRangeY.Stop do
    begin
      var LNextZ := FRangeZ.Start;
      while LNextZ <= FRangeZ.Stop do
      begin
        var i := Length(FTestCaseInfo);
        SetLength(FTestCaseInfo, i + 1);
        FTestCaseInfo[i].Name := FCaseName;
        SetLength(FTestCaseInfo[i].Values, 3);
        FTestCaseInfo[i].Values[0] := LNextX;
        FTestCaseInfo[i].Values[1] := LNextY;
        FTestCaseInfo[i].Values[2] := LNextZ;
        LNextZ := LNextZ + FRangeZ.Step;
      end;
      LNextY := LNextY + FRangeY.Step;
    end;
    LNextX := LNextX + FRangeX.Step;
  end;
end;

function TTestCaseRangeAttribute.GetCaseInfoArray: TestCaseInfoArray;
begin
  Result := FTestCaseInfo;
end;

end.
