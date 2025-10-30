unit Debug.Logger;

interface

uses
  System.SysUtils, System.Classes, WinApi.Windows, DUnitX.TestFramework;

type
  ///
  ///  Writes messages to OutputDebugString to be seen in DebugView.
  ///  Must be run outside of a debugger to work.
  ///  Can implement an ITestLogger to write to other outputs - Syslog, ElasticSearch,
  ///  Databases, etc.
  ///
  TDebugLogger = class(TInterfacedObject, ITestLogger)
  private
  public
    ///	<summary>
    ///	  Called at the start of testing. The default console logger prints the
    ///	  DUnitX banner.
    ///	</summary>
    procedure OnTestingStarts(const threadId: TThreadID; testCount, testActiveCount: Cardinal);

    ///	<summary>
    ///	  //Called before a Fixture is run.
    ///	</summary>
    procedure OnStartTestFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo);

    ///	<summary>
    ///	  //Called before a fixture Setup method is run
    ///	</summary>
    procedure OnSetupFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo);

    ///	<summary>
    ///	  Called after a fixture setup method is run.
    ///	</summary>
    procedure OnEndSetupFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo);

    ///	<summary>
    ///	  Called before a Test method is run.
    ///	</summary>
    procedure OnBeginTest(const threadId: TThreadID; const Test: ITestInfo);

    ///	<summary>
    ///	  Called before a test setup method is run.
    ///	</summary>
    procedure OnSetupTest(const threadId: TThreadID; const Test: ITestInfo);

    ///	<summary>
    ///	  Called after a test setup method is run.
    ///	</summary>
    procedure OnEndSetupTest(const threadId: TThreadID; const Test: ITestInfo);

    ///	<summary>
    ///	  Called before a Test method is run.
    ///	</summary>
    procedure OnExecuteTest(const threadId: TThreadID; const Test: ITestInfo);

    ///	<summary>
    ///	  Called when a test succeeds
    ///	</summary>
    procedure OnTestSuccess(const threadId: TThreadID; const Test: ITestResult);

    ///	<summary>
    ///	  Called when a test errors.
    ///	</summary>
    procedure OnTestError(const threadId: TThreadID; const Error: ITestError);

    ///	<summary>
    ///	  Called when a test fails.
    ///	</summary>
    procedure OnTestFailure(const threadId: TThreadID; const Failure: ITestError);

    /// <summary>
    ///   called when a test is ignored.
    /// </summary>
    procedure OnTestIgnored(const threadId: TThreadID; const AIgnored: ITestResult);

    /// <summary>
    ///   called when a test memory leaks.
    /// </summary>
    procedure OnTestMemoryLeak(const threadId: TThreadID; const Test: ITestResult);

    /// <summary>
    ///   allows tests to write to the log.
    /// </summary>
    procedure OnLog(const logType: TLogLevel; const msg: string);

    /// <summary>
    ///   called before a Test Teardown method is run.
    /// </summary>
    procedure OnTeardownTest(const threadId: TThreadID; const Test: ITestInfo);

    /// <summary>
    ///   called after a test teardown method is run.
    /// </summary>
    procedure OnEndTeardownTest(const threadId: TThreadID; const Test: ITestInfo);

    /// <summary>
    ///   called after a test method and teardown is run.
    /// </summary>
    procedure OnEndTest(const threadId: TThreadID; const Test: ITestResult);

    /// <summary>
    ///   called before a Fixture Teardown method is called.
    /// </summary>
    procedure OnTearDownFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo);

    /// <summary>
    ///   called after a Fixture Teardown method is called.
    /// </summary>
    procedure OnEndTearDownFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo);

    /// <summary>
    ///   called after a Fixture has run.
    /// </summary>
    procedure OnEndTestFixture(const threadId: TThreadID; const results: IFixtureResult);

    /// <summary>
    ///   called after all fixtures have run.
    /// </summary>
    procedure OnTestingEnds(const RunResults: IRunResults);
  end;

implementation

procedure TDebugLogger.OnTestingStarts(const threadId: TThreadID; testCount, testActiveCount: Cardinal);
begin
  var LOut := String.Format('%s 0x%.8x  TestCount: %d. Active %d.', [FormatDateTime('YYYY-MM-DD hh:nn:ss.zzz', Now), threadId, testCount, testActiveCount]);
  OutputDebugString(PChar(LOut));
end;

