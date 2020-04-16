unit tiled.utils;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.UIConsts, NativeXML;

type
  TXMLNodeHelper = class helper for TXMLNode
    function ReadAttribute(const AName: string; const ADefault: string)
      : string; overload;
    function ReadAttribute(const AName: string; const ADefault: Integer)
      : Integer; overload;
    function ReadAttribute(const AName: string; const ADefault: Single)
      : Single; overload;
    function ReadAttribute(const AName: string; const ADefault: Boolean)
      : Boolean; overload;
  end;

function StringToColor(const AColor: string;
  ADefColor: TAlphaColor = TAlphaColorRec.Black): TAlphaColor;

implementation

function StringToColor(const AColor: string; ADefColor: TAlphaColor): TAlphaColor;
var
  p: PWideChar;
  V: Integer absolute Result;
  ARGB: TAlphaColorRec absolute Result;
begin
  if Length(AColor) > 0 then
  begin
    p := Pointer(AColor);
    if ((p^ >= 'a') and (p^ <= 'z')) or ((p^ >= 'A') and (p^ <= 'Z')) then
    // #AARRGGBB
    begin
      if not IdentToAlphaColor('cla' + AColor, V) then
        Result := ADefColor;
    end
    else if (p^ = '#') or (p^ = 'x') or (p^ = '$') or (p^ = 'H') then
    begin
      if Length(AColor) = 7 then // #RRGGBB?
      begin
        Inc(p);
        if TryStrToInt('$' + p, V) then
          ARGB.A := 255
        else
          Result := ADefColor;
      end
      else if Length(AColor) = 9 then // AARRGGBB
      begin
        Inc(p);
        if not TryStrToInt('$' + p, V) then
          Result := ADefColor;
      end
      else
        Result := ADefColor;
    end
    else
      Result := ADefColor;
  end
  else
    Result := ADefColor;
end;

{ TXMLNodeHelper }

function TXMLNodeHelper.ReadAttribute(const AName, ADefault: string): string;
var
  LAttribute: TsdAttribute;
begin
  LAttribute := Self.AttributeByName[AName];
  if Assigned(LAttribute) then
    Result := LAttribute.ValueUnicode
  else
    Result := ADefault;
end;

function TXMLNodeHelper.ReadAttribute(const AName: string;
  const ADefault: Integer): Integer;
var
  LAttribute: TsdAttribute;
begin
  LAttribute := Self.AttributeByName[AName];
  if Assigned(LAttribute) then
    Result := LAttribute.ValueAsInteger
  else
    Result := ADefault;
end;

function TXMLNodeHelper.ReadAttribute(const AName: string;
  const ADefault: Single): Single;
var
  LAttribute: TsdAttribute;
begin
  LAttribute := Self.AttributeByName[AName];
  if Assigned(LAttribute) then
    Result := LAttribute.ValueAsFloat
  else
    Result := ADefault;
end;

function TXMLNodeHelper.ReadAttribute(const AName: string;
  const ADefault: Boolean): Boolean;
var
  LAttribute: TsdAttribute;
begin
  LAttribute := Self.AttributeByName[AName];
  if Assigned(LAttribute) then
    Result := LAttribute.ValueAsBool
  else
    Result := ADefault;
end;

end.
