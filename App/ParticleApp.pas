unit ParticleApp;

{$mode objfpc}{$H+}

interface

uses
  sgeSQLite, sgeParameterList;


type
  TParticleApp = class
  private
    FBase: TsgeSQLite;
    FParams: TsgeParameterList;
    FMainDir: String;
    FSettingsFile: String;
  public
    constructor Create;
    destructor  Destroy; override;

    procedure ResetDataBase;
    function  IsFilterInString(Filter, Str: String): Boolean;
    function  GetChastIDByName(Name: String): String;
    function  GetMissileIDByName(Name: String): String;
    procedure OptimizeDB;

    property Base: TsgeSQLite read FBase;
    property Settings: TsgeParameterList read FParams;
  end;



implementation

uses
  sgeTypes,
  SysUtils, Dialogs, LazUTF8;


constructor TParticleApp.Create;
begin
  FMainDir := ExtractFilePath(ParamStr(0));
  FSettingsFile := FMainDir + 'Particle.Settings';


  FBase := TsgeSQLite.Create;
  FBase.OpenDB(FMainDir + 'Particle.db');
  FBase.ForeignKeys := True;


  //Параметры
  FParams := TsgeParameterList.Create;
  try
    if FileExists(FSettingsFile) then FParams.LoadFromFile(FSettingsFile);
  except
  end;
end;


destructor TParticleApp.Destroy;
begin
  FParams.SaveToFile(FSettingsFile);

  FParams.Free;
  FBase.Free;
end;


procedure TParticleApp.ResetDataBase;
var
  SQL: String;
begin
  try
    //Обнулить индексы
    SQL := 'UPDATE `sqlite_sequence` SET seq = 0';
    FBase.Query(SQL);
    //Стереть данные
    SQL := 'DELETE FROM `Chast`';
    FBase.Query(SQL);
  except
    on E: EsgeException do
      ShowMessage(E.Message);
  end;
end;


function TParticleApp.IsFilterInString(Filter, Str: String): Boolean;
begin
  if Filter = '' then
    begin
    Result := True;
    Exit;
    end;

  Result := (UTF8Pos(Filter, Str) <> 0);
end;


function TParticleApp.GetChastIDByName(Name: String): String;
var
  SQL: String;
begin
  //Найти индекс части по имени
  try
    SQL := 'SELECT ID FROM Chast WHERE NAME='#39 + Name + #39;
    FBase.Query(SQL);
  except
    on E: EsgeException do
      ShowMessage(E.Message);
  end;
  if FBase.Table.RowCount > 0 then Result := FBase.Table.Cell[0, 0] else Result := '0';
end;


function TParticleApp.GetMissileIDByName(Name: String): String;
var
  SQL: String;
begin
  //Найти индекс части по имени
  try
    SQL := 'SELECT ID FROM Missile WHERE NAME='#39 + Name + #39;
    FBase.Query(SQL);
  except
    on E: EsgeException do
      ShowMessage(E.Message);
  end;
  if FBase.Table.RowCount > 0 then Result := FBase.Table.Cell[0, 0] else Result := '0';
end;


procedure TParticleApp.OptimizeDB;
begin
  FBase.Query('VACUUM');
end;



end.

