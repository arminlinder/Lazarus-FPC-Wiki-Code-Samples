Program TestDaemon;

// --------------------------------------
// Testdaemon: main program
// V1.1 3/2022 arminlinder@arminlinder.de
// --------------------------------------


Uses
// {$IFDEF UNIX}{$IFDEF UseCThreads}
//  CThreads,
// {$ENDIF}{$ENDIF}
{$IFDEF UNIX}
  CThreads,
{$ENDIF}
  DaemonApp, lazdaemonapp, DaemonMapperUnit1, DaemonUnit1, FileLoggerUnit
  { add your units here };

{$R *.res}

begin
  Application.Initialize;
  Application.Run;
end.
