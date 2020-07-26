unit MainUnit;

{$mode objfpc}{$H+}

interface

uses
  sgeTypes, ParticleApp,
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Grids,
  ComCtrls, Types;

const
  VERSION = '0.1';



type
  TMainFrm = class(TForm)
    btnDeletePart: TToolButton;
    btnEditPart: TToolButton;
    btnSeparator2: TToolButton;
    btnSeparator3: TToolButton;
    btnSeparator5: TToolButton;
    FilterEdit: TEdit;
    GridImageList: TImageList;
    btnOptimizeDataBase: TToolButton;
    ToolImageList: TImageList;
    StatusBar: TStatusBar;
    StringGrid: TStringGrid;
    ToolBar: TToolBar;
    btnAddPart: TToolButton;
    btnSeparator1: TToolButton;
    btnClose: TToolButton;
    btnAddFail: TToolButton;
    btnClearFails: TToolButton;
    btnChastList: TToolButton;
    btnMissileList: TToolButton;
    btnClearFilter: TToolButton;
    btnSeparator4: TToolButton;
    btnRestDataBase: TToolButton;
    procedure btnAddFailClick(Sender: TObject);
    procedure btnAddPartClick(Sender: TObject);
    procedure btnChastListClick(Sender: TObject);
    procedure btnClearFailsClick(Sender: TObject);
    procedure btnClearFilterClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnDeletePartClick(Sender: TObject);
    procedure btnEditPartClick(Sender: TObject);
    procedure btnMissileListClick(Sender: TObject);
    procedure btnOptimizeDataBaseClick(Sender: TObject);
    procedure btnRestDataBaseClick(Sender: TObject);
    procedure FilterEditChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure StringGridDblClick(Sender: TObject);
    procedure StringGridDrawCell(Sender: TObject; aCol, aRow: Integer; aRect: TRect; aState: TGridDrawState);
    procedure ToolBarChangeBounds(Sender: TObject);
  private
    procedure FillStringGrid;
    procedure CorrectToolBar;
    procedure LoadSettings;
    procedure SaveSettings;

    function  IsPartExist(ID: String; AChast, AMissile, APartName, AProducer: String): Boolean;
  public

  end;



var
  MainFrm: TMainFrm;
  APP: TParticleApp;



implementation

{$R *.lfm}


uses
  sgeSQLiteTable,
  ChastUnit, MissileUnit, PartEditorUnit, PartFailEditorUnit,
  LazUTF8, Windows;



procedure TMainFrm.FormCreate(Sender: TObject);
begin
  //Настройки
  Caption := 'Частица - ' + VERSION;
  LoadSettings;

  //Данные
  FillStringGrid;
  CorrectToolBar;
end;


procedure TMainFrm.btnCloseClick(Sender: TObject);
begin
  Close;
end;


procedure TMainFrm.btnDeletePartClick(Sender: TObject);
var
  Sql, RealIDX, s: String;
begin
  if StringGrid.Row < 1 then Exit;

  RealIDX := StringGrid.Cells[0, StringGrid.Row];

  s := 'Будет удалена запчасть "' + StringGrid.Cells[3, StringGrid.Row] + '" и связанные данные';
  if MessageDlg('Вопрос', s, mtConfirmation, mbYesNo, 0) = mrYes then
    begin

    try
      SQL := 'DELETE FROM `Parts` WHERE ID=' + RealIDX;
      APP.Base.Query(SQL);
    except
      on E: EsgeException do
        ShowMessage(E.Message);
    end;

    FillStringGrid;
    CorrectToolBar;
    end;


end;


procedure TMainFrm.btnEditPartClick(Sender: TObject);
Label
  A1;
var
  Upd: Boolean;
  ChastName, MissileName, PartName, Producer, SQL: String;
  AllowFails, WarrantiTime: Integer;
  IDMissile: String;
  Idx: String;
begin
  if StringGrid.Row < 1 then Exit;

  Idx := StringGrid.Cells[0, StringGrid.Row];
  ChastName := StringGrid.Cells[1, StringGrid.Row];
  MissileName := StringGrid.Cells[2, StringGrid.Row];
  PartName := StringGrid.Cells[3, StringGrid.Row];
  Producer := StringGrid.Cells[4, StringGrid.Row];
  AllowFails := StrToInt(StringGrid.Cells[5, StringGrid.Row]);
  WarrantiTime := StrToInt(StringGrid.Cells[6, StringGrid.Row]);

