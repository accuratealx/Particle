unit sgeTypes;

{$mode objfpc}{$H+}

interface

uses
  SysUtils;


const
  Err_IndexOutOfBounds = 'IndexOutOfBounds';
  Err_ColumnOutOfBounds = 'ColumnOutOfBounds';
  Err_RowOutOfBounds = 'RowOutOfBounds';


  //sgeSQLite
  Err_CantLoadLibrary = 'CantLoadLibrary';
  Err_CantOpenDB = 'CantOpenDB';
  Err_DataBaseNotOpened = 'DataBaseNotOpened';
  Err_QueryError = 'QueryError';



type
  EsgeException = class(Exception);



function  sgeCreateErrorString(UnitName, ErrorMessage: String; Info: String = ''; Separator: Char = ';'): String;
function  sgeFoldErrorString(ErrorMessage: String; Info: String = ''; Separator: ShortString = #13#10): String;



implementation


function sgeCreateErrorString(UnitName, ErrorMessage: String; Info: String; Separator: Char = ';'): String;
begin
  Result := UnitName + Separator + ErrorMessage;
  if Info <> '' then Result := Result + Separator + Info;
end;


function sgeFoldErrorString(ErrorMessage: String; Info: String = ''; Separator: ShortString = #13#10): String;
begin
  Result := ErrorMessage;
  if Info <> '' then Result := Result + Separator + Info;
end;





end.

