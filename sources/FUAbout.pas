unit FUAbout;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls;

type
  TFAbout = class(TForm)
    Label1: TLabel;
    Image1: TImage;
    VersionLabel: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    WebLabel: TLabel;
    Label5: TLabel;
    MailLabel: TLabel;
    Label7: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure WebLabelClick(Sender: TObject);
    procedure MailLabelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FAbout: TFAbout;

implementation

uses
  WinUtils, ShellApi;

const
  URL_INFO = 'https://www.markreds.it/iebrowser';
  URL_MAIL = 'mailto:marco@markreds.it';

{$R *.dfm}

procedure TFAbout.FormCreate(Sender: TObject);
var
  AppInfo: TApplicationInformation;
begin
  AppInfo:= GetApplicationInfo;
  VersionLabel.Caption:= Format('Version %d.%d.%d build %d', [AppInfo.MajorVersion, AppInfo.MinorVersion, AppInfo.Release, AppInfo.Build]);
end;

procedure TFAbout.WebLabelClick(Sender: TObject);
begin
  ShellExecute(0, 'open', PChar(URL_INFO), nil, nil, SW_SHOWNORMAL);
  ModalResult:= mrOk;
end;

procedure TFAbout.MailLabelClick(Sender: TObject);
begin
  ShellExecute(0, 'open', PChar(URL_MAIL), nil, nil, SW_SHOWNORMAL);
  ModalResult:= mrOk;
end;

end.
