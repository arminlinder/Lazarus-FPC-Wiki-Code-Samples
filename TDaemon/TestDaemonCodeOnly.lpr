program TestDaemonCodeOnly;

{$mode objfpc}{$H+}

uses
 {$IFDEF UNIX}
  cthreads,
   {$ENDIF}
  Classes,
  SysUtils,
  { you can add units after this }
  DaemonApp,
  FileLoggerUnit,             // Thread safe file logger
  DaemonWorkerThread,         // a TThread descendant to do the daemon's work
  DaemonSystemdInstallerUnit; // -install and -uninstall support for Linux/systemd

// ------------------------------------------------------------------
// TDaemonMapper: This class type defines the settings for the daemon
// ------------------------------------------------------------------

type
  TDaemonMapper1 = class(TCustomDaemonMapper)
  public
    constructor Create(AOwner: TComponent); override;
  end;

  constructor TDaemonMapper1.Create(AOwner: TComponent);

  begin
    inherited Create(AOwner);
    with TDaemonDef(self.DaemonDefs.Add) do
    begin
      DaemonClassName := 'TDaemon1';           // This must exactly match the daemon class
      Name := 'TestDaemonCodeOnly';            // Service name
      DisplayName := 'Test Daemon (CodeOnly)'; // Service display name
      Description := 'Lazarus Daemons and Services Wiki Demo Service (Created in Code only)';
      Options := [doAllowStop, doAllowPause];
      WinBindings.StartType := stManual;  // stBoot, stSystem, stAuto, stManual, stDisabled
      WinBindings.ServiceType := stWin32;
    end;
  end;

// -------------------------------------------------------------------
// TDaemon: This class type definies the daemon task and handles the
//          events triggered by the Windows/Linux Service Manager
// -------------------------------------------------------------------

type

  { TDaemon1 }

  TDaemon1 = class(TCustomDaemon)
  private
    FDaemonWorkerThread: TDaemonWorkerThread;
  public
    function Start: boolean; override;     // start the daemon worker thread
    function Stop: boolean; override;      // stop the daemon worker thread
    function Pause: boolean; override;     // pause the daemon worker thread (Windows only)
    function Continue: boolean; override;  // resume the daemon worker thread (Windows only)
    function ShutDown: boolean; override;  // stop the daemon worker thread because of OS shutdown
    function Install: boolean; override;   // added -install suppport for Linux
    function UnInstall: boolean; override; // added -uninstall suppport for Linux
  end;

  { TDaemon1 }

  // ------------------------------------------------
  // Daemon start and stop signal
  // ------------------------------------------------

  function TDaemon1.Start: boolean;
  begin
    // Create a suspended worker thread - see DaemonWorkerThread unit
    FDaemonWorkerThread := TDaemonWorkerThread.Create;
    // Parametrize it
    FDaemonWorkerThread.FreeOnTerminate := False;
    // Start the worker
    FDaemonWorkerThread.Start;
    LogToFile(Format('TDaemon1: service %s started, PID=%d', [self.Definition.Name, GetProcessID]));
    Result := True;
  end;

  function TDaemon1.Stop: boolean;
  begin
    // stop and terminate the worker
    if assigned(FDaemonWorkerThread) then
    begin
      FDaemonWorkerThread.Terminate;
      // Wait for the thread to terminate.
      FDaemonWorkerThread.WaitFor;
      FreeAndNil(FDaemonWorkerThread);
    end;
    Result := True;
    LogToFile(Format('TDaemon1: service %s stopped', [self.Definition.Name]));
  end;

// ------------------------------------------------
// Daemon pause and continue signal (Windows only)
// ------------------------------------------------

  function TDaemon1.Pause: boolean;
  begin
    FDaemonWorkerThread.Suspend;    // deprecated, yet still working
    LogToFile(Format('TDaemon1: service %s paused', [self.Definition.Name]));
    Result := True;
  end;

  function TDaemon1.Continue: boolean;

  begin
    LogToFile(Format('TDaemon1: service %s continuing', [self.Definition.Name]));
    FDaemonWorkerThread.Resume;    // deprecated, yet still working
    Result := True;
  end;

// --------------------------------------------------------------
// Daemon stop on operating system shutdown signal (Windows only)
// --------------------------------------------------------------

  function TDaemon1.ShutDown: boolean;
  begin
    Result := self.Stop;   // On shutdown, we trigger the stop handler. This will do nicely for this demo
    LogToFile(Format('TDaemon1: service %s shutdown', [self.Definition.Name]));
  end;

// -----------------------------------------------------------------------------------------
// Daemon install and uninstall helpers for Linux, Windows is already built in TCustomDaemon
// -----------------------------------------------------------------------------------------

  function TDaemon1.Install: boolean;

  var
    FilePath: string;

  begin
    Result := False;
    {$IFDEF WINDOWS}
    Result := inherited Install;
    {$ELSE}
      {$IFDEF UNIX}
      FilePath := GetSystemdControlFilePath(Self.Definition.Name);
      LogToFile(Format('TDaemon1: installing control file: %s',[FilePath]));
      Result := CreateSystemdControlFile(self, FilePath);
      if not Result then
        LogToFile('TDaemon1: Error creating systemd control file: ' + FilePath);
      {$ENDIF}
    {$ENDIF}
    LogToFile(Format('TDaemon1: service %s installed: %s', [self.Definition.Name, BoolToStr(Result, 'ok', 'failure')]));
  end;

  function TDaemon1.UnInstall: boolean;

  var
    FilePath: string;

  begin
    Result := False;
    {$IFDEF WINDOWS}
    Result := inherited UnInstall;
    {$ELSE}
      {$IFDEF UNIX}
      FilePath := GetSystemdControlFilePath(Self.Definition.Name);
      Result := RemoveSystemdControlFile(FilePath);
      if not Result then
        LogToFile('TDaemon1: Error removing systemd control file: ' + FilePath);
      {$ENDIF}
    {$ENDIF}
    LogToFile(Format('TDaemon1: service %s uninstalled: %s', [self.Definition.Name, BoolToStr(Result, 'ok', 'failure')]));
  end;

// ---------------------
// Daemon main init code
// ---------------------

begin
  RegisterDaemonClass(TDaemon1);
  RegisterDaemonMapper(TDaemonMapper1);
  Application.Run;
end.
