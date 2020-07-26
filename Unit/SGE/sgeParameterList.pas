{
Пакет             Simple Game Engine 1
Файл              sgeParameterList.pas
Версия            1.5
Создан            07.06.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Параметры приложения
}

unit sgeParameterList;

{$mode objfpc}{$H+}

interface

uses
  StringArray, SimpleParameters;


type
  TsgeParameter = TSimpleParam;


  TsgeParameterList = class
  private
    FParameters: TSimpleParameters;
    FIndent: Boolean;
    FOptions: TSearchOptions;
    FFileName: String;

    function  GetCount: Integer;
    function  GetExist(Name: String): Boolean;
    procedure SetParameter(Index: Integer; Param: TsgeParameter);
    function  GetParameter(Index: Integer): TsgeParameter;
    procedure SetValue(Name: String; Value: String);
    function  GetValue(Name: String): String;
  public
    constructor Create(FileName: String = '');
    destructor  Destroy; override;

    procedure Clear;
    function  IndexOf(Name: String): Integer;
    function  Add(Name: String; Value: String): Boolean;
    function  Add(Param: TsgeParameter): Boolean;
    procedure Add(Params: TsgeParameterList);
    function  Insert(Index: Integer; Name: String; Value: String): Boolean;
    function  Insert(Index: Integer; Param: TsgeParameter): Boolean;
    procedure Insert(Index: Integer; Params: TsgeParameterList);
    function  Delete(Index: Integer): Boolean;
    function  Delete(Name: String): Boolean;

    function  SetString(Name: String; Value: String): Boolean;
    function  SetInteger(Name: String; Value: Integer): Boolean;
    function  SetReal(Name: String; Value: Real): Boolean;
    function  SetBoolean(Name: String; Value: Boolean; TrueStr: String = 'True'; FalseStr: String = 'False'): Boolean;
    function  GetString(Name: String; var ResultValue: String): Boolean;
    function  GetInteger(Name: String; var ResultValue: Integer): Boolean;
    function  GetReal(Name: String; var ResultValue: Real): Boolean;
    function  GetBoolean(Name: String; var ResultValue: Boolean; TrueStr: String = 'True'): Boolean;

    function  GetStringDefault(Name: String; DefValue: String): String;
    function  GetIntegerDefault(Name: String; DefValue: Integer): Integer;
    function  GetRealDefault(Name: String; DefValue: Real): Real;
    function  GetBooleanDefault(Name: String; DefValue: Boolean; TrueStr: String = 'True'): Boolean;
    procedure SetStringDefault(Name: String; Value: String);
    procedure SetIntegerDefault(Name: String; Value: Integer);
    procedure SetRealDefault(Name: String; Value: Real);
    procedure SetBooleanDefault(Name: String; Value: Boolean; TrueStr: String = 'True'; FalseStr: String = 'False');

    procedure Reload;

    procedure SaveToFile(FileName: String = ''; StrDivider: String = sa_StrDivider);
    procedure LoadFromFile(FileName: String = ''; StrDivider: String = sa_StrDivider);
    procedure UpdateInFile(FileName: String = ''; AutoAdd: Boolean = False; StrDivider: String = sa_StrDivider);
    procedure UpdateFromFile(FileName: String = ''; AutoAdd: Boolean = False; StrDivider: String = sa_StrDivider);
    function  Substitute(Str: String; OpenQuote: String = '@'; CloseQuote: String = ''): String;

    property Count: Integer read GetCount;
    property Parameter[Index: Integer]: TsgeParameter read GetParameter write SetParameter;
    property Exist[Name: String]: Boolean read GetExist;
    property Value[Name: String]: String read GetValue write SetValue;
    property Options: TSearchOptions read FOptions write FOptions;
    property Indent: Boolean read FIndent write FIndent;
    property FileName: String read FFileName write FFileName;
  end;


implementation

uses
  SimpleCommand,
  sgeConst, sgeTypes, SysUtils;


const
  _UNITNAME = 'sgeParameterList';


function TsgeParameterList.GetCount: Integer;
begin
  Result := SimpleParameters_GetCount(@FParameters);
end;


function TsgeParameterList.GetExist(Name: String): Boolean;
var
  Idx: Integer;
