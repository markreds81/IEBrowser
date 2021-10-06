program IEBrowser;

uses
  Forms,
  FUMain in 'FUMain.pas' {FMain},
  FUBrowser in 'FUBrowser.pas' {FBrowser},
  FUHidden in 'FUHidden.pas' {FHidden},
  WinUtils in 'WinUtils.pas',
  FUAbout in 'FUAbout.pas' {FAbout},
  DefaultsDb in 'DefaultsDb.pas',
  FUInfo in 'FUInfo.pas' {FInfo};

{$R *.res}

begin
  Application.Initialize;

  EnableExtendedStyleApplication(True);

  Application.Title := 'IEBrowser';
  Application.CreateForm(TFHidden, FHidden);
  Application.CreateForm(TFMain, FMain);
  Application.CreateForm(TFAbout, FAbout);
  Application.CreateForm(TFInfo, FInfo);
  Application.ShowMainForm:= False;
  Application.Run;
end.