A1:

  if Execute_PartEditor(App, pemEdit, ChastName, MissileName, PartName, Producer, AllowFails, WarrantiTime, Upd) then
    begin
    if IsPartExist(Idx, ChastName, MissileName, PartName, Producer) then
      begin
      ShowMessage('Запчасть "' + PartName + '" существует, задайте другое имя.');
      goto A1;
      end;

    //Изменить в базе
    IDMissile := App.GetMissileIDByName(MissileName);
    SQL := 'UPDATE Parts SET ID_MISSILE=' + IDMissile + ', Name='#39 + PartName + #39', Producer='#39 + Producer + #39', AllowFails=' + IntToStr(AllowFails) + ', WarrantyTime=' + IntToStr(WarrantiTime) + ' WHERE ID=' + Idx;
    try
      APP.Base.Query(SQL);
    except
      on E: EsgeException do
        ShowMessage(E.Message);
    end;

    FillStringGrid;
    end;

  if Upd then FillStringGrid;
end;


procedure TMainFrm.btnMissileListClick(Sender: TObject);
var
  Upd: Boolean;
begin
  Execute_Missile(APP, Upd);
  if Upd then FillStringGrid;
end;


procedure TMainFrm.btnOptimizeDataBaseClick(Sender: TObject);
begin
  App.OptimizeDB;
  ShowMessage('Оптимизация выполнена успешна!');
end;


