unit tiled.types;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections;

type
  TTiled = class
  public type
    TVector4Integer = array [0 .. 3] of Integer;
    TEncodingType = (etNone, etBase64, etCSV);
    TCompressionType = (ctNone, ctGZip, ctZLib);
    TMapOrientation = (moOrthogonal, moIsometric, moIsometricStaggered, moHexagonal);
    TMapRenderOrder = (mroRightDown, mroRightUp, mroLeftDown, mroLeftUp);
    TStaggerAxis = (saX, saY);
    TStaggerIndex = (siOdd, siEven);
    TObjectsDrawOrder = (odoIndex, odoTopDown);
    TTileObjectPrimitive = (topEllipse, topPoligon, topPolyLine);
    class function StringToEncodingType(const AEnumString: string): TEncodingType; static;
    class function StringToCompressionType(const AEnumString: string): TCompressionType; static;
    class function StrintToOrientation(const AEnumString: string): TMapOrientation; static;
    class function StringToRenderOrder(const AEnumString: string): TMapRenderOrder; static;
    class function StringToStaggerAxis(const AEnumString: string): TStaggerAxis; static;
    class function StringToStaggerIndex(const AEnumString: string): TStaggerIndex; static;
    class function StringToDrawOrder(const AEnumString: string): TObjectsDrawOrder; static;
  public type
{
  <properties>
    <property name="click" value="800001.action"/>
    <property name="collision" value="900001.action"/>
  </properties>
}
    TProperty = class
    private
      FName, FValue, FType: string;
    public
      property Name: string read FName write FName;
      property Value: string read FValue write FValue;
      property &Type: string read FType write FType;
    end;
    TPropertyList = class(TObjectList<TProperty>);

    TBinaryData = class
    private
      FCompression: TCompressionType;
      FEncoding: TEncodingType;
    public
      SourceData: TArray<Cardinal>;
      property Encoding: TEncodingType read FEncoding write FEncoding;
      property Compression: TCompressionType read FCompression write FCompression;
    end;

{
  <image format="" source="tmw_desert_spacing.png" trans="0ac81e" width="265" height="199" >
    <data />
  </image>
}
    TImage = class
    private
      FData: TBinaryData;
      FFormat, FSource: string;
      FTrans: TColor;
      FHeight, FWidth: Cardinal;
    public
      constructor Create;
      destructor Destroy; override;

      property Format: string read FFormat write FFormat;
      property Source: string read FSource write FSource;
      property Trans: TColor read FTrans write FTrans;
      property Width: Cardinal read FWidth write FWidth;
      property Height: Cardinal read FHeight write FHeight;
      property Data: TBinaryData read FData;
    end;

{
  <object id="2" x="255.5" y="224.5" width="15.5" height="15">
    <properties>
      <property name="click" value="800001.action"/>
      <property name="collision" value="900001.action"/>
    </properties>
  </object>
  <object id="21" x="404" y="196" width="67" height="21">
    <ellipse/>
  </object>
  <object id="22" x="566" y="115">
    <polygon points="0,0 -7,45 18,45 44,23"/>
  </object>
  <object id="23" x="631" y="194">
    <polyline points="0,0 72,46 106,13 58,3 98,-26 129,10"/>
  </object>
}
    TTiledObject = class
    private
      FImage: TImage;
      FProperties: TPropertyList;
      FPoints: TArray<TPointF>;
      FID, FGID: Integer;
      FName, FType: string;
      FRotation: Single;
      FX, FY, FWidth, FHeight: Single;
      FVisible: Boolean;
      FPrimitive: TTileObjectPrimitive;
    public
      constructor Create;
      destructor Destroy; override;
      procedure SetPoints(const AFormattedPoints: string);

      property ID: Integer read FID write FID;
      property Name: string read FName write FName;
      property &Type: string read FType write FType;
      property X: Single read FX write FY;
      property Y: Single read FY write FY;
      property Width: Single read FWidth write FWidth;
      property Height: Single read FHeight write FHeight;
      property Rotation: Single read FRotation write FRotation;
      property GID: Integer read FGID write FGID;
      property Visible: Boolean read FVisible write FVisible;
      property Primitive: TTileObjectPrimitive read FPrimitive write FPrimitive;
      property Properties: TPropertyList read FProperties;
    end;
    TTiledObjectList = class(TObjectList<TTiledObject>);

