unit tiled.parser;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Zlib, System.IOUtils, Soap.EncdDecd, NativeXML,
  tiled.types, tiled.utils;

type
  TTiledParser = class
  private type
    TTile = record
      ImageFileName: string;
      DrawingWidth, DrawingHeight, FrameWidth, FrameHeight: Integer;
      LeftMargin, TopMargin: Integer;
      HorzSpacing, VertSpacing: Integer;
      IsVertSpacingBottom: Boolean;
      IsSmoothScalingSafeBorder: Boolean;
    end;
  private
    FRootPath: string;
  private
    function ParseTileset(const ANode: TXMLNode): TTiled.TTileset;
    procedure ParseImage(const AImage: TTiled.TImage; const ANode: TXMLNode);
    procedure ParseProperties(const AProperties: TTiled.TPropertyList; const ANode: TXMLNode);
    procedure ParseTerrainTypes(const ATerrainTypes: TTiled.TTerrainList; const ANode: TXMLNode);
    procedure ParseAnimation(const AAnimation: TTiled.TAnimation; const ANode: TXMLNode);
    function ParseObjectGroupLayer(const ANode: TXMLNode): TTiled.TObjectGroupLayer; overload;
    procedure ParseObjectGroupLayer(const ALayer: TTiled.TObjectGroupLayer; const ANode: TXMLNode); overload;
    function ParseLayer(const ANode: TXMLNode): TTiled.TLayer; overload;
    procedure ParseLayer(const ALayer: TTiled.TLayer; const ANode: TXMLNode); overload;
    procedure ParseLayerAttribute(const ALayer: TTiled.TLayer; const ANode: TXMLNode);
    function ParseImageLayer(const ANode: TXMLNode): TTiled.TImageLayer;
    procedure ParseData(const AData: TTiled.TBinaryData; const ANode: TXMLNode);
  private
    FMap: TTiled.TMap;
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromFile(const AFileName: string);

    property Map: TTiled.TMap read FMap;
  end;

implementation

{ TTiledMap }

constructor TTiledParser.Create;
begin
  FMap:= TTiled.TMap.Create;
end;

destructor TTiledParser.Destroy;
begin
  FreeAndNil(FMap);
  inherited;
end;

procedure TTiledParser.LoadFromFile(const AFileName: string);
var
  LXML: TNativeXml;
  I: Integer;
begin
  FMap.Reset;
  FRootPath:= ExtractFilePath(AFileName);
  LXML:= TNativeXml.Create(nil);
  try
    LXML.ExternalEncoding:= TsdStringEncoding.seUTF8;
    LXML.LoadFromFile(AFileName);
    //
    FMap.Version:= LXML.Root.ReadAttribute('version', 'invalid version...');
    FMap.Orientation:= TTiled.StrintToOrientation(LXML.Root.ReadAttribute('orientation', 'orthogonal'));
    FMap.RenderOrder:= TTiled.StringToRenderOrder(LXML.Root.ReadAttribute('renderorder', 'right-down'));
    FMap.Width:= LXML.Root.ReadAttribute('width', 0);
    FMap.Height:= LXML.Root.ReadAttribute('height', 0);
    FMap.TileWidth:= LXML.Root.ReadAttribute('tilewidth', 0);
    FMap.TileHeight:= LXML.Root.ReadAttribute('tileheight', 0);
    FMap.HexSideLength:= LXML.Root.ReadAttribute('hexsidelength', 0);
    FMap.StaggerAxis:= TTiled.StringToStaggerAxis(LXML.Root.ReadAttribute('staggeraxis', 'x'));
    FMap.StaggerIndex:= TTiled.StringToStaggerIndex(LXML.Root.ReadAttribute('staggerindex', 'odd'));
    FMap.BackgroundColor:= StringToColor(LXML.Root.ReadAttribute('backgroundcolor','#000000'));
    for I:= 0 to LXML.Root.ElementCount - 1 do
    begin
      if LXML.Root.Elements[I].NameUnicode.Equals('tileset') then
        FMap.Tilesets.Add(Self.ParseTileset(LXML.Root.Elements[I]))
      else if LXML.Root.Elements[I].NameUnicode.Equals('layer') then
        FMap.Layers.Add(Self.ParseLayer(LXML.Root.Elements[I]))
      else if LXML.Root.Elements[I].NameUnicode.Equals('objectgroup') then
        FMap.Layers.Add(Self.ParseObjectGroupLayer(LXML.Root.Elements[I]))
      else if LXML.Root.Elements[I].NameUnicode.Equals('imagelayer') then
        FMap.Layers.Add(Self.ParseImageLayer(LXML.Root.Elements[I]))
      else if LXML.Root.Elements[I].NameUnicode.Equals('properties') then
        Self.ParseProperties(FMap.Properties, LXML.Root.Elements[I])
    end;
  finally
    FreeAndNil(LXML);
  end;
