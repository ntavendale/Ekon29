unit TestEcef;

interface

uses
  System.SysUtils, System.Classes, DUnitX.TestFramework, DUnitX.Attributes,
  DUnitX.TestDataProvider, Attributes.Range, DataProvider.EcefToLla,
  DUnitX.FilterBuilder,
  Coordinates, Coordinates.Helpers;

type
  [TestFixture]
  [Category('CoordinateTests')]
  TTestEcef = class
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    [TestCase('TestAEcef','-1247110.7388627927, -4577497.307185983, 4250834.659784284')]
    [TestCase('TestBEcef','20100.0, 20100.0, 20100.0')]
    procedure TestPoint(XMeters, YMeters, ZMeters: Double);
    [Test]
    // include will only bring these in if explicitly mentions=ed on ciommand line.
    [Category('RangeTests')]  //
    [TestCaseRange('RangeTest', '20100.0:20200.0:10.0, 20100.0:20200.0:10.0, 20100.0:20200.0:10.0')]
    procedure TestRange(X, Y, Z: Double);
    [Test]
    [TestCaseProvider(TEcefToLlaDataProvider)]
    procedure ToLla(AEcef: TEcefCoordinates; AExpected: TGeodeticCoordinates; ATolerance: Double; AObjectID: String);
    [Test]
    [TestCaseProvider('EcefToLLa')]
    procedure ToEcef(ALla: TGeodeticCoordinates; AExpected: TEcefCoordinates; ATolerance: Double; AObjectID: String);
  end;

implementation

procedure TTestEcef.Setup;
begin
end;

procedure TTestEcef.TearDown;
begin
end;

procedure TTestEcef.TestPoint(XMeters, YMeters, ZMeters: Double);
begin
  TDUnitX.CurrentRunner.Log(TLogLevel.Information,  String.Format('Running Test X: %.3f, Y: %.3f, Z: %.3f', [XMeters, YMeters, ZMeters]));
  var Expected := TEcefCoordinates.Create(XMeters, YMeters, ZMeters);
  var Geodetic := Expected.ToGeodeticCoordinates;
  var Actual := Geodetic.ToEcefCoordinates;

  Assert.AreEqual(Expected.XMeters, Actual.XMeters, 1000, 'X Meters wrong!');
  Assert.AreEqual(Expected.YMeters, Actual.YMeters, 1000, 'Y Meters wrong!');
  Assert.AreEqual(Expected.ZMeters, Actual.ZMeters, 1000, 'Z Meters wrong!');
end;

procedure TTestEcef.TestRange(X, Y, Z: Double);
begin
  TDUnitX.CurrentRunner.Log(TLogLevel.Information,  String.Format('X: %.3f, Y: %.3f, Z: %.3f', [X, Y, Z]));

  var Expected := TEcefCoordinates.Create(X, Y, Z);
  var Geodetic := Expected.ToGeodeticCoordinates;
  var Actual := Geodetic.ToEcefCoordinates;

  Assert.AreEqual(Expected.XMeters, Actual.XMeters, TOLERANCE, 'X Meters wrong!');
  Assert.AreEqual(Expected.YMeters, Actual.YMeters, TOLERANCE, 'Y Meters wrong!');
  Assert.AreEqual(Expected.ZMeters, Actual.ZMeters, TOLERANCE, 'Z Meters wrong!');
end;

procedure TTestEcef.ToLla(AEcef: TEcefCoordinates; AExpected: TGeodeticCoordinates; ATolerance: Double; AObjectID: String);
begin
  TDUnitX.CurrentRunner.Log(TLogLevel.Information,  String.Format('Using Data Provider %s', [AObjectID]));
  var LActual := AEcef.ToGeodeticCoordinates;
  Assert.AreEqual(AExpected.LatitudeDegrees, LActual.LatitudeDegrees, ATolerance, 'Latitude incorrect');
  Assert.AreEqual(AExpected.LongitudeDegrees, LActual.LongitudeDegrees, ATolerance, 'Longitude incorrect');
  Assert.AreEqual(AExpected.AltitudeMeters, LActual.AltitudeMeters, ATolerance, 'Altitude incorrect');
end;

procedure TTestEcef.ToEcef(ALla: TGeodeticCoordinates; AExpected: TEcefCoordinates; ATolerance: Double; AObjectID: String);
begin
  TDUnitX.CurrentRunner.Log(TLogLevel.Information,  String.Format('Using Data Provider %s', [AObjectID]));
  var LActual := ALla.ToEcefCoordinates;
  Assert.AreEqual(AExpected.XMeters, LActual.XMeters, ATolerance, 'Latitude incorrect');
  Assert.AreEqual(AExpected.YMeters, LActual.YMeters, ATolerance, 'Longitude incorrect');
  Assert.AreEqual(AExpected.ZMeters, LActual.ZMeters, ATolerance, 'Altitude incorrect');
end;

initialization
  TDUnitX.RegisterTestFixture(TTestEcef);
  // Create a seperate instance of TEcefToLlaDataProvider for each test method that uses it
  TestDataProviderManager.RegisterProvider('EcefToLLa', TEcefToLlaDataProvider);
end.