{
  <animation>
    <frame tileid="1" duration="3" />
    <frame tileid="2" duration="5" />
  </animation>
}
    TAnimFrame = class
    private
      FTileID: Cardinal;
      FDuration: Cardinal;
    public
      property TileID: Cardinal read FTileID write FTileID;
      property Duration: Cardinal read FDuration write FDuration;
    end;
    TAnimation = class(TObjectList<TAnimFrame>);
  public type
{
  <layer name="Ground" width="40" height="40">
    <data>
      <tile gid="10"/>
      <tile gid="30"/>
      <tile gid="30"/>
    </data>
  </layer>
}
    TLayer = class
    private
      FProperties: TPropertyList;
      FData: TBinaryData;
      FName: string;
      FOpacity: Single;
      FVisible: Boolean;
      FOffsetX, FOffsetY: Single;
      FColor: TColor;
      FWidth, FHeight: Integer;
    public
      constructor Create;
      destructor Destroy; override;

      property Name: string read FName write FName;
      property Opacity: Single read FOpacity write FOpacity;
      property Visible: Boolean read FVisible write FVisible;
      property OffsetX: Single read FOffsetX write FOffsetX;
      property OffsetY: Single read FOffsetY write FOffsetY;
      property Color: TColor read FColor write FColor;
      property Width: Integer read FWidth write FWidth;
      property Height: Integer read FHeight write FHeight;
      property Properties: TPropertyList read FProperties;
      property Data: TBinaryData read FData;
    end;
    TLayerList = class(TObjectList<TTiled.TLayer>);

{
  <objectgroup name="actions" visible="0" draworder="topdown">
    ...
  </objectgroup>
}
    TObjectGroupLayer = class(TLayer)
    private
      FObjects: TTiledObjectList;
      FDrawOrder: TObjectsDrawOrder;
    public
      constructor Create;
      destructor Destroy; override;

      property DrawOrder: TObjectsDrawOrder read FDrawOrder write FDrawOrder;
      property Objects: TTiledObjectList read FObjects;
    end;

{
  <imagelayer name="embed" offsetx="-144" offsety="246">
    ...
  </imagelayer>
}
    TImageLayer = class(TLayer)
    private
      FImage: TImage;
    public
      constructor Create;
      destructor Destroy; override;

      property Image: TImage read FImage;
    end;
  public type
{
  <tile id="45" terrain="0,0,0,0" probability="0">
    <properties />
    <image format="" source="tmw_desert_spacing.png" trans="0ac81e" width="265" height="199" />
    <objectgroup name="actions" visible="0" draworder="topdown" />
    <animation />
  </tile>
}
    TTile = class
    private
      FProperties: TPropertyList;
      FObjectGroup: TObjectGroupLayer;
      FImage: TImage;
      FAnimation: TAnimation;
      FID: Cardinal;
      FTerrain: TVector4Integer;
      FProbability: Single;
    public
      constructor Create;
      destructor Destroy; override;
      procedure SetTerrain(const AFormattedTerrain: string);

      property ID: Cardinal read FID write FID;
      property Probability: Single read FProbability write FProbability;
      property Properties: TPropertyList read FProperties;
      property Image: TImage read FImage;
      property ObjectGroup: TObjectGroupLayer read FObjectGroup;
      property Animation: TAnimation read FAnimation;
    end;
    TTileList = class(TObjectList<TTile>);

{
  <terraintypes>
    <terrain name="Desert" tile="29"/>
    <terrain name="Brick" tile="9"/>
    <terrain name="Cobblestone" tile="33"/>
      <properties>
        <property name="click" value="800001.action"/>
        <property name="collision" value="900001.action"/>
      </properties>
    <terrain name="Dirt" tile="14"/>
  </terraintypes>
}
    TTerrain = class
    private
      FProperties: TPropertyList;
      FName: string;
      FTile: Cardinal;
    public
      constructor Create;
      destructor Destroy; override;

      property Name: string read FName write FName;
      property Tile: Cardinal read FTile write FTile;
      property Properties: TPropertyList read FProperties;
    end;
    TTerrainList = class(TObjectList<TTerrain>);