end;

procedure TTiledParser.ParseImage(const AImage: TTiled.TImage;
  const ANode: TXMLNode);
var
  I: Integer;
begin
  AImage.Format:= ANode.ReadAttribute('format', '');
  AImage.Source:= ANode.ReadAttribute('source', '');
  AImage.Trans := StringToColor(ANode.ReadAttribute('trans', '0ac81e'));
  AImage.Width := ANode.ReadAttribute('width', 0);
  AImage.Height:= ANode.ReadAttribute('height', 0);
  //
  for I:= 0 to ANode.ElementCount - 1 do
    if ANode.Elements[I].NameUnicode.Equals('data') then
      Self.ParseData(AImage.Data, ANode.Elements[I]);
end;

procedure TTiledParser.ParseProperties(const AProperties: TTiled.TPropertyList;
  const ANode: TXMLNode);
var
  I: Integer;
  LProperty: TTiled.TProperty;
begin
  for I:= 0 to ANode.ElementCount - 1 do
  begin
    LProperty:= TTiled.TProperty.Create;
    LProperty.Name := ANode.Elements[I].ReadAttribute('name', '');
    LProperty.Value:= ANode.Elements[I].ReadAttribute('value', '');
    LProperty.&Type:= ANode.Elements[I].ReadAttribute('type', '');
    AProperties.Add(LProperty);
  end;
end;

procedure TTiledParser.ParseTerrainTypes(const ATerrainTypes: TTiled.TTerrainList;
  const ANode: TXMLNode);
var
  I, J: Integer;
  LTerrainNode: TXMLNode;
  LTerrain: TTiled.TTerrain;
begin
  for I:= 0 to ANode.ElementCount - 1 do
  begin
    LTerrainNode:= ANode.Elements[I];
    LTerrain:= TTiled.TTerrain.Create;
    LTerrain.Name:= LTerrainNode.ReadAttribute('name', '');
    LTerrain.Tile:= LTerrainNode.ReadAttribute('tile', -1);
    for J:= 0 to LTerrainNode.ElementCount - 1 do
      if LTerrainNode.Elements[J].NameUnicode.Equals('properties') then
        Self.ParseProperties(LTerrain.Properties, LTerrainNode.Elements[J]);
  end;
end;

procedure TTiledParser.ParseAnimation(const AAnimation: TTiled.TAnimation;
  const ANode: TXMLNode);
var
  I: Integer;
  LFrame: TTiled.TAnimFrame;
begin
  for I:= 0 to ANode.ElementCount - 1 do
  begin
    if ANode.Elements[I].NameUnicode.Equals('frame') then
    begin
      LFrame:= TTiled.TAnimFrame.Create;
      LFrame.TileID  := ANode.Elements[I].ReadAttribute('tileid', -1);
      LFrame.Duration:= ANode.Elements[I].ReadAttribute('duration', 0);
      AAnimation.Add(LFrame);
    end;
  end;
end;

procedure TTiledParser.ParseData(const AData: TTiled.TBinaryData;
  const ANode: TXMLNode);
const
  BufferSize = 16;
  CSVDataSeparator = Char(',');
