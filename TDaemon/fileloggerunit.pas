unit FileLoggerUnit;

{$mode ObjFPC}{$H+}

// -------------------------------------------------------------------------------------
// Thread-safe write log message to file
//
// Note: TDaemonApplication has some logging capabilities (property Logger:TEventLog)
//       built-in, but that is not thread-safe. For the daemon sample, we make our own logger.
//       For more feature-rich thread-safe logging, look into the LazLogger unit.
// -------------------------------------------------------------------------------------
{$WARN 5058 off : Variable "$1" does not seem to be initialized}
interface

uses
  Classes, SysUtils, DaemonApp;

procedure LogToFile(aMessage: string);

implementation

// Make the logger thread-safe

var
  LogToFileCriticalSection: TRTLCriticalSection;

procedure LogToFile(aMessage: string);
// create a daily log file in the .exe directory


  function TimeStamped(S: string): string;
  // Return a timestamped copy of a string

  begin
    Result := FormatDateTime('hh:mm:ss', now) + ' ' + S;
  end;

var
  f: Text;
  LogFilePath: string;

begin
  LogFilePath := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) +
    FormatDateTime('YYYYMMDD', now) + '.log';
  AssignFile(f, LogFilePath);
  try
    if FileExists(LogFilePath) then
      Append(f)
    else
    begin
      Rewrite(f);
      writeln(f, TimeStamped('Log created'));
    end;
    Writeln(f, TimeStamped(aMessage));
  finally
    CloseFile(f);
  end;
end;

initialization
  InitCriticalSection(LogToFileCriticalSection);

finalization
  DoneCriticalSection(LogToFileCriticalSection);

end.