{
  <tileset firstgid="1" source="desert.tsx"/>
-----------------------------------------------
  from .tmx
      <tileset firstgid="1" name="tileSet-hd" tilewidth="16" tileheight="16" tilecount="256" columns="16" spacing="0">
        <image source="data/image/tiled_main_horz.png" trans="fe80fe" width="256" height="256"/>
      </tileset>
-----------------------------------------------
  from .tsx
      <tileset name="Desert" tilewidth="32" tileheight="32" spacing="1" margin="1">
        <image source="tmw_desert_spacing.png" width="265" height="199"/>
        <terraintypes>
          <terrain name="Desert" tile="29"/>
          <terrain name="Brick" tile="9"/>
          <terrain name="Cobblestone" tile="33"/>
          <terrain name="Dirt" tile="14"/>
        </terraintypes>
        <tileoffset x="1", y="2" />
        <tile id="0" terrain="0,0,0,1"/>
        <tile id="1" terrain="0,0,1,1"/>
        <tile id="2" terrain="0,0,1,0"/>
        ...
        <tile id="45" terrain="0,0,0,0" probability="0"/>
        <tile id="46" terrain="0,0,0,0" probability="0.01"/>
        <tile id="47" terrain="0,0,0,0" probability="0.01"/>
      </tileset>
}
    TTileset = class
    private
      FProperties: TPropertyList;
      FImage: TImage;
      FTiles: TTileList;
      FTerrainTypes: TTerrainList;
      FFirstGID: Cardinal;
      FName: string;
      FTileWidth, FTileHeight, FSpacing, FMargin, FTileCount, FColumns: Cardinal;
      FRendererData: TObject;
    public
      TileOffset: TPoint;
      constructor Create;
      destructor Destroy; override;

      property FirstGID: Cardinal read FFirstGID write FFirstGID;
      property Name: string read FName write FName;
      property TileWidth: Cardinal read FTileWidth write FTileWidth;
      property TileHeight: Cardinal read FTileHeight write FTileHeight;
      property Spacing: Cardinal read FSpacing write FSpacing;
      property Margin: Cardinal read FMargin write FMargin;
      property TileCount: Cardinal read FTileCount write FTileCount;
      property Columns: Cardinal read FColumns write FColumns;
      property Properties: TPropertyList read FProperties;
      property Image: TImage read FImage;
      property Tiles: TTileList read FTiles;
      property TerrainTypes: TTerrainList read FTerrainTypes;

      property RendererData: TObject read FRendererData write FRendererData;
    end;
    TTilesetList = class(TObjectList<TTiled.TTileset>);
  public type
{
  <map version="1.0" tiledversion="1.1.5" orientation="orthogonal"
       renderorder="right-down" width="212" height="20" tilewidth="16"
       tileheight="16" infinite="0" backgroundcolor="#000000" nextobjectid="24">
    ...
  </map>
}
    TMap = class
    private
      FVersion: string;
      FOrientation: TMapOrientation;
      FWidth, FHeight, FTileWidth, FTileHeight, FHexSideLength: Cardinal;
      FStaggerAxis: TStaggerAxis;
      FStaggerIndex: TStaggerIndex;
      FBackgroundColor: TAlphaColor;
      FRenderOrder: TMapRenderOrder;
      FTilesets: TTilesetList;
      FLayers: TLayerList;
      FProperties: TPropertyList;
    public
      constructor Create;
      destructor Destroy; override;

      procedure Reset;
      function RequireTileRenderData(const ATilePos: TPoint;
        const ADataIndex: Integer; const ALayer: TTiled.TLayer;
        out ATileset: TTiled.TTileset; out AFrame: Integer;
        out AHorzFlip, AVertFlip, ADiagonalFlip: Boolean): Boolean;

      property Version: string read FVersion write FVersion;
      property Orientation: TMapOrientation read FOrientation write FOrientation;
      property Width: Cardinal read FWidth write FWidth;
      property Height: Cardinal read FHeight write FHeight;
      property TileWidth: Cardinal read FTileWidth write FTileWidth;
      property TileHeight: Cardinal read FTileHeight write FTileHeight;
      property HexSideLength: Cardinal read FHexSideLength write FHexSideLength;
      property StaggerAxis: TStaggerAxis read FStaggerAxis write FStaggerAxis;
      property StaggerIndex: TStaggerIndex read FStaggerIndex write FStaggerIndex;
      property BackgroundColor: TAlphaColor read FBackgroundColor write FBackgroundColor;
      property RenderOrder: TMapRenderOrder read FRenderOrder write FRenderOrder;
      property Tilesets: TTilesetList read FTilesets;
      property Layers: TLayerList read FLayers;
      property Properties: TPropertyList read FProperties;
    end;
  end;

implementation

{ TTiled }

class function TTiled.StrintToOrientation(const AEnumString: string)
  : TMapOrientation;
