unit FUHidden;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, XPMan;

type
  TFHidden = class(TForm)
    XPManifest: TXPManifest;
  private
    { Private declarations }
  protected
    procedure CreateParams(var AParams: TCreateParams); override;
  public
    { Public declarations }
  end;

var
  FHidden: TFHidden;

implementation

{$R *.dfm}

{ TFHidden }

procedure TFHidden.CreateParams(var AParams: TCreateParams);
begin
  inherited CreateParams(AParams);
  AParams.ExStyle:= AParams.ExStyle and not WS_EX_APPWINDOW;
  AParams.WndParent:= GetDesktopWindow;
end;

end.