var
  RawData: string;
  DecoderIn, DecoderOut, Decompressor: TStream;
  Buffer: array[0..BufferSize-1] of Cardinal;
  DataCount, DataLength: Longint;
  CSVItem: string;
  tmpChar, p: PChar;
  CSVDataCount: Cardinal;
  UsePlainXML: Boolean;
  I: Integer;
begin
  UsePlainXML:= False;
  DecoderIn:= TStringStream.Create;
  DecoderOut:= TMemoryStream.Create;
  try
    with AData do
    begin
      Encoding:= TTiled.StringToEncodingType(ANode.ReadAttribute('encoding', ''));
      Compression:= TTiled.StringToCompressionType(ANode.ReadAttribute('compression', ''));
      if (Encoding = etNone) and (Compression = ctNone) then
        UsePlainXML:= True
      else
      begin
        RawData:= ANode.ValueUnicode.Replace('#$D#$A', '').Trim;
        case Encoding of
          etBase64:
            begin
              TStringStream(DecoderIn).WriteString(RawData);
              DecoderIn.Position:= 0;
              Soap.EncdDecd.DecodeStream(DecoderIn, DecoderOut);
            end;
          etCSV:
            begin
              // remove EOLs
              RawData:= StringReplace(RawData, #10, '', [rfReplaceAll]);
              RawData:= StringReplace(RawData, #13, '', [rfReplaceAll]);
              // count data
              CSVDataCount:= 0;
              tmpChar:= StrScan(PChar(RawData), CSVDataSeparator);
              while tmpChar <> nil do
              begin
                Inc(CSVDataCount);
                tmpChar:= StrScan(StrPos(tmpChar, CSVDataSeparator) + 1, CSVDataSeparator);
              end;
              // read data
              SetLength(SourceData, CSVDataCount + 1);
              p:= PChar(RawData);
              DataCount:= 0;
              repeat
                tmpChar:= StrPos(p, CSVDataSeparator);
                if tmpChar = nil then tmpChar:= StrScan(p, #0);
                SetString(CSVItem, p, tmpChar - p);
                SourceData[DataCount]:= StrToInt(CSVItem);
                Inc(DataCount);
                p:= tmpChar + 1;
              until tmpChar^ = #0;
            end;
        end;
        //
        case Compression of
          ctGzip: ;//Gzip format not implemented
          ctZLib:
            begin
              DecoderOut.Position:= 0;
              Decompressor:= TDecompressionStream.Create(DecoderOut);
              try
                repeat
                  DataCount:= Decompressor.Read(Buffer, BufferSize * SizeOf(Cardinal));
                  DataLength:= Length(SourceData);
                  SetLength(SourceData, DataLength+(DataCount div SizeOf(Cardinal)));
                  if DataCount > 0 then
                    Move(Buffer, SourceData[DataLength], DataCount);
                until DataCount < SizeOf(Buffer);
              finally
                Decompressor.Free;
              end;
            end;
          ctNone:
            begin
  //            if Encoding = etBase64 then
  //              repeat
  //                DataCount:= Decoder.Read(Buffer, BufferSize * SizeOf(Cardinal));
  //                DataLength:= Length(Data);
  //                SetLength(Data, DataLength+(DataCount div SizeOf(Cardinal)));
  //                if DataCount > 0 then // because if DataCount=0 then ERangeCheck error
  //                  Move(Buffer, Data[DataLength], DataCount);
  //              until DataCount < SizeOf(Buffer);
            end;
        end;
      end;

      for I:= 0 to ANode.ElementCount -1 do
      begin
        if ANode.Elements[I].NameUnicode.Equals('tile') then
        begin
          if UsePlainXML then
          begin
            SetLength(SourceData, Length(SourceData)+1);
            SourceData[High(SourceData)]:= ANode.Elements[I].ReadAttribute('gid', 0);
          end;
        end;
      end;
    end;
  finally
    DecoderIn.Free;
    DecoderOut.Free;
  end;
end;

function TTiledParser.ParseLayer(const ANode: TXMLNode): TTiled.TLayer;
begin
  Result:= TTiled.TLayer.Create;
  Self.ParseLayer(Result, ANode);
end;

procedure TTiledParser.ParseLayer(const ALayer: TTiled.TLayer;
  const ANode: TXMLNode);
var
  I: Integer;
begin
  Self.ParseLayerAttribute(ALayer, ANode);
  for I:= 0 to ANode.ElementCount - 1 do
  begin
    if ANode.Elements[I].NameUnicode.Equals('properties') then
      Self.ParseProperties(ALayer.Properties, ANode.Elements[I])
    else if ANode.Elements[I].NameUnicode.Equals('data') then
      Self.ParseData(ALayer.Data, ANode.Elements[I]);
  end;
end;

procedure TTiledParser.ParseLayerAttribute(const ALayer: TTiled.TLayer;
  const ANode: TXMLNode);
begin
  ALayer.Name   := ANode.ReadAttribute('name', '');
  ALayer.Opacity:= ANode.ReadAttribute('opacity', 1.0);
  ALayer.Visible:= ANode.ReadAttribute('visible', 1) <> 0;
  ALayer.OffsetX:= ANode.ReadAttribute('offsetx', 0.0);
  ALayer.OffsetY:= ANode.ReadAttribute('offsety', 0.0);
  ALayer.Color  := StringToColor(ANode.ReadAttribute('color', '#000000'));
  ALayer.Width  := ANode.ReadAttribute('width', 0);
  ALayer.Height := ANode.ReadAttribute('height', 0);
end;

function TTiledParser.ParseObjectGroupLayer(const ANode: TXMLNode)
  : TTiled.TObjectGroupLayer;
begin
  Result:= TTiled.TObjectGroupLayer.Create;
  Self.ParseObjectGroupLayer(Result, ANode);
end;

procedure TTiledParser.ParseObjectGroupLayer(const ALayer: TTiled.TObjectGroupLayer;
  const ANode: TXMLNode);
var
  I, J: Integer;
  LObjectNode: TXMLNode;
  LObject: TTiled.TTiledObject;
begin
  Self.ParseLayerAttribute(ALayer, ANode);
  ALayer.DrawOrder:= TTiled.StringToDrawOrder(ANode.ReadAttribute('draworder', 'topdown'));
  for I:= 0 to ANode.ElementCount - 1 do
  begin
    LObjectNode:= ANode.Elements[I];
    if LObjectNode.NameUnicode.Equals('object') then
    begin
      LObject:= TTiled.TTiledObject.Create;
      LObject.ID      := LObjectNode.ReadAttribute('id', -1);
      LObject.Name    := LObjectNode.ReadAttribute('name', '');
      LObject.&Type   := LObjectNode.ReadAttribute('type', '');
      LObject.X       := LObjectNode.ReadAttribute('x', 0.0);
      LObject.Y       := LObjectNode.ReadAttribute('y', 0.0);
      LObject.Width   := LObjectNode.ReadAttribute('width', 0.0);
      LObject.Height  := LObjectNode.ReadAttribute('height', 0.0);
      LObject.Rotation:= LObjectNode.ReadAttribute('rotation', 0.0);
      LObject.GID     := LObjectNode.ReadAttribute('gid', -1);
      LObject.Visible := LObjectNode.ReadAttribute('visible', 1) <> 0;
      //
      for J:= 0 to LObjectNode.ElementCount - 1 do
      begin
        if LObjectNode.Elements[J].NameUnicode.Equals('properties') then
          Self.ParseProperties(LObject.Properties, LObjectNode.Elements[J])
        else if LObjectNode.Elements[J].NameUnicode.Equals('ellipse') then
          LObject.Primitive:= TTiled.TTileObjectPrimitive.topEllipse
        else if LObjectNode.Elements[J].NameUnicode.Equals('polygon') then
        begin
          LObject.Primitive:= TTiled.TTileObjectPrimitive.topPoligon;
          LObject.SetPoints(LObjectNode.Elements[J].ReadAttribute('points', ''));
        end
        else if LObjectNode.Elements[J].NameUnicode.Equals('polyline') then
        begin
          LObject.Primitive:= TTiled.TTileObjectPrimitive.topPolyLine;
          LObject.SetPoints(LObjectNode.Elements[J].ReadAttribute('points', ''));
        end;
      end;
      ALayer.Objects.Add(LObject);
    end;
  end;
end;

function TTiledParser.ParseImageLayer(const ANode: TXMLNode): TTiled.TImageLayer;
var
  I: Integer;
begin
  Result:= TTiled.TImageLayer.Create;
  Self.ParseLayerAttribute(Result, ANode);
  for I:= 0 to ANode.ElementCount - 1 do
  begin
    if ANode.Elements[I].NameUnicode.Equals('image') then
      Self.ParseImage(Result.Image, ANode.Elements[I]);
  end;
end;

function TTiledParser.ParseTileset(const ANode: TXMLNode): TTiled.TTileset;
  function ParseTilesetFromTSX(const ASource: string): TTiled.TTileset;
  var
    LXML: TNativeXml;
  begin
    LXML:= TNativeXml.Create(nil);
    try
      LXML.ExternalEncoding:= TsdStringEncoding.seUTF8;
      LXML.LoadFromFile(TPath.Combine(FRootPath, ASource));
      Result:= Self.ParseTileset(LXML.Root);
    finally
      FreeAndNil(LXML);
    end;
  end;

  function ParseTile(const ANode: TXMLNode): TTiled.TTile;
  begin
    Result:= TTiled.TTile.Create;
    Result.ID:= ANode.ReadAttribute('id', -1);
    Result.SetTerrain(ANode.ReadAttribute('terrain', ''));
    Result.Probability:= ANode.ReadAttribute('probability', 1.0);
    if ANode.HasAttribute('properties') then
      Self.ParseProperties(Result.Properties, ANode);
    if ANode.HasAttribute('image') then
      Self.ParseImage(Result.Image, ANode);
    if ANode.HasAttribute('animation') then
      Self.ParseAnimation(Result.Animation, ANode);
    if ANode.HasAttribute('objectgroup') then
      Self.ParseObjectGroupLayer(Result.ObjectGroup, ANode);
  end;

var
  I: Integer;
begin
  if ANode.HasAttribute('source') then
  begin
    Result:= ParseTilesetFromTSX(ANode.ReadAttribute('source', ''));
    Result.FirstGID:= ANode.ReadAttribute('firstgid', 1);
  end
  else
  begin
    Result:= TTiled.TTileset.Create;
    Result.Name      := ANode.ReadAttribute('name', '');
    Result.TileWidth := ANode.ReadAttribute('tilewidth', 0);
    Result.TileHeight:= ANode.ReadAttribute('tileheight', 0);
    Result.FirstGID  := ANode.ReadAttribute('firstgid', 1);
    Result.TileCount := ANode.ReadAttribute('tilecount', 0);
    Result.Columns   := ANode.ReadAttribute('columns', 0);
    Result.Spacing   := ANode.ReadAttribute('spacing', 0);
    Result.Margin    := ANode.ReadAttribute('margin', 0);
    for I:= 0 to ANode.ElementCount - 1 do
    begin
      if ANode.Elements[I].NameUnicode.Equals('image') then
        Self.ParseImage(Result.Image, ANode.Elements[I])
      else if ANode.Elements[I].NameUnicode.Equals('terraintypes') then
        Self.ParseTerrainTypes(Result.TerrainTypes, ANode.Elements[I])
      else if ANode.Elements[I].NameUnicode.Equals('tile') then
        Result.Tiles.Add(ParseTile(ANode.Elements[I]))
      else if ANode.Elements[I].NameUnicode.Equals('properties') then
        Self.ParseProperties(Result.Properties, ANode.Elements[I])
      else if ANode.Elements[I].NameUnicode.Equals('tileoffset') then
      begin
        Result.TileOffset.X:= ANode.Elements[I].ReadAttribute('x', 0);
        Result.TileOffset.Y:= ANode.Elements[I].ReadAttribute('y', 0);
      end;
    end;
  end;
end;

end.