begin
  if AEnumString.Equals('orthogonal') then
    Result:= TMapOrientation.moOrthogonal
  else if AEnumString.Equals('isometric') then
    Result:= TMapOrientation.moIsometric
  else if AEnumString.Equals('staggered') then
    Result:= TMapOrientation.moIsometricStaggered
  else if AEnumString.Equals('hexagonal') then
    Result:= TMapOrientation.moHexagonal;
end;

class function TTiled.StringToCompressionType(
  const AEnumString: string): TCompressionType;
begin
  if AEnumString.Equals('gzip') then
    Result:= TCompressionType.ctGzip
  else if AEnumString.Equals('zlib') then
    Result:= TCompressionType.ctZLib
  else
    Result:= TCompressionType.ctNone;
end;

class function TTiled.StringToDrawOrder(const AEnumString: string)
  : TObjectsDrawOrder;
begin
  if AEnumString.Equals('index') then
    Result:= TObjectsDrawOrder.odoIndex
  else if AEnumString.Equals('topdown') then
    Result:= TObjectsDrawOrder.odoTopDown;
end;

class function TTiled.StringToEncodingType(
  const AEnumString: string): TEncodingType;
begin
  if AEnumString.Equals('base64') then
    Result:= TEncodingType.etBase64
  else if AEnumString.Equals('csv') then
    Result:= TEncodingType.etCSV
  else
    Result:= TEncodingType.etNone;
end;

class function TTiled.StringToRenderOrder(const AEnumString: string): TMapRenderOrder;
begin
  if AEnumString.Equals('right-down') then
    Result:= TMapRenderOrder.mroRightDown
  else if AEnumString.Equals('right-up') then
    Result:= TMapRenderOrder.mroRightUp
  else if AEnumString.Equals('left-down') then
    Result:= TMapRenderOrder.mroLeftDown
  else if AEnumString.Equals('left-up') then
    Result:= TMapRenderOrder.mroLeftUp;
end;

class function TTiled.StringToStaggerAxis(const AEnumString: string): TStaggerAxis;
begin
  if AEnumString.Equals('x') then
    Result:= TStaggerAxis.saX
  else if AEnumString.Equals('y') then
    Result:= TStaggerAxis.saY;
end;

class function TTiled.StringToStaggerIndex(const AEnumString: string): TStaggerIndex;
begin
  if AEnumString.Equals('odd') then
    Result:= TStaggerIndex.siOdd
  else if AEnumString.Equals('even') then
    Result:= TStaggerIndex.siEven;
end;

{ TTiled.TImage }

constructor TTiled.TImage.Create;
begin
  FData:= TBinaryData.Create;
end;

destructor TTiled.TImage.Destroy;
begin
  FreeAndNil(FData);
  inherited;
end;

{ TTiled.TTiledObject }

constructor TTiled.TTiledObject.Create;
begin
  FImage:= TImage.Create;
  FProperties:= TPropertyList.Create;
  SetLength(FPoints, 0);
end;

destructor TTiled.TTiledObject.Destroy;
begin
  FreeAndNil(FImage);
  FreeAndNil(FProperties);
  inherited;
end;

procedure TTiled.TTiledObject.SetPoints(const AFormattedPoints: string);
var
  I: Integer;
  LX, LY: Single;
  LPoints, LPoint: TArray<string>;
begin
  LPoints:= AFormattedPoints.Split([' ']);
  SetLength(FPoints, Length(LPoints));
  for I:= 0 to High(LPoints) do
  begin
    LX:= 0;
    LY:= 0;
    LPoint:= LPoints[I].Split([',']);
    if Length(LPoint) >= 2 then
    begin
      LX:= StrToFloatDef(LPoint[0], 0);
      LY:= StrToFloatDef(LPoint[1], 0);
    end;
    FPoints[I]:= TPointF.Create(LX, LY);
  end;
end;

{ TTiled.TLayer }

constructor TTiled.TLayer.Create;
begin
  FProperties:= TPropertyList.Create;
  FData:= TBinaryData.Create;
end;

destructor TTiled.TLayer.Destroy;
begin
  FreeAndNil(FProperties);
  FreeAndNil(FData);
  inherited;
end;

{ TTiled.TObjectGroupLayer }

constructor TTiled.TObjectGroupLayer.Create;
begin
  inherited Create;
  FObjects:= TTiledObjectList.Create;
end;

