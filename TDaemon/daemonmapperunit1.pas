unit DaemonMapperUnit1;

// ---------------------------------------------
// Testdaemon: daemon definition/parametrization
// V1.1 3/2022 arminlinder@arminlinder.de
// ---------------------------------------------

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DaemonApp;

type
  TDaemonMapper1 = class(TDaemonMapper)
  private

  public

  end;

// Added by scaffolded code, not required
// var
//  DaemonMapper1: TDaemonMapper1;

implementation

procedure RegisterMapper;
begin
  RegisterDaemonMapper(TDaemonMapper1)
end;

{$R *.lfm}


initialization
  RegisterMapper;
end.

