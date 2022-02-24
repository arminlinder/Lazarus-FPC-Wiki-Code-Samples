unit DaemonMapperUnit1;

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

