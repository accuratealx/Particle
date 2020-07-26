unit PartFailEditorUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Dialogs, StdCtrls, Buttons,
  ExtCtrls, Spin, ParticleApp;

type
  TMissileEditorMode = (memNew, memEdit);


  TPartFailEditorFrm = class(TForm)
    Image1: TImage;
    Image2: TImage;
    Label1: TLabel;
    Label2: TLabel;
    btnCancel: TSpeedButton;
    btnOK: TSpeedButton;
    TotalFailSpinEdit: TSpinEdit;
    TotalWorkSpinEdit: TSpinEdit;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private

  public

  end;


var
  PartFailEditorFrm: TPartFailEditorFrm;
  App: TParticleApp;



function Execute_PartFailEditor(var TotalFail, TotalWork: Integer): Boolean;


implementation

{$R *.lfm}


uses
  sgeTypes,
  ChastUnit,
  LCLType, LazUTF8;



function Execute_PartFailEditor(var TotalFail, TotalWork: Integer): Boolean;
begin
  Application.CreateForm(TPartFailEditorFrm, PartFailEditorFrm);
  PartFailEditorFrm.ShowModal;

  if PartFailEditorFrm.Tag = 1 then
    begin
    TotalFail := PartFailEditorFrm.TotalFailSpinEdit.Value;
    TotalWork := PartFailEditorFrm.TotalWorkSpinEdit.Value;
    Result := True;
    end;

  PartFailEditorFrm.Free;
end;



procedure TPartFailEditorFrm.btnOKClick(Sender: TObject);
begin
  Tag := 1;
  Close;
end;


procedure TPartFailEditorFrm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE: btnCancel.Click;
    VK_RETURN: btnOK.Click;
  end;
end;


procedure TPartFailEditorFrm.btnCancelClick(Sender: TObject);
begin
  Close;
end;


end.