begin
  Idx := SimpleParameters_GetIdxByName(@FParameters, Name, FOptions);
  if Idx = -1 then Result := False else Result := True;
end;


procedure TsgeParameterList.SetParameter(Index: Integer; Param: TsgeParameter);
var
  c: Integer;
begin
  c := Count - 1;
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index)));

  FParameters[Index] := Param;
end;


function TsgeParameterList.GetParameter(Index: Integer): TsgeParameter;
var
  c: Integer;
begin
  c := Count - 1;
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index)));

  Result := FParameters[Index];
end;


procedure TsgeParameterList.SetValue(Name: String; Value: String);
begin
  if not SimpleParameters_Set(@FParameters, Name, Value, FOptions) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_ParameterNotFound, Name));
end;


function TsgeParameterList.GetValue(Name: String): String;
begin
  if not SimpleParameters_Get(@FParameters, Name, Result, FOptions) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_ParameterNotFound, Name));
end;


constructor TsgeParameterList.Create(FileName: String);
begin
  FIndent := True;

  FFileName := FileName;
  if FFileName <> '' then LoadFromFile(FFileName);
end;


destructor TsgeParameterList.Destroy;
begin
  Clear;
end;


procedure TsgeParameterList.Clear;
begin
  SimpleParameters_Clear(@FParameters);
end;


function TsgeParameterList.IndexOf(Name: String): Integer;
begin
  Result := SimpleParameters_GetIdxByName(@FParameters, Name, FOptions);
end;


function TsgeParameterList.Add(Name: String; Value: String): Boolean;
begin
  Result := SimpleParameters_Add(@FParameters, Name, Value, FOptions);
end;


function TsgeParameterList.Add(Param: TsgeParameter): Boolean;
begin
  Result := SimpleParameters_Add(@FParameters, Param, FOptions);
end;


procedure TsgeParameterList.Add(Params: TsgeParameterList);
begin
  SimpleParameters_Add(@FParameters, @Params, FOptions);
end;


function TsgeParameterList.Insert(Index: Integer; Name: String; Value: String): Boolean;
begin
  Result := SimpleParameters_Insert(@FParameters, Index, Name, Value, FOptions);
end;


function TsgeParameterList.Insert(Index: Integer; Param: TsgeParameter): Boolean;
begin
  Result := SimpleParameters_Insert(@FParameters, Index, Param, FOptions);
end;


procedure TsgeParameterList.Insert(Index: Integer; Params: TsgeParameterList);
begin
  SimpleParameters_Insert(@FParameters, @Params, Index, Options);
end;


function TsgeParameterList.Delete(Index: Integer): Boolean;
begin
  Result := SimpleParameters_Delete(@FParameters, Index);
end;


function TsgeParameterList.Delete(Name: String): Boolean;
begin
  Result := SimpleParameters_Delete(@FParameters, Name, FOptions);
end;


function TsgeParameterList.SetString(Name: String; Value: String): Boolean;
begin
  Result := SimpleParameters_Set(@FParameters, Name, Value, FOptions);
end;


function TsgeParameterList.SetInteger(Name: String; Value: Integer): Boolean;
begin
  Result := SimpleParameters_Set(@FParameters, Name, Value, FOptions);
end;


function TsgeParameterList.SetReal(Name: String; Value: Real): Boolean;
begin
  Result := SimpleParameters_Set(@FParameters, Name, Value, FOptions);
end;


function TsgeParameterList.SetBoolean(Name: String; Value: Boolean; TrueStr: String; FalseStr: String): Boolean;
begin
  Result := SimpleParameters_Set(@FParameters, Name, Value, TrueStr, FalseStr, FOptions);
end;


function TsgeParameterList.GetString(Name: String; var ResultValue: String): Boolean;
begin
  Result := SimpleParameters_Get(@FParameters, Name, ResultValue, FOptions);
end;


function TsgeParameterList.GetInteger(Name: String; var ResultValue: Integer): Boolean;
begin
  Result := SimpleParameters_Get(@FParameters, Name, ResultValue, FOptions);
end;


function TsgeParameterList.GetReal(Name: String; var ResultValue: Real): Boolean;
begin
  Result := SimpleParameters_Get(@FParameters, Name, ResultValue, FOptions);
end;


