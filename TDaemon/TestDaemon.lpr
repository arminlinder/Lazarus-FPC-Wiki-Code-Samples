Program TestDaemon;

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
