unit ChastUnit;

{$mode objfpc}{$H+}

interface

uses
  ParticleApp, Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, Grids;


type
  TChastFrm = class(TForm)
    btnClearFilter: TToolButton;
    FilterEdit: TEdit;
    btnSeparator1: TToolButton;
    StringGridImageList: TImageList;
    btnSeparator2: TToolButton;
    btnClear: TToolButton;
    ToolImageList: TImageList;
    StatusBar: TStatusBar;
    StringGrid: TStringGrid;
    ToolBar: TToolBar;
    btnAddChast: TToolButton;
    btnEditChast: TToolButton;
    btnDeleteChast: TToolButton;
    procedure btnAddChastClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnClearFilterClick(Sender: TObject);
    procedure btnDeleteChastClick(Sender: TObject);
    procedure btnEditChastClick(Sender: TObject);
    procedure FilterEditChange(Sender: TObject);
    procedure StringGridChangeBounds(Sender: TObject);
    procedure StringGridDblClick(Sender: TObject);
  private
    procedure LoadSettings;
    procedure SaveSettings;
    procedure CorrectToolBar;
    procedure LoadStringGrid;
    function  IsNameExist(AName: String): Boolean;
  public

  end;

var
  ChastFrm: TChastFrm;
  APP: TParticleApp;


procedure Execute_Chast(APPObj: TParticleApp; var NeedUpdate: Boolean);


implementation

{$R *.lfm}

uses
  sgeTypes, sgeSQLiteTable,
  LazUTF8;



procedure Execute_Chast(APPObj: TParticleApp; var NeedUpdate: Boolean);
begin
  APP := APPObj;

  Application.CreateForm(TChastFrm, ChastFrm);
  ChastFrm.LoadSettings;
  ChastFrm.LoadStringGrid;
  ChastFrm.CorrectToolBar;
  ChastFrm.ShowModal;
  NeedUpdate := ChastFrm.Tag = 1;
  ChastFrm.SaveSettings;
  ChastFrm.Free;
end;


procedure TChastFrm.btnAddChastClick(Sender: TObject);
label
  A1;
var
  Str: String;
  SQL: String;
begin
A1:

  if InputQuery('Добавить', 'Введите имя части', Str) then
    begin
    Str := UTF8Trim(Str);

    //Проверить на пустую строку
    if Str = '' then
      begin
      ShowMessage('Имя не может быть пустым.');
      goto A1;
      end;

    //Проверить на одинаковость
    if IsNameExist(Str) then
      begin
      ShowMessage('Часть "' + Str + '" существует, задайте другое имя.');
      goto A1;
      end;


    //Вставить в базу
    try
      SQL := 'INSERT INTO `Chast` (Name) VALUES ('#39 + Str + #39')';
      APP.Base.Query(SQL);
    except
      on E: EsgeException do
        ShowMessage(E.Message);
    end;


    //Перестроить список
    LoadStringGrid;
    CorrectToolBar;
    Tag := 1;
    end;
end;


procedure TChastFrm.btnClearClick(Sender: TObject);
var
  SQL: String;