function TsgeParameterList.GetBoolean(Name: String; var ResultValue: Boolean; TrueStr: String): Boolean;
begin
  Result := SimpleParameters_Get(@FParameters, Name, ResultValue, TrueStr, FOptions);
end;


function TsgeParameterList.GetStringDefault(Name: String; DefValue: String): String;
begin
  if not SimpleParameters_Get(@FParameters, Name, Result, FOptions) then Result := DefValue;
end;


function TsgeParameterList.GetIntegerDefault(Name: String; DefValue: Integer): Integer;
begin
  if not SimpleParameters_Get(@FParameters, Name, Result, FOptions) then Result := DefValue;
end;


function TsgeParameterList.GetRealDefault(Name: String; DefValue: Real): Real;
begin
  if not SimpleParameters_Get(@FParameters, Name, Result, FOptions) then Result := DefValue;
end;


function TsgeParameterList.GetBooleanDefault(Name: String; DefValue: Boolean; TrueStr: String): Boolean;
begin
  if not SimpleParameters_Get(@FParameters, Name, Result, TrueStr, FOptions) then Result := DefValue;
end;


procedure TsgeParameterList.SetStringDefault(Name: String; Value: String);
begin
  if not SimpleParameters_Set(@FParameters, Name, Value, FOptions) then SimpleParameters_Add(@FParameters, Name, Value, FOptions);
end;


procedure TsgeParameterList.SetIntegerDefault(Name: String; Value: Integer);
begin
  if not SimpleParameters_Set(@FParameters, Name, Value, FOptions) then SimpleParameters_Add(@FParameters, Name, IntToStr(Value), FOptions);
end;


procedure TsgeParameterList.SetRealDefault(Name: String; Value: Real);
begin
  if not SimpleParameters_Set(@FParameters, Name, Value, FOptions) then SimpleParameters_Add(@FParameters, Name, FloatToStr(Value), FOptions);
end;


procedure TsgeParameterList.SetBooleanDefault(Name: String; Value: Boolean; TrueStr: String; FalseStr: String);
var
  s: String;
begin
  if Value then S := TrueStr else S := FalseStr;
  if not SimpleParameters_Set(@FParameters, Name, Value, TrueStr, FalseStr, FOptions) then SimpleParameters_Add(@FParameters, Name, s, FOptions);
end;


procedure TsgeParameterList.Reload;
begin
  LoadFromFile(FFileName);
end;


procedure TsgeParameterList.SaveToFile(FileName: String; StrDivider: String);
begin
  //Если пустое имя, то заменить
  if FileName = '' then FileName := FFileName;

  if not SimpleParameters_SaveToFile(@FParameters, FileName, FIndent, StrDivider) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_FileWriteError, FileName));
end;


procedure TsgeParameterList.LoadFromFile(FileName: String; StrDivider: String);
begin
  //Если пустое имя, то заменить
  if FileName = '' then FileName := FFileName;

  if not SimpleParameters_LoadFromFile(@FParameters, FileName, StrDivider) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_FileReadError, FileName));
end;


procedure TsgeParameterList.UpdateInFile(FileName: String; AutoAdd: Boolean; StrDivider: String);
begin
  //Если пустое имя, то заменить
  if FileName = '' then FileName := FFileName;

  if not SimpleParameters_UpdateInFile(@FParameters, FileName, FIndent, FOptions, StrDivider, AutoAdd) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_FileWriteError, FileName));
end;


procedure TsgeParameterList.UpdateFromFile(FileName: String; AutoAdd: Boolean; StrDivider: String);
begin
  //Если пустое имя, то заменить
  if FileName = '' then FileName := FFileName;

  if not SimpleParameters_UpdateFromFile(@FParameters, FileName, FOptions, StrDivider, AutoAdd) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_FileReadError, FileName));
end;


function TsgeParameterList.Substitute(Str: String; OpenQuote: String; CloseQuote: String): String;
var
  i, c: Integer;
  s: String;
begin
  c := GetCount - 1;
  for i := 0 to c do
    begin
    s := SimpleCommand_SecureString(FParameters[i].Value);
    Str := StringReplace(Str, OpenQuote + FParameters[i].Name + CloseQuote, s, [rfIgnoreCase, rfReplaceAll]);
    end;

  Result := Str;
end;





end.

