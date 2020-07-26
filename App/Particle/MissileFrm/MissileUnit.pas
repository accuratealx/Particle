unit MissileUnit;

{$mode objfpc}{$H+}

interface

uses
  ParticleApp, Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, Grids;


type
  TMissileFrm = class(TForm)
    btnClear: TToolButton;
    btnClearFilter: TToolButton;
    btnSeparator2: TToolButton;
    FilterEdit: TEdit;
    btnSeparator1: TToolButton;
    StringGridImageList: TImageList;
    ToolImageList: TImageList;
    StatusBar: TStatusBar;
    StringGrid: TStringGrid;
    ToolBar: TToolBar;
    btnAddMissile: TToolButton;
    btnEditMissile: TToolButton;
    btnDeleteMissile: TToolButton;
    procedure btnAddMissileClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnClearFilterClick(Sender: TObject);
    procedure btnDeleteMissileClick(Sender: TObject);
    procedure btnEditMissileClick(Sender: TObject);
    procedure FilterEditChange(Sender: TObject);
    procedure StringGridDblClick(Sender: TObject);
    procedure StringGridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    procedure LoadSettings;
    procedure SaveSettings;
    procedure CorrectToolBar;
    procedure LoadStringGrid;
    function  IsNameExist(AChast, AName: String): Boolean;
  public

  end;

var
  MissileFrm: TMissileFrm;
  APP: TParticleApp;


procedure Execute_Missile(APPObj: TParticleApp; var NeedUpdate: Boolean);


implementation

{$R *.lfm}

uses
  sgeTypes, sgeSQLiteTable,
  MissileEditorUnit,
  LazUTF8, LCLType;



procedure Execute_Missile(APPObj: TParticleApp; var NeedUpdate: Boolean);
begin
  APP := APPObj;
  Application.CreateForm(TMissileFrm, MissileFrm);
  MissileFrm.LoadSettings;
  MissileFrm.LoadStringGrid;
  MissileFrm.CorrectToolBar;
  MissileFrm.ShowModal;
  NeedUpdate := MissileFrm.Tag = 1;
  MissileFrm.SaveSettings;
  MissileFrm.Free;
end;


procedure TMissileFrm.btnAddMissileClick(Sender: TObject);
Label
  A1;
var
  ChastIDX, ChastName, MissileName, SQL: String;
  MainUpdate: Boolean;
begin
  ChastName := '';
  MissileName := '';
  MainUpdate := False;

A1:

  if Execute_MissileEditor(APP, memNew, ChastName, MissileName, MainUpdate) then
    begin
    //Проверить на уникальность
    if IsNameExist(ChastName, MissileName) then
      begin
      ShowMessage('Ракета "' + MissileName + '" существует, задайте другое имя.');
      goto A1;
      end;


    //Найти индекс части по имени
    ChastIDX := App.GetChastIDByName(ChastName);

    //Вставить в базу
    try
      SQL := 'INSERT INTO Missile (ID_Chast, Name) VALUES (' + ChastIDX + ', '#39 + MissileName + #39')';
      APP.Base.Query(SQL);
    except
      on E: EsgeException do
        ShowMessage(E.Message);
    end;

    //Поправить интерфейс
    LoadStringGrid;
    CorrectToolBar;
    Tag := 1;
    end;


  //Проверить на обновление главного списка запчастей
  if MainUpdate then Tag := 1;
end;


procedure TMissileFrm.btnClearClick(Sender: TObject);
var
  SQL: String;