begin
  if MessageDlg('ВНИМАНИЕ!', 'ВНИМАНИЕ! Действие нельзя отменить!'#13#10'Будут удалены все части и связанные данные', mtConfirmation, mbYesNo, 0) = mrYes then
    if MessageDlg('ВНИМАНИЕ!', 'Вы точно уверены?', mtConfirmation, mbYesNo, 0) = mrNone then
      begin
      try
        SQL := 'DELETE FROM Chast';
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


procedure TChastFrm.btnClearFilterClick(Sender: TObject);
begin
  FilterEdit.Clear;
end;


procedure TChastFrm.btnDeleteChastClick(Sender: TObject);
var
  s: String;
  Idx: Integer;
  SQL: String;
begin
  if StringGrid.Row < 1 then Exit;

  Idx := StrToInt(StringGrid.Cells[0, StringGrid.Row]);

  s := 'Будет удалена часть "' + StringGrid.Cells[1, StringGrid.Row] + '" и связанные данные';
  if MessageDlg('Вопрос', s, mtConfirmation, mbYesNo, 0) = mrYes then
    begin

    try
      SQL := 'DELETE FROM `Chast` WHERE ID=' + IntToStr(Idx);
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


procedure TChastFrm.btnEditChastClick(Sender: TObject);
label
  A1;
var
  SQL, Str: String;
  RealIdx: Integer;
begin
  if StringGrid.Row < 1 then Exit;

  RealIdx := StrToInt(StringGrid.Cells[0, StringGrid.Row]);
  Str := StringGrid.Cells[1, StringGrid.Row];

A1:
  if InputQuery('Изменить', 'Введите новое имя части', Str) then
    begin
    Str := UTF8Trim(Str);

    //Проверить на пустую строку
    if Str = '' then
      begin
      ShowMessage('Имя не может быть пустым.');
      goto A1;
      end;

    //Проверить на одинаковость
    if IsNameExist(Str) then
      begin
      ShowMessage('Часть "' + Str + '" существует, задайте другое имя.');
      goto A1;
      end;


    //Изменить в базе
    try
      SQL := 'UPDATE `Chast` SET Name='#39 + Str + #39' WHERE ID=' + IntToStr(RealIdx);
      APP.Base.Query(SQL);
    except
      on E: EsgeException do
        ShowMessage(E.Message);
    end;


    //Перестроить список
    LoadStringGrid;
    CorrectToolBar;
    Tag := 1;
    end;
end;


procedure TChastFrm.FilterEditChange(Sender: TObject);
begin
  LoadStringGrid;
end;


procedure TChastFrm.StringGridChangeBounds(Sender: TObject);
begin
  StringGrid.Columns.Items[1].Width := StringGrid.ClientWidth;
end;


procedure TChastFrm.StringGridDblClick(Sender: TObject);
begin
  btnEditChast.Click;
end;


procedure TChastFrm.LoadSettings;
begin
  Width := APP.Settings.GetIntegerDefault('ChastFrm.Width', 400);
  Height := APP.Settings.GetIntegerDefault('ChastFrm.Height', 450);
end;


procedure TChastFrm.SaveSettings;
begin
  APP.Settings.SetIntegerDefault('ChastFrm.Width', Width);
  APP.Settings.SetIntegerDefault('ChastFrm.Height', Height);
end;


procedure TChastFrm.CorrectToolBar;
var
  Idx: Integer;
begin
  Idx := StringGrid.Row;

  btnEditChast.Enabled := (Idx > -1);
  btnDeleteChast.Enabled := (Idx > -1);
end;


procedure TChastFrm.LoadStringGrid;
var
  SQL, Filter: String;
  i, j, Idx, LastIdx: Integer;
  Add: Boolean;
begin
  Filter := UTF8LowerCase(UTF8Trim(FilterEdit.Text));
  LastIdx := StringGrid.Row;

  SQL := 'SELECT * FROM `Chast`';

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
    if Filter = '' then Add := True else
      if UTF8Pos(Filter, UTF8LowerCase(App.Base.Table.Row[i][1])) > 0 then Add := True;


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


  StatusBar.SimpleText := 'Всего частей: ' + IntToStr(StringGrid.RowCount - 1);
end;


function TChastFrm.IsNameExist(AName: String): Boolean;
var
  SQL: String;
  i, c: Integer;
  Row: TsgeSQLiteTableRow;
begin
  Result := False;
  AName := UTF8LowerCase(AName);

  //Запросить таблицу
  SQL := 'SELECT Name FROM Chast';
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
    if (UTF8LowerCase(Row[0]) = AName) then
        begin
        Result := True;
        Break;
        end;
    end;
end;


end.

