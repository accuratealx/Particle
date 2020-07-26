unit MissileEditorUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  ExtCtrls, ParticleApp;

type
  TMissileEditorMode = (memNew, memEdit);


  TMissileEditorFrm = class(TForm)
    ChastComboBox: TComboBox;
    MissileEdit: TEdit;
    Image1: TImage;
    Image2: TImage;
    Label1: TLabel;
    Label2: TLabel;
    btnChastList: TSpeedButton;
    btnCancel: TSpeedButton;
    btnOK: TSpeedButton;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnChastListClick(Sender: TObject);
  private
    FMainUpdate: Boolean;

    procedure FillChastComboBox;
  public

  end;


var
  MissileEditorFrm: TMissileEditorFrm;
  App: TParticleApp;


function Execute_MissileEditor(APPObj: TParticleApp; Mode: TMissileEditorMode; var ChastName, MissileName: String; var NeedMainUpdate: Boolean): Boolean;


implementation

{$R *.lfm}


uses
  sgeTypes,
  ChastUnit,
  LCLType, LazUTF8;



function Execute_MissileEditor(APPObj: TParticleApp; Mode: TMissileEditorMode; var ChastName, MissileName: String; var NeedMainUpdate: Boolean): Boolean;
begin
  APP := APPObj;
  Application.CreateForm(TMissileEditorFrm, MissileEditorFrm);

  MissileEditorFrm.FMainUpdate := False;
  MissileEditorFrm.FillChastComboBox;

  case Mode of
    memNew: MissileEditorFrm.Caption := 'Добавить';
    memEdit: MissileEditorFrm.Caption := 'Изменить';
  end;
  MissileEditorFrm.ChastComboBox.ItemIndex := MissileEditorFrm.ChastComboBox.Items.IndexOf(ChastName);
      MissileEditorFrm.MissileEdit.Text := MissileName;


  MissileEditorFrm.ShowModal;

  if MissileEditorFrm.Tag = 1 then
    begin
    ChastName := UTF8Trim(MissileEditorFrm.ChastComboBox.Text);
    MissileName := UTF8Trim(MissileEditorFrm.MissileEdit.Text);
    end;

  Result := MissileEditorFrm.Tag = 1;
  NeedMainUpdate := MissileEditorFrm.FMainUpdate;

  MissileEditorFrm.Free;
end;



procedure TMissileEditorFrm.btnOKClick(Sender: TObject);
begin
  if ChastComboBox.ItemIndex = -1 then
    begin
    ShowMessage('Выберите название части!');
    Exit;
    end;

  if UTF8Trim(MissileEdit.Text) = '' then
    begin
    ShowMessage('Укажите название ракеты!');
    Exit;
    end;


  Tag := 1;
  Close;
end;


procedure TMissileEditorFrm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE: btnCancel.Click;
    VK_RETURN: btnOK.Click;
  end;
end;


procedure TMissileEditorFrm.btnChastListClick(Sender: TObject);
var
  LastValue: String;
begin
  LastValue := ChastComboBox.Text;


  Execute_Chast(APP, FMainUpdate);

  if FMainUpdate then
    begin
    FMainUpdate := True;
    FillChastComboBox;
    ChastComboBox.ItemIndex := ChastComboBox.Items.IndexOf(LastValue);
    end;
end;


procedure TMissileEditorFrm.FillChastComboBox;
var
  i: Integer;
  SQL: String;
begin
  //Получить список частей
  try
    SQL := 'SELECT Name FROM `Chast`';
    APP.Base.Query(SQL);
  except
    on E: EsgeException do
      ShowMessage(E.Message);
  end;

  //Заполнить выпадающий список
  ChastComboBox.Items.BeginUpdate;
  ChastComboBox.Items.Clear;
  for i := 0 to App.Base.Table.RowCount - 1 do
    ChastComboBox.Items.Add(App.Base.Table.Cell[0, i]);
  ChastComboBox.Items.EndUpdate;
end;


procedure TMissileEditorFrm.btnCancelClick(Sender: TObject);
begin
  Close;
end;


end.

