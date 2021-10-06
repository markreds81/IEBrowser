unit FUBrowser;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleCtrls, SHDocVw;

type
  TFBrowser = class(TForm)
    WebBrowser: TWebBrowser;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    procedure WMSysCommand(var AMessage: TMessage); message WM_SYSCOMMAND;
    function GetUrl: String;
    procedure SetUrl(AUrl: String);
  protected
    procedure CreateParams(var AParams: TCreateParams); override;
  public
    property Url: String read GetUrl write SetUrl;
  end;

var
  FBrowser: TFBrowser;

implementation

uses
  FUMain, FUAbout, FUInfo, ShellApi;

const
  ID_MENU_MAIN = Word(-100);
  ID_MENU_SHOW_INFO = Word(-101);
  ID_MENU_INTERNET_OPTIONS = Word(-102);
  ID_MENU_ABOUT = Word(-110);

{$R *.dfm}

procedure TFBrowser.FormClose(Sender: TObject; var Action: TCloseAction);
var
  I, VisibleCount: Integer;
begin
  Action:= caFree;
  VisibleCount:= 0;

  for I:= 0 to Screen.FormCount - 1 do
    if Screen.Forms[I].Visible then
      VisibleCount:= VisibleCount + 1;

  if VisibleCount = 1 then
    Application.Terminate;
end;

procedure TFBrowser.WMSysCommand(var AMessage: TMessage);
begin
  case AMessage.WParam of
    ID_MENU_MAIN:
      FMain.Show;
    ID_MENU_SHOW_INFO:
      begin
        FInfo.Url:= WebBrowser.LocationURL;
        FInfo.ShowModal;
      end;
    ID_MENU_INTERNET_OPTIONS:
      ShellExecute(Handle, nil, PChar('inetcpl.cpl'), nil, nil, SW_SHOWNORMAL);
    ID_MENU_ABOUT:
      FAbout.ShowModal;
  end;

  inherited;
end;

procedure TFBrowser.FormCreate(Sender: TObject);
var
  SysMenu: THandle;
begin
  SysMenu:= GetSystemMenu(Handle, False);
  AppendMenu(SysMenu, MF_SEPARATOR, Word(-1), '');
  AppendMenu(SysMenu, MF_BYPOSITION, ID_MENU_MAIN, 'New Session');
  AppendMenu(SysMenu, MF_BYPOSITION, ID_MENU_SHOW_INFO, 'Show info');
  AppendMenu(SysMenu, MF_BYPOSITION, ID_MENU_INTERNET_OPTIONS, 'Internet Options');
  AppendMenu(SysMenu, MF_SEPARATOR, Word(-1), '');
  AppendMenu(SysMenu, MF_BYPOSITION, ID_MENU_ABOUT, 'About IEBrowser');
end;

function TFBrowser.GetUrl: String;
begin
  Result:= WebBrowser.LocationURL;
end;

procedure TFBrowser.SetUrl(AUrl: String);
begin
  WebBrowser.Navigate(AUrl);
end;

procedure TFBrowser.CreateParams(var AParams: TCreateParams);
begin
  inherited CreateParams(AParams);
  AParams.ExStyle:= AParams.ExStyle or WS_EX_APPWINDOW;
  AParams.WndParent:= GetDesktopWindow;
end;

end.
