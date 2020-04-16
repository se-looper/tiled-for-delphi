unit tiled.render;

interface

uses
  System.Classes, System.SysUtils, System.Types, System.Math,
  FMX.Types, FMX.Graphics,
  tiled.types, tiled.parser;

type
  TTiledRender = class
  private
    FMap: TTiled.TMap;
    FObjectsVisible: Boolean;
    procedure RenderObjects;
    procedure SetMap(const Value: TTiled.TMap);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render(const ACanvas: TCanvas);

    property Map: TTiled.TMap read FMap write SetMap;
  end;

implementation

{ TTiledRender }

constructor TTiledRender.Create;
begin
  FObjectsVisible:= False;
end;

destructor TTiledRender.Destroy;
begin

  inherited;
end;

procedure TTiledRender.SetMap(const Value: TTiled.TMap);
var
  LTileset: TTiled.TTileset;
  LImage: TBitmap;
begin
  FMap:= Value;
  if FMap = nil then Exit;
  //
  for LTileset in FMap.Tilesets do
  begin
    if LTileset.Columns = 0 then
      LTileset.Columns:= LTileset.Image.Width div LTileset.TileWidth;
    if LTileset.TileCount = 0 then
      LTileset.TileCount:= (LTileset.Image.Height div LTileset.TileHeight) * LTileset.Columns;
    if (LTileset.TileCount > 0) and (LTileset.Columns > 0) then
    begin
      LImage:= TBitmap.Create;
      LImage.LoadFromFile(LTileset.Image.Source);
      LTileset.RendererData:= LImage;
    end;
  end;
end;

procedure TTiledRender.Render(const ACanvas: TCanvas);
  function ChunkRenderRect(const ATileset: TTiled.TTileset; const AFrame: Integer): TRectF;
  var
    LFullWidth, LFullHeight: Integer;
  begin
    LFullWidth   := ATileset.TileWidth  + ATileset.Spacing;
    LFullHeight  := ATileset.TileHeight + ATileset.Spacing;
    Result.Left  := AFrame mod ATileset.Columns * LFullWidth  + ATileset.Margin;
    Result.Top   := AFrame div ATileset.Columns * LFullHeight + ATileset.Margin;
    Result.Width := ATileset.TileWidth;
    Result.Height:= ATileset.TileHeight;
  end;

  procedure RenderTile(const ALayer: TTiled.TLayer; const AX, AY, ADataIndex: Integer);
  var
    LTileset: TTiled.TTileset;
    LFrame: Integer;
    LHorzFlip, LVertFlip, LDiagonalFlip: Boolean;
    LImage: TBitmap;
    LRect: TRectF;
  begin
    if FMap.RequireTileRenderData(Point(AX, AY), ADataIndex, ALayer, LTileset,
      LFrame, LHorzFlip, LVertFlip, LDiagonalFlip) then
    begin
      if LTileset.RendererData = nil then Exit;
      //
      LImage:= TBitmap(LTileset.RendererData);
      LRect:= ChunkRenderRect(LTileset, LFrame);
      ACanvas.DrawBitmap(LImage, LRect,
        RectF(AX*LTileset.TileWidth,
              AY*LTileset.TileHeight,
              AX*LTileset.TileWidth+LTileset.TileWidth,
              AY*LTileset.TileHeight+LTileset.TileHeight), 1.0);
    end;
  end;
var
  X, Y, LDataIndex: Integer;
  LLayer: TTiled.TLayer;
begin
  if not (Assigned(ACanvas) and Assigned(FMap))then 
    Exit;
  //
  ACanvas.Fill.Color:= FMap.BackgroundColor;
  ACanvas.FillRect(RectF(0, 0, ACanvas.Width, ACanvas.Height), 0, 0, AllCorners, 1.0);

  for LLayer in FMap.Layers do
  begin
    if not LLayer.Visible then 
      Continue;
    if (LLayer is TTiled.TObjectGroupLayer) or (LLayer is TTiled.TImageLayer) then
      Continue;

    // TODO: use FMap.RenderOrder
    LDataIndex:= 0;
    for Y:= 0 to FMap.Height - 1 do
      for X:= 0 to FMap.Width - 1 do
      begin
        RenderTile(LLayer, X, Y, LDataIndex);
        Inc(LDataIndex);
      end;
  end;

  if FObjectsVisible then RenderObjects;
end;

procedure TTiledRender.RenderObjects;
var
  LLayer: TTiled.TLayer;
begin
  for LLayer in FMap.Layers do
  begin

  end;
end;

end.
