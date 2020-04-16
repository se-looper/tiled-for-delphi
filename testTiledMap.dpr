program testTiledMap;

uses
  System.StartUpCopy,
  FMX.Forms,
  frmMain in 'frmMain.pas' {MainFrm},
  tiled.parser in 'tiled.parser.pas',
  tiled.types in 'tiled.types.pas',
  tiled.utils in 'tiled.utils.pas',
  tiled.render in 'tiled.render.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainFrm, MainFrm);
  Application.Run;
end.
