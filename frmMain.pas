unit frmMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, tiled.parser, tiled.render, FMX.Edit;

type
  TMainFrm = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
    procedure Button1Click(Sender: TObject);
  private
    FMapParser: TTiledParser;
    FMapRender: TTiledRender;
  public
    { Public declarations }
  end;

var
  MainFrm: TMainFrm;

implementation

{$R *.fmx}

procedure TMainFrm.Button1Click(Sender: TObject);
begin
  FMapParser.LoadFromFile(Edit1.Text);
  FMapRender.Map:= FMapParser.Map;
end;

procedure TMainFrm.FormCreate(Sender: TObject);
begin
  FMapParser:= TTiledParser.Create;
  FMapRender:= TTiledRender.Create;
end;

procedure TMainFrm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FMapParser);
  FreeAndNil(FMapRender);
end;

procedure TMainFrm.FormPaint(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
begin
  FMapRender.Render(Canvas);
  Self.Invalidate;
end;

end.
