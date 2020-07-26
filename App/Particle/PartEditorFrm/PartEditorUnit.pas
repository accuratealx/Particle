unit PartEditorUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  ExtCtrls, Spin, ParticleApp;

type
  TPartEditorMode = (pemNew, pemEdit);


  TPartEditorFrm = class(TForm)
    WarrantiTimeSpinEdit: TSpinEdit;
    btnChastList1: TSpeedButton;
    ChastComboBox: TComboBox;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    MissileComboBox: TComboBox;
    PartNameEdit: TEdit;
    Image1: TImage;
    Image2: TImage;
    Label1: TLabel;
    Label2: TLabel;
    btnChastList: TSpeedButton;
    btnCancel: TSpeedButton;
    btnOK: TSpeedButton;
    ProducerEdit: TEdit;
    AllowFailsSpinEdit: TSpinEdit;
    procedure btnCancelClick(Sender: TObject);
    procedure btnChastList1Click(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure ChastComboBoxSelect(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnChastListClick(Sender: TObject);
  private
    FMainUpdate: Boolean;

    procedure FillChastComboBox;
    procedure FillMissileComboBox;
  public

  end;


var
  PartEditorFrm: TPartEditorFrm;
  App: TParticleApp;



function Execute_PartEditor(APPObj: TParticleApp; Mode: TPartEditorMode;
                            var ChastName, MissileName, PartName, Producer: String;
                            var AllowFails, WarrantiTime: Integer;
                            var NeedMainUpdate: Boolean): Boolean;


implementation

{$R *.lfm}


uses
  sgeTypes,
  ChastUnit, MissileUnit,
  LCLType, LazUTF8;



function Execute_PartEditor(APPObj: TParticleApp; Mode: TPartEditorMode;
                            var ChastName, MissileName, PartName, Producer: String;
                            var AllowFails, WarrantiTime: Integer;
                            var NeedMainUpdate: Boolean): Boolean;
begin
  APP := APPObj;
  Application.CreateForm(TPartEditorFrm, PartEditorFrm);

  PartEditorFrm.FMainUpdate := False;
  PartEditorFrm.FillChastComboBox;


  case Mode of
    pemNew: PartEditorFrm.Caption := 'Добавить';
    pemEdit: PartEditorFrm.Caption := 'Изменить';
  end;

  PartEditorFrm.ChastComboBox.ItemIndex := PartEditorFrm.ChastComboBox.Items.IndexOf(ChastName);
  PartEditorFrm.FillMissileComboBox;
  PartEditorFrm.MissileComboBox.ItemIndex := PartEditorFrm.MissileComboBox.Items.IndexOf(MissileName);
  PartEditorFrm.PartNameEdit.Text := PartName;
  PartEditorFrm.ProducerEdit.Text := Producer;
  PartEditorFrm.AllowFailsSpinEdit.Value := AllowFails;
  PartEditorFrm.WarrantiTimeSpinEdit.Value := WarrantiTime;


  PartEditorFrm.ShowModal;

  if PartEditorFrm.Tag = 1 then
    begin
    ChastName := UTF8Trim(PartEditorFrm.ChastComboBox.Text);
    MissileName := UTF8Trim(PartEditorFrm.MissileComboBox.Text);
    PartName := UTF8Trim(PartEditorFrm.PartNameEdit.Text);
    Producer := UTF8Trim(PartEditorFrm.ProducerEdit.Text);
    AllowFails := PartEditorFrm.AllowFailsSpinEdit.Value;
    WarrantiTime := PartEditorFrm.WarrantiTimeSpinEdit.Value;
    end;

  Result := PartEditorFrm.Tag = 1;
  NeedMainUpdate := PartEditorFrm.FMainUpdate;

  PartEditorFrm.Free;
end;



procedure TPartEditorFrm.btnOKClick(Sender: TObject);
begin
  if ChastComboBox.ItemIndex = -1 then
    begin
    ShowMessage('Выберите название части!');
    Exit;
    end;

  if MissileComboBox.ItemIndex = -1 then
    begin
    ShowMessage('Выберите название ракеты!');
    Exit;
    end;

  if UTF8Trim(PartNameEdit.Text) = '' then
    begin
    ShowMessage('Укажите название запчасти!');
    Exit;
    end;

  if UTF8Trim(ProducerEdit.Text) = '' then
    begin
    ShowMessage('Укажите производителя!');
    Exit;
    end;



  Tag := 1;
  Close;
end;


procedure TPartEditorFrm.ChastComboBoxSelect(Sender: TObject);
begin
  FillMissileComboBox;
end;


procedure TPartEditorFrm.FormCreate(Sender: TObject);
begin

end;


procedure TPartEditorFrm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE: btnCancel.Click;
    VK_RETURN: btnOK.Click;
  end;
end;


procedure TPartEditorFrm.btnChastListClick(Sender: TObject);
begin
  Execute_Chast(APP, FMainUpdate);

  if FMainUpdate then
    begin
    FMainUpdate := True;
    FillChastComboBox;
    FillMissileComboBox;
    end;
end;


procedure TPartEditorFrm.FillChastComboBox;
var
  i: Integer;
  SQL, LastValue: String;
begin
  LastValue := ChastComboBox.Text;


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


  ChastComboBox.ItemIndex := ChastComboBox.Items.IndexOf(LastValue);
end;


procedure TPartEditorFrm.FillMissileComboBox;
var
  i: Integer;
  SQL, ChastID, LastValue: String;
begin
  LastValue := MissileComboBox.Text;


  //Получить ID части
  ChastID := APP.GetChastIDByName(ChastComboBox.Text);


  //Получить список ракет
  try
    SQL := 'SELECT Name FROM `Missile` WHERE ID_CHAST=' + ChastID;
    APP.Base.Query(SQL);
  except
    on E: EsgeException do
      ShowMessage(E.Message);
  end;

  //Заполнить выпадающий список
  MissileComboBox.Items.BeginUpdate;
  MissileComboBox.Items.Clear;
  for i := 0 to App.Base.Table.RowCount - 1 do
    MissileComboBox.Items.Add(App.Base.Table.Cell[0, i]);
  MissileComboBox.Items.EndUpdate;


  MissileComboBox.ItemIndex := MissileComboBox.Items.IndexOf(LastValue);
end;


procedure TPartEditorFrm.btnCancelClick(Sender: TObject);
begin
  Close;
end;


procedure TPartEditorFrm.btnChastList1Click(Sender: TObject);
begin
  Execute_Missile(APP, FMainUpdate);

  if FMainUpdate then
    begin
    FMainUpdate := True;
    FillChastComboBox;
    FillMissileComboBox;
    end;
end;


end.