destructor TTiled.TObjectGroupLayer.Destroy;
begin
  FreeAndNil(FObjects);
  inherited;
end;

{ TTiled.TImageLayer }

constructor TTiled.TImageLayer.Create;
begin
  inherited Create;
  FImage:= TImage.Create;
end;

destructor TTiled.TImageLayer.Destroy;
begin
  FreeAndNil(FImage);
  inherited;
end;

{ TTiled.TTile }

constructor TTiled.TTile.Create;
begin
  FProperties:= TPropertyList.Create;
  FObjectGroup:= TObjectGroupLayer.Create;
  FImage:= TImage.Create;
  FAnimation:= TAnimation.Create;
  FillChar(FTerrain, SizeOf(FTerrain), 0);
end;

destructor TTiled.TTile.Destroy;
begin
  FreeAndNil(FProperties);
  FreeAndNil(FObjectGroup);
  FreeAndNil(FImage);
  FreeAndNil(FAnimation);
  inherited;
end;

procedure TTiled.TTile.SetTerrain(const AFormattedTerrain: string);
var
  I: Integer;
  LValues: TArray<string>;
begin
  LValues:= AFormattedTerrain.Split([',']);
  for I:= 0 to High(LValues) do
  begin
    if I > 3 then break;
    FTerrain[I]:= StrToIntDef(LValues[I], 0);
  end;
end;

{ TTiled.TTerrain }

constructor TTiled.TTerrain.Create;
begin
  FProperties:= TPropertyList.Create;
end;

destructor TTiled.TTerrain.Destroy;
begin
  FreeAndNil(FProperties);
  inherited;
end;

{ TTiled.TTileset }

constructor TTiled.TTileset.Create;
begin
  FProperties:= TPropertyList.Create;
  FImage:= TImage.Create;
  FTiles:= TTileList.Create;
  FTerrainTypes:= TTerrainList.Create;
  FTileWidth:= 0;
  FTileHeight:= 0;
  FSpacing:= 0;
  FMargin:= 0;
  FTileCount:= 0;
  FColumns:= 0;
  FRendererData:= nil;
end;

destructor TTiled.TTileset.Destroy;
begin
  FreeAndNil(FProperties);
  FreeAndNil(FImage);
  FreeAndNil(FTiles);
  FreeAndNil(FTerrainTypes);
  if Assigned(FRendererData) then
    FreeAndNil(FRendererData);
  inherited;
end;

{ TTiled.TMap }

constructor TTiled.TMap.Create;
begin
  FTilesets:= TTiled.TTilesetList.Create;
  FLayers:= TTiled.TLayerList.Create;
  FProperties:= TTiled.TPropertyList.Create;
end;

destructor TTiled.TMap.Destroy;
begin
  FreeAndNil(FTilesets);
  FreeAndNil(FLayers);
  FreeAndNil(FProperties);
  inherited;
end;

procedure TTiled.TMap.Reset;
begin
  FTilesets.Clear;
  FLayers.Clear;
  FProperties.Clear;
end;

function TTiled.TMap.RequireTileRenderData(const ATilePos: TPoint;
  const ADataIndex: Integer; const ALayer: TTiled.TLayer;
  out ATileset: TTiled.TTileset; out AFrame: Integer;
  out AHorzFlip, AVertFlip, ADiagonalFlip: Boolean): Boolean;

  function GIDToTileset(const AGID: Cardinal): TTiled.TTileSet;
  var
    I: Integer;
  begin
    for I:= 0 to FTilesets.Count - 1 do
      if FTilesets.Items[I].FirstGID > AGID then
      begin
        Result:= FTilesets[I-1];
        Exit;
      end;
    Result:= FTilesets[FTilesets.Count - 1];
  end;

const
  HorizontalFlag = $80000000;
  VerticalFlag   = $40000000;
  DiagonalFlag   = $20000000;
  ClearFlag      = $1FFFFFFF;
var
  LIndex: Integer;
  LGID, LData: Cardinal;
begin
  LData:= ALayer.Data.SourceData[ADataIndex];
  LGID:= LData and ClearFlag;
  if LGID = 0 then
    Exit(False);
  //
  ATileset:= GIDToTileset(LGID);
  AFrame:= LGID - ATileset.FirstGID;
  AHorzFlip:= LData and HorizontalFlag > 0;
  AVertFlip:= LData and VerticalFlag > 0;
  ADiagonalFlip:= LData and DiagonalFlag > 0;
  Result:= True;
end;

end.
