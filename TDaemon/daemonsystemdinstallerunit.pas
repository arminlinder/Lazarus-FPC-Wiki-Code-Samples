unit DaemonSystemdInstallerUnit;

// ---------------------------------------------------------------------------------------------
// Common file: helper functions for Linux service install/uninstall support (systemd/systemctl)
// Not required for Windows, where similar functionality is built-in in the DaemonApp unit
// V1.1 3/2022 arminlinder@arminlinder.de
// ---------------------------------------------------------------------------------------------

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DaemonApp, IniFiles;

const
  DAEMON_CONFIG_FILE_PATH = '/lib/systemd/system';   // Linux systemd config file path

function GetSystemdControlFilePath(aDaemonName: string): string;
function CreateSystemdControlFile(aDaemon: TCustomDaemon; aFilePath: string): boolean;
function RemoveSystemdControlFile(aFilePath: string): boolean;

implementation

function GetSystemdControlFilePath(aDaemonName: string): string;

begin
  Result := IncludetrailingBackslash(DAEMON_CONFIG_FILE_PATH) + aDaemonName + '.service';
end;

function CreateSystemdControlFile(aDaemon: TCustomDaemon; aFilePath: string): boolean;

var
  f: TIniFile;

begin
  Result := False;
  try
    f := TIniFile.Create(aFilePath, []);
    // The mapper class used to create the daemon is accessible through the "Definition" property of the daemon object
    // We use it to populate a very basic .service file. Consult the systemd documentation for more options
    f.WriteString('Unit', 'Description', aDaemon.Definition.Description);
    f.WriteString('Unit', 'After', 'network.target');
    f.WriteString('Service', 'Type', 'simple');
    f.WriteString('Service', 'ExecStart', Application.ExeName + ' -r');
    f.WriteString('Install', 'WantedBy', 'multi-user.target');
    Result := True;
  finally
    f.Free;
  end;
end;

function RemoveSystemdControlFile(aFilePath: string): boolean;

  // Remove the control file, if it does exist

begin
  Result := True;
  if FileExists(aFilePath) then
    Result := DeleteFile(aFilePath);
end;

end.
