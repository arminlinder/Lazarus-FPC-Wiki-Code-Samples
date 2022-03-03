unit DaemonUnit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DaemonApp, DaemonWorkerThread, DaemonSystemdInstallerUnit,
  LazFileUtils;

type

  { TDaemon1 }

  TDaemon1 = class(TDaemon)
    procedure DataModuleAfterInstall(Sender: TCustomDaemon);
    procedure DataModuleBeforeUnInstall(Sender: TCustomDaemon);
    procedure DataModuleContinue(Sender: TCustomDaemon; var OK: Boolean);
    procedure DataModulePause(Sender: TCustomDaemon; var OK: Boolean);
    procedure DataModuleShutDown(Sender: TCustomDaemon);
    procedure DataModuleStart(Sender: TCustomDaemon; var OK: Boolean);
    procedure DataModuleStop(Sender: TCustomDaemon; var OK: Boolean);
  private
    FDaemonWorkerThread: TDaemonWorkerThread;
  public

  end;

// Added by scaffolded code, not required
// var
//  Daemon1: TDaemon1;

implementation

{$R *.lfm}

uses FileLoggerUnit;

{ TDaemon1 }

// --------------------------------
// Installation and De-Installation
// --------------------------------

procedure TDaemon1.DataModuleAfterInstall(Sender: TCustomDaemon);

  var
  isInstalled: boolean = True;
  FilePath: string;

begin
  LogToFile('Daemon installing');
  {$IFDEF UNIX}
  FilePath := GetSystemdControlFilePath(Self.Definition.Name);
  isInstalled := CreateSystemdControlFile(self, FilePath);
  if not isInstalled then
    LogToFile('Error creating systemd control file: ' + FilePath);
  {$ENDIF}
  if isInstalled then
    LogToFile('Daemon installed');
end;

procedure TDaemon1.DataModuleBeforeUnInstall(Sender: TCustomDaemon);
  var
    isUnInstalled: boolean = True;
    FilePath: string;

  begin
    LogToFile('Daemon uninstalling');
    {$IFDEF UNIX}
    FilePath := GetSystemdControlFilePath(Self.Definition.Name);
    isUnInstalled := RemoveSystemdControlFile(FilePath);
    if not isUninstalled then
      LogToFile('Error removing systemd control file: ' + FilePath);
    {$ENDIF}
    if isUninstalled then
      LogToFile('Daemon uninstalled');
  end;

// ---------------------
// Pause and Continue
// ---------------------
//
// Note: functionality supported by Windows only

procedure TDaemon1.DataModuleContinue(Sender: TCustomDaemon; var OK: Boolean);

begin
  LogToFile('Daemon received continue signal');
  FDaemonWorkerThread.Resume;    // deprecated, yet still working
  OK := True;
end;


procedure TDaemon1.DataModulePause(Sender: TCustomDaemon; var OK: Boolean);
begin
  LogToFile('Daemon received pause signal');
  FDaemonWorkerThread.Suspend;    // deprecated, yet still working
  OK := True;;
end;

procedure TDaemon1.DataModuleShutDown(Sender: TCustomDaemon);
begin
  self.Stop;   // On shutdown, we trigger the stop handler. This will do nicely for this demo
  LogToFile('Daemon received shutdown signal');
end;

// ---------------------
// Start and Stop signal
// ---------------------

procedure TDaemon1.DataModuleStart(Sender: TCustomDaemon; var OK: Boolean);
begin
  LogToFile(Format('Daemon received start signal, PID:%d', [GetProcessID]));
  // Create a suspended worker thread - see DaemonWorkerThread unit
  FDaemonWorkerThread := TDaemonWorkerThread.Create;
  // Parametrize it
  FDaemonWorkerThread.FreeOnTerminate := False;
  // Start the worker
  FDaemonWorkerThread.Start;
  OK := True;
end;

procedure TDaemon1.DataModuleStop(Sender: TCustomDaemon; var OK: Boolean);
begin
  LogToFile('Daemon received stop signal');
  // stop and terminate the worker
  if assigned(FDaemonWorkerThread) then
  begin
    FDaemonWorkerThread.Terminate;
    // Wait for the thread to terminate.
    FDaemonWorkerThread.WaitFor;
    FreeAndNil(FDaemonWorkerThread);
  end;
  LogToFile('Daemon stopped');
  OK := True;
end;

// ------------------------------------
// Unit initialization and finalization
// ------------------------------------

procedure RegisterDaemon;
begin
  RegisterDaemonClass(TDaemon1);
end;

initialization
  RegisterDaemon;

end.
