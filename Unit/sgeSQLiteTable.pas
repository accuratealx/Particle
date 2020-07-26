unit sgeSQLiteTable;

{$mode objfpc}{$H+}

interface

uses
  sgeTypes,
  SysUtils;


type
  //Строка таблицы
  TsgeSQLiteTableRow = array of String;

  //Массив строк
  TsgeSQLiteTableRowArray = array of TsgeSQLiteTableRow;


  //Таблица
  TsgeSQLiteTable = class
  private
    FColCount: Integer;             //Количество столбцов
    FCols: TsgeSQLiteTableRow;      //Массив имён столбцов

    FRowCount: Integer;             //Количество строк
    FRows: TsgeSQLiteTableRowArray; //Массив строк таблицы

    procedure SetColumnCount(ACount: Integer);
    procedure SetColumn(Index: Integer; Name: String);
    function  GetColumn(Index: Integer): String;

    function  GetRow(Index: Integer): TsgeSQLiteTableRow;

    procedure SetCell(Column, Row: Integer; Value: String);
    function  GetCell(Column, Row: Integer): String;
  public
    destructor  Destroy; override;

    procedure ClearTable;
    procedure ClearRows;
    procedure SetColumns(ColCount: Integer; Names: PPChar);
    procedure AddRowFromSQLite(ColCount: Integer; Values: PPChar);

    property ColumnCount: Integer read FColCount write SetColumnCount;
    property Column[Index: Integer]: String read GetColumn write SetColumn;
    property RowCount: Integer read FRowCount;
    property Row[Index: Integer]: TsgeSQLiteTableRow read GetRow;
    property Cell[ColIdx, RowIdx: Integer]: String read GetCell write SetCell;
  end;



implementation

const
  _UNITNAME = 'sgeSQLiteTable';


procedure TsgeSQLiteTable.SetColumnCount(ACount: Integer);
var
  i: Integer;
begin
  if FColCount = ACount then Exit;

  FColCount := ACount;

  //Изменить количество столбиков
  SetLength(FCols, FColCount);


  //Пробежать по строкам и изменить длину
  for i := 0 to FRowCount - 1 do
    SetLength(FRows[i], FColCount);

  //Если ширина 0, то удалить массив
  if FColCount = 0 then
    begin
    SetLength(FRows, 0);
    FRowCount := 0;
    end;
end;


procedure TsgeSQLiteTable.SetColumn(Index: Integer; Name: String);
begin
  if (Index < 0) or (Index > FColCount - 1) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, 'IndexOutOfBounds', IntToStr(Index)));

  FCols[Index] := Name;
end;


function TsgeSQLiteTable.GetColumn(Index: Integer): String;
begin
  if (Index < 0) or (Index > FColCount - 1) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, 'IndexOutOfBounds', IntToStr(Index)));

  Result := FCols[Index];
end;


function TsgeSQLiteTable.GetRow(Index: Integer): TsgeSQLiteTableRow;
begin
  if (Index < 0) or (Index > FRowCount - 1) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, 'IndexOutOfBounds', IntToStr(Index)));

  Result := FRows[Index];
end;


procedure TsgeSQLiteTable.SetCell(Column, Row: Integer; Value: String);
begin
  if (Column < 0) or (Column > FColCount - 1) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, 'ColumnOutOfBounds', IntToStr(Column)));

  if (Row < 0) or (Row > FRowCount - 1) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, 'RowOutOfBounds', IntToStr(Column)));

  FRows[Row][Column] := Value;
end;


function TsgeSQLiteTable.GetCell(Column, Row: Integer): String;
begin
  if (Column < 0) or (Column > FColCount - 1) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, 'ColumnOutOfBounds', IntToStr(Column)));

  if (Row < 0) or (Row > FRowCount - 1) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, 'RowOutOfBounds', IntToStr(Column)));

  Result := FRows[Row][Column];
end;


destructor TsgeSQLiteTable.Destroy;
begin
  ClearTable;
end;


procedure TsgeSQLiteTable.ClearTable;
begin
  SetColumnCount(0);
end;


procedure TsgeSQLiteTable.ClearRows;
var
  i: Integer;
begin
  //Удалить память каждой строки
  for i := 0 to FRowCount - 1 do
    SetLength(FRows[i], 0);

  SetLength(FRows, 0);
end;


procedure TsgeSQLiteTable.SetColumns(ColCount: Integer; Names: PPChar);
var
  ColName: PPChar;
  i: Integer;
begin
  if ColCount < 1 then Exit;
  SetColumnCount(ColCount);

  ColName := Names;
  for i := 0 to ColCount - 1 do
    begin
    FCols[i] := ColName^;
    Inc(ColName);
    end;
end;


procedure TsgeSQLiteTable.AddRowFromSQLite(ColCount: Integer; Values: PPChar);
var
  i, c: Integer;
  ColVal: PPChar;
  Line: TsgeSQLiteTableRow;
begin
  if ColCount < 1 then Exit;

  //Подготовить строку
  SetLength(Line, ColCount);

  //Запомнить строки
  ColVal := Values;
  for i := 0 to ColCount - 1 do
    begin
    Line[i] := ColVal^;
    Inc(ColVal);
    end;

  //Добавить строку в таблицу
  c := FRowCount;
  Inc(FRowCount);
  SetLength(FRows, c + 1);
  FRows[c] := Line;
end;



end.