procedure TDebugLogger.OnStartTestFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo);
begin
  var LOut := String.Format('%s 0x%.8x  Starting test fixture %s. %d tests found.', [FormatDateTime('YYYY-MM-DD hh:nn:ss.zzz', Now), threadId, fixture.Name, fixture.Tests.Count]);
  OutputDebugString(PChar(LOut));
end;

procedure TDebugLogger.OnSetupFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo);
begin
  var LOut := String.Format('%s 0x%.8x  Setting up test fixture %s.', [FormatDateTime('YYYY-MM-DD hh:nn:ss.zzz', Now), threadId, fixture.Name]);
  OutputDebugString(PChar(LOut));
end;

procedure TDebugLogger.OnEndSetupFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo);
begin
  //
end;

procedure TDebugLogger.OnBeginTest(const threadId: TThreadID; const Test: ITestInfo);
begin
  var LOut := String.Format('%s 0x%.8x  Begin Test %s.', [FormatDateTime('YYYY-MM-DD hh:nn:ss.zzz', Now), threadId, Test.Name]);
  OutputDebugString(PChar(LOut));
end;

procedure TDebugLogger.OnSetupTest(const threadId: TThreadID; const Test: ITestInfo);
begin
  //
end;

procedure TDebugLogger.OnEndSetupTest(const threadId: TThreadID; const Test: ITestInfo);
begin
  //
end;

procedure TDebugLogger.OnExecuteTest(const threadId: TThreadID; const Test: ITestInfo);
begin
  var LOut := String.Format('%s 0x%.8x  Execute Test %s.', [FormatDateTime('YYYY-MM-DD hh:nn:ss.zzz', Now), threadId, Test.Name]);
  OutputDebugString(PChar(LOut));
end;

procedure TDebugLogger.OnTestSuccess(const threadId: TThreadID; const Test: ITestResult);
begin
  var LOut := String.Format('%s 0x%.8x Test succeeded: %s.', [FormatDateTime('YYYY-MM-DD hh:nn:ss.zzz', Now), threadId, Test.Message]);
  OutputDebugString(PChar(LOut));
end;

procedure TDebugLogger.OnTestError(const threadId: TThreadID; const Error: ITestError);
begin
  var LOut := String.Format('%s 0x%.8x Test error: %s.', [FormatDateTime('YYYY-MM-DD hh:nn:ss.zzz', Now), threadId, Error.ExceptionMessage]);
  OutputDebugString(PChar(LOut));
end;

procedure TDebugLogger.OnTestFailure(const threadId: TThreadID; const Failure: ITestError);
begin
  var LOut := String.Format('%s 0x%.8x Test failed: %s. Actual: %s, Expected %s', [FormatDateTime('YYYY-MM-DD hh:nn:ss.zzz', Now), threadId, Failure.ExceptionMessage, Failure.Actual, Failure.Expected]);
  OutputDebugString(PChar(LOut));
end;

procedure TDebugLogger.OnTestIgnored(const threadId: TThreadID; const AIgnored: ITestResult);
begin
  var LOut := String.Format('%s 0x%.8x Ignoring test: %s.', [FormatDateTime('YYYY-MM-DD hh:nn:ss.zzz', Now), threadId, AIgnored.Test.Name]);
  OutputDebugString(PChar(LOut));
end;

procedure TDebugLogger.OnTestMemoryLeak(const threadId: TThreadID; const Test: ITestResult);
begin
  //
end;

procedure TDebugLogger.OnLog(const logType: TLogLevel; const msg: string);
begin
  var LOut := String.Format('%s %s', [FormatDateTime('YYYY-MM-DD hh:nn:ss.zzz', Now), msg]);
  OutputDebugString(PChar(LOut));
end;

procedure TDebugLogger.OnTeardownTest(const threadId: TThreadID; const Test: ITestInfo);
begin
  //
end;

procedure TDebugLogger.OnEndTeardownTest(const threadId: TThreadID; const Test: ITestInfo);
begin
  //
end;

procedure TDebugLogger.OnEndTest(const threadId: TThreadID; const Test: ITestResult);
begin
  //
end;

procedure TDebugLogger.OnTearDownFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo);
begin
  //
end;

procedure TDebugLogger.OnEndTearDownFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo);
begin
  //
end;

procedure TDebugLogger.OnEndTestFixture(const threadId: TThreadID; const results: IFixtureResult);
begin
  //
end;

procedure TDebugLogger.OnTestingEnds(const RunResults: IRunResults);
begin
  //
end;


end.