procedure TMainFrm.btnRestDataBaseClick(Sender: TObject);
begin
  if MessageDlg('ВНИМАНИЕ!', 'ВНИМАНИЕ! Действие нельзя отменить!'#13#10'База данных будет сброшена к начальным значениям', mtConfirmation, mbYesNo, 0) = mrYes then
    if MessageDlg('ВНИМАНИЕ!', 'Вы точно уверены?', mtConfirmation, mbYesNo, 0) = mrYes then
      begin
      APP.ResetDataBase;
      FillStringGrid;
      end;
end;


procedure TMainFrm.FilterEditChange(Sender: TObject);
begin
  FillStringGrid;
end;


procedure TMainFrm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  SaveSettings;
end;


procedure TMainFrm.btnAddPartClick(Sender: TObject);
Label
  A1;
var
  Upd: Boolean;
  ChastName, MissileName, PartName, Producer, SQL: String;
  AllowFails, WarrantiTime: Integer;
  IDMissile: String;
begin
  ChastName := '';
  MissileName := '';
  PartName := '';
  Producer := '';
  AllowFails := 0;
  WarrantiTime := 0;

A1:
  if Execute_PartEditor(App, pemNew, ChastName, MissileName, PartName, Producer, AllowFails, WarrantiTime, Upd) then
    begin
    if IsPartExist('', ChastName, MissileName, PartName, Producer) then
      begin
      ShowMessage('Запчасть "' + PartName + '" существует, задайте другое имя.');
      goto A1;
      end;


    //Добавить в базу
    IDMissile := App.GetMissileIDByName(MissileName);
    SQL := 'INSERT INTO Parts (ID_MISSILE, Name, Producer, AllowFails, WarrantyTime) VALUES ('#39 +
           IDMissile + #39', '#39 + PartName + #39', '#39 + Producer + #39', ' + IntToStr(AllowFails) + ', ' + IntToStr(WarrantiTime) + ')';
    try
      APP.Base.Query(SQL);
    except
      on E: EsgeException do
        ShowMessage(E.Message);
    end;

    FillStringGrid;
    end;



  if Upd then FillStringGrid;
end;


procedure TMainFrm.btnChastListClick(Sender: TObject);
var
  Upd: Boolean;
begin
  Execute_Chast(APP, Upd);
  if Upd then FillStringGrid;
end;


procedure TMainFrm.btnClearFailsClick(Sender: TObject);
var
  SQL, s, PartIdx: String;
begin
  if StringGrid.Row < 1 then Exit;

  s := 'Будет удалена информация о сбоях запчасти "' + StringGrid.Cells[3, StringGrid.Row];
  if MessageDlg('Вопрос', s, mtConfirmation, mbYesNo, 0) = mrYes then
    begin

    PartIdx := StringGrid.Cells[0, StringGrid.Row];

    SQL := 'DELETE FROM `Fails` WHERE ID_Part=' + PartIdx;

    try
      App.Base.Query(SQL);
    except
      on E: EsgeException do
        ShowMessage(E.Message);
    end;

    FillStringGrid;
    end;
end;


procedure TMainFrm.btnClearFilterClick(Sender: TObject);
begin
  FilterEdit.Clear;
end;


procedure TMainFrm.btnAddFailClick(Sender: TObject);
var
  Fail, Work: Integer;
  PartIdx: String;
  SQL: String;
begin
  if StringGrid.Row < 1 then Exit;

  PartIdx := StringGrid.Cells[0, StringGrid.Row];
  Fail := 0;
  Work := 0;
  if Execute_PartFailEditor(Fail, Work) then
    begin

    SQL := 'INSERT INTO Fails (ID_PART, FailCount, WorkHours) VALUES (' + PartIdx + ', ' + IntToStr(Fail) + ', ' + IntToStr(Work) + ')';

    try
      App.Base.Query(SQL);
    except
      on E: EsgeException do
        ShowMessage(E.Message);
    end;

    FillStringGrid;
    end;
end;


procedure TMainFrm.FormDestroy(Sender: TObject);
begin
end;


procedure TMainFrm.StringGridDblClick(Sender: TObject);
begin
  btnEditPart.Click;
end;


procedure TMainFrm.StringGridDrawCell(Sender: TObject; aCol, aRow: Integer; aRect: TRect; aState: TGridDrawState);
var
  Col: TColor;
  Idx: Integer;
  X, Y: Integer;
begin
  if aRow = 0 then Exit;

  //Вывод текста если выделение
  if (TStringGrid(Sender).Row = aRow) and (aCol <> 9) then
    begin
    //Нарисовать выделение
    Col := $FF9933;
    StringGrid.Canvas.Brush.Color := Col;
    StringGrid.Canvas.FillRect(aRect);


    if (aCol >= 1) then
      begin
      case aCol of
        1..4:
          begin
          X := aRect.Left + 3;
          Y := aRect.Top + (aRect.Bottom - aRect.Top) div 2 - StringGrid.Canvas.Font.GetTextHeight('W') div 2 - 1;
          end;
        5..8:
          begin
          X := aRect.Right - StringGrid.Canvas.TextWidth(StringGrid.Cells[aCol, aRow]) - 4;
          Y := aRect.Top + (aRect.Bottom - aRect.Top) div 2 - StringGrid.Canvas.Font.GetTextHeight('W') div 2 - 1;
          end;
      end;

      //StringGrid.Canvas.Font.Style := [fsBold];
      StringGrid.Canvas.Font.Color := clWhite;
      StringGrid.Canvas.TextOut(X, Y, StringGrid.Cells[aCol, aRow]);
      end;
    end;



  //Вывод иконки
  if aCol = 9 then
    begin
    //Стереть фон
    Col := clMenu;
    if odd(aRow) then Col := clWhite;
    if TStringGrid(Sender).Row = aRow then Col := $FF9933;
    StringGrid.Canvas.Brush.Color := Col;
    StringGrid.Canvas.FillRect(aRect);

    //Иконка
    if StringGrid.Cells[aCol, aRow] = '1' then Idx := 9 else Idx := 10;
    X := (aRect.Right - aRect.Left) div 2 - GridImageList.Width div 2;
    Y := (aRect.Bottom - aRect.Top) div 2 - GridImageList.Height div 2;
    GridImageList.Draw(StringGrid.Canvas, aRect.Left + X, aRect.Top + Y, Idx, True);
    end;
end;


procedure TMainFrm.ToolBarChangeBounds(Sender: TObject);
begin
  //btnClose.Left := ToolBar.Width - btnClose.Width;
end;


procedure TMainFrm.FillStringGrid;
var
  SQL, Filter: String;
  i, j, k, Idx, LastIdx, Col1, Col2: Integer;
  Add: Boolean;
begin
  Filter := UTF8LowerCase(UTF8Trim(FilterEdit.Text));
  LastIdx := StringGrid.Row;


  SQL := 'SELECT * FROM `PartList`';

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
      for k := 1 to 8 do
        if UTF8Pos(Filter, UTF8LowerCase(App.Base.Table.Row[i][k])) > 0 then
          begin
          Add := True;
          Break;
          end;
      end;


    //Добавлять столбики
    if Add then
      begin
      Inc(Idx);
      StringGrid.RowCount := Idx + 1;

      for j := 0 to APP.Base.Table.ColumnCount - 1 do
        StringGrid.Cells[j, Idx] := APP.Base.Table.Cell[j, i];



      //Определить статус
      Filter := '1';
      Col1 := StrToInt(StringGrid.Cells[5, Idx]);
      Col2 := StrToInt(StringGrid.Cells[7, Idx]);
      if Col1 < Col2 then Filter := '0';
      Col1 := StrToInt(StringGrid.Cells[6, Idx]);
      Col2 := StrToInt(StringGrid.Cells[8, Idx]);
      if Col1 < Col2 then Filter := '0';
      StringGrid.Cells[9, Idx] := Filter;
      end;
    end;





  if LastIdx > StringGrid.RowCount - 1 then LastIdx := StringGrid.RowCount - 1;
  StringGrid.Row := LastIdx;


  StatusBar.SimpleText := 'Запчастей: ' + IntToStr(StringGrid.RowCount - 1);
end;


procedure TMainFrm.CorrectToolBar;
var
  Idx: Integer;
begin
  Idx := StringGrid.Row;

  btnEditPart.Enabled := (Idx > 0);
  btnDeletePart.Enabled := (Idx > 0);
  btnAddFail.Enabled := (Idx > 0);
  btnClearFails.Enabled := (Idx > 0);
end;


procedure TMainFrm.LoadSettings;
var
  i: Integer;
begin
  //Окно
  Left := APP.Settings.GetIntegerDefault('MainFrm.Left', 100);
  Top := APP.Settings.GetIntegerDefault('MainFrm.Top', 100);
  Width := APP.Settings.GetIntegerDefault('MainFrm.Width', 500);
  Height := APP.Settings.GetIntegerDefault('MainFrm.Height', 400);

  //Таблица
  for i := 1 to StringGrid.ColCount - 1 do
    StringGrid.Columns.Items[i].Width := APP.Settings.GetIntegerDefault('MainFrm.Column' + IntToStr(i), 100);
end;


procedure TMainFrm.SaveSettings;
var
  i: Integer;
begin
  //Окно
  APP.Settings.SetIntegerDefault('MainFrm.Left', Left);
  APP.Settings.SetIntegerDefault('MainFrm.Top', Top);
  APP.Settings.SetIntegerDefault('MainFrm.Width', Width);
  APP.Settings.SetIntegerDefault('MainFrm.Height', Height);

  //Таблица
  for i := 1 to StringGrid.ColCount - 1 do
    APP.Settings.SetIntegerDefault('MainFrm.Column' + IntToStr(i), StringGrid.Columns.Items[i].Width);
end;


function TMainFrm.IsPartExist(ID: String; AChast, AMissile, APartName, AProducer: String): Boolean;
var
  SQL: String;
  i, c: Integer;
  Row: TsgeSQLiteTableRow;
begin
  Result := False;
  AChast := UTF8LowerCase(AChast);
  AMissile := UTF8LowerCase(AMissile);
  APartName := UTF8LowerCase(APartName);
  AProducer := UTF8LowerCase(AProducer);

  //Запросить таблицу
  SQL := 'SELECT ChastName, MissileName, Name, Producer, ID FROM PartList';
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
       (UTF8LowerCase(Row[1]) = AMissile) and
       (UTF8LowerCase(Row[2]) = APartName) and
       (UTF8LowerCase(Row[3]) = AProducer) and
       (Row[4] <> ID) then
        begin
        Result := True;
        Break;
        end;
    end;
end;



end.