begin
  if MessageDlg('ВНИМАНИЕ!', 'ВНИМАНИЕ! Действие нельзя отменить!'#13#10'Будут удалены вся техника и связанные данные', mtConfirmation, mbYesNo, 0) = mrYes then
    if MessageDlg('ВНИМАНИЕ!', 'Вы точно уверены?', mtConfirmation, mbYesNo, 0) = mrYes then
      begin
      try
        SQL := 'DELETE FROM Missile';
        APP.Base.Query(SQL);
      except
        on E: EsgeException do
          ShowMessage(E.Message);
      end;

      LoadStringGrid;
      CorrectToolBar;
      Tag := 1;
      end;
end;


procedure TMissileFrm.btnClearFilterClick(Sender: TObject);
begin
  FilterEdit.Clear;
end;


procedure TMissileFrm.btnDeleteMissileClick(Sender: TObject);
var
  s: String;
  Idx: Integer;
  SQL: String;
begin
  if StringGrid.Row < 1 then Exit;


  Idx := StrToInt(StringGrid.Cells[0, StringGrid.Row]);

  s := 'Будет удалена ракета "' + StringGrid.Cells[2, StringGrid.Row] + '" и связанные данные';
  if MessageDlg('Вопрос', s, mtConfirmation, mbYesNo, 0) = mrYes then
    begin

    try
      SQL := 'DELETE FROM `Missile` WHERE ID=' + IntToStr(Idx);
      APP.Base.Query(SQL);
    except
      on E: EsgeException do
        ShowMessage(E.Message);
    end;

    LoadStringGrid;
    CorrectToolBar;
    Tag := 1;
    end;
end;


procedure TMissileFrm.btnEditMissileClick(Sender: TObject);
label
  A1;
var
  SQL, ChastIDX, RealIdx, ChastName, MissileName: String;
  MainUpdate: Boolean;
begin
  if StringGrid.Row < 1 then Exit;

  MainUpdate := False;
  RealIdx := StringGrid.Cells[0, StringGrid.Row];
  ChastName := StringGrid.Cells[1, StringGrid.Row];
  MissileName := StringGrid.Cells[2, StringGrid.Row];

A1:

  if Execute_MissileEditor(APP, memEdit, ChastName, MissileName, MainUpdate) then
    begin
    //Проверить на уникальность
    if IsNameExist(ChastName, MissileName) then
      begin
      ShowMessage('Ракета "' + MissileName + '" существует, задайте другое имя.');
      goto A1;
      end;


    //Найти индекс части по имени
    try
      SQL := 'SELECT ID FROM Chast WHERE NAME='#39 + ChastName + #39;
      APP.Base.Query(SQL);
    except
      on E: EsgeException do
        ShowMessage(E.Message);
    end;
    ChastIDX := App.Base.Table.Cell[0, 0];


    //Вставить в базу
    try
      SQL := 'UPDATE Missile SET ID_Chast=' + ChastIDX + ', Name='#39 + MissileName + #39' WHERE ID=' + RealIdx;
      APP.Base.Query(SQL);
    except
      on E: EsgeException do
        ShowMessage(E.Message);
    end;

    //Поправить интерфейс
    LoadStringGrid;
    CorrectToolBar;
    Tag := 1;
    end;

  //Проверить на обновление главного списка запчастей
  if MainUpdate then
    begin
    Tag := 1;
    LoadStringGrid;
    end;
end;


procedure TMissileFrm.FilterEditChange(Sender: TObject);
begin
  LoadStringGrid;
end;


procedure TMissileFrm.StringGridDblClick(Sender: TObject);
begin
  btnEditMissile.Click;
end;


procedure TMissileFrm.StringGridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_INSERT: btnAddMissile.Click;
    VK_DELETE: btnDeleteMissile.Click;
  end;
end;


procedure TMissileFrm.LoadSettings;
var
  i: Integer;
begin
  //Окно
  Width := APP.Settings.GetIntegerDefault('MissileFrm.Width', 400);
  Height := APP.Settings.GetIntegerDefault('MissileFrm.Height', 450);

  //Таблица
  for i := 1 to StringGrid.ColCount - 1 do
    StringGrid.Columns.Items[i].Width := APP.Settings.GetIntegerDefault('MissileFrm.Column' + IntToStr(i), 100);
end;


procedure TMissileFrm.SaveSettings;
var
  i: Integer;
begin
  //Окно
  APP.Settings.SetIntegerDefault('MissileFrm.Width', Width);
  APP.Settings.SetIntegerDefault('MissileFrm.Height', Height);

  //Таблица
  for i := 1 to StringGrid.ColCount - 1 do
    APP.Settings.SetIntegerDefault('MissileFrm.Column' + IntToStr(i), StringGrid.Columns.Items[i].Width);
end;


procedure TMissileFrm.CorrectToolBar;
var
  Idx: Integer;
begin
  Idx := StringGrid.Row;

  btnEditMissile.Enabled := (Idx > 0);
  btnDeleteMissile.Enabled := (Idx > 0);
end;


procedure TMissileFrm.LoadStringGrid;
var
  SQL, Filter: String;
  i, j, k, Idx, LastIdx: Integer;
  Add: Boolean;
begin
  Filter := UTF8LowerCase(UTF8Trim(FilterEdit.Text));
  LastIdx := StringGrid.Row;

  SQL := 'SELECT * FROM `MissileList`';

  try
    APP.Base.Query(SQL);
  except
    on E: EsgeException do
      ShowMessage(E.Message);
  end;

  //Заполнить таблицу
  StringGrid.RowCount := 1;
  Idx := 0;
  for i := 0 to APP.Base.Table.RowCount - 1 do
    begin
    Add := False;
    if Filter = '' then Add := True
      else begin
      for k := 1 to 2 do
        if UTF8Pos(Filter, UTF8LowerCase(App.Base.Table.Row[i][k])) > 0 then
          begin
          Add := True;
          Break;
          end;
      end;


    //Добавлять
    if Add then
      begin
      Inc(Idx);
      StringGrid.RowCount := Idx + 1;

      for j := 0 to APP.Base.Table.ColumnCount - 1 do
        StringGrid.Cells[j, Idx] := APP.Base.Table.Cell[j, i];
      end;

    end;

  if LastIdx > StringGrid.RowCount - 1 then LastIdx := StringGrid.RowCount - 1;
  StringGrid.Row := LastIdx;

  StatusBar.SimpleText := 'Техники: ' + IntToStr(StringGrid.RowCount - 1);
end;


function TMissileFrm.IsNameExist(AChast, AName: String): Boolean;
var
  SQL: String;
  i, c: Integer;
  Row: TsgeSQLiteTableRow;
begin
  Result := False;
  AChast := UTF8LowerCase(AChast);
  AName := UTF8LowerCase(AName);

  //Запросить таблицу
  SQL := 'SELECT ChastName, Name FROM MissileList';
  try
    App.Base.Query(SQL);
  except
    on E: EsgeException do
      ShowMessage(E.Message);
  end;

  //Проверить построчно
  c := App.Base.Table.RowCount - 1;
  for i := 0 to c do
    begin
    Row := App.Base.Table.Row[i];
    if (UTF8LowerCase(Row[0]) = AChast) and
       (UTF8LowerCase(Row[1]) = AName) then
        begin
        Result := True;
        Break;
        end;
    end;
end;


end.

