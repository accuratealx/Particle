program Particle;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, MainUnit, Dialogs,
  { you can add units after this }
  sgeTypes, ParticleApp;


{$R *.res}


var
  App: TParticleApp;


begin
  try
    App := TParticleApp.Create;
  except
    on E: EsgeException do
      begin
      ShowMessage('Возникла фатальная ошибка, продолжение не возможно!'#13#10 + E.Message);
      halt;
      end;
  end;

  MainUnit.APP := App;



  RequireDerivedFormResource := True;
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TMainFrm, MainFrm);
  Application.Run;



  App.Free;
end.

