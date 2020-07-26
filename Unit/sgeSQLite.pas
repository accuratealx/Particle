unit sgeSQLite;

{$mode objfpc}{$H+}

interface

uses
  sgeSQLiteTable,
  sqlite3,
  SysUtils;


const
{$IFDEF WINDOWS}
  {$IFDEF WIN64}
  SQLiteLibName = 'sqlite3.dll';
  {$ELSE}
  SQLiteLibName = 'sqlite3.X32.dll';
  {$ENDIF}
{$EndIf}



type
  TsgeSQLite = class
  private
    FHandle: psqlite3;
    FTable: TsgeSQLiteTable;
    FForeignKeys: Boolean;

    FOpened: Boolean;
    FAffectedRows: Cardinal;
    FFirstReply: Boolean;

    procedure SetForeignKeys(Enable: Boolean);
  public
    constructor Create(LibName: String = SQLiteLibName);
    destructor Destroy; override;

    procedure OpenDB(FileName: String);
    procedure CloseDB;

    procedure Query(Str: String);

    property AffectedRows: Cardinal read FAffectedRows;
    property Table: TsgeSQLiteTable read FTable;
    property ForeignKeys: Boolean read FForeignKeys write SetForeignKeys;
  end;



implementation

uses
  sgeTypes;

const
  _UNITNAME = 'sgeSQLite';



function SQLiteCallback(Sender: Pointer; Columns: Integer; ColumnValues: PPChar; ColumnNames: PPchar): integer; cdecl;
var
  Self: TsgeSQLite;
begin
  Result := 0;
  Self := TsgeSQLite(Sender);

  if Self.FFirstReply then
    begin
    Self.Table.SetColumns(Columns, ColumnNames);
    Self.FFirstReply := False;
    end;

  Self.Table.AddRowFromSQLite(Columns, ColumnValues);
end;


procedure TsgeSQLite.SetForeignKeys(Enable: Boolean);
var
  Str: String;
begin
  if FForeignKeys = Enable then Exit;
  FForeignKeys := Enable;

  if FForeignKeys then Str := 'on' else Str := 'off';
  Query('PRAGMA foreign_keys=' + Str);
end;


constructor TsgeSQLite.Create(LibName: String);
begin
  if SQLiteLibraryHandle <> 0 then Exit;

  try
    InitializeSqlite(LibName);
  except
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_CantLoadLibrary, LibName));
  end;

  FTable := TsgeSQLiteTable.Create;
end;


destructor TsgeSQLite.Destroy;
begin
  FTable.Free;

  if FOpened then CloseDB;

  ReleaseSqlite;
end;


procedure TsgeSQLite.OpenDB(FileName: String);
var
  SqlResult: Integer;
begin
  if FOpened then CloseDB;

  SqlResult := sqlite3_open(PAnsiChar(FileName), @FHandle);
  if SqlResult <> SQLITE_OK then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_CantOpenDB, sqlite3_errstr(SqlResult)));



  FOpened := True;
end;


procedure TsgeSQLite.CloseDB;
begin
  sqlite3_close(FHandle);

  FOpened := False;
  FAffectedRows := 0;
end;


procedure TsgeSQLite.Query(Str: String);
var
  SqlResult: Integer;
begin
  //Проверить
  if not FOpened then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_DataBaseNotOpened));

  //Очистить таблицу
  FTable.ClearTable;

  //Флаг первого ответа
  FFirstReply := True;

  //Выполнить запрос
  SqlResult := sqlite3_exec(FHandle, PAnsiChar(Str), @SQLiteCallback, Self, nil);

  //Проверить результат
  if SqlResult <> SQLITE_OK then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_QueryError, sqlite3_errstr(SqlResult)));

  //Узнать количество затронутых строк
  FAffectedRows := sqlite3_changes(FHandle);
end;


end.

