unit FUInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  TFInfo = class(TForm)
    Label1: TLabel;
    UrlField: TEdit;
    CopyButton: TSpeedButton;
    ButtonClose: TButton;
    procedure CopyButtonClick(Sender: TObject);
  private
    function GetUrl: String;
    procedure SetUrl(AUrl: String);
  public
    property Url: String read GetUrl write SetUrl;
  end;

var
  FInfo: TFInfo;

implementation

uses
  Clipbrd;

{$R *.dfm}

{ TFInfo }

function TFInfo.GetUrl: String;
begin
  Result:= UrlField.Text;
end;

procedure TFInfo.SetUrl(AUrl: String);
begin
  UrlField.Text:= AUrl;
end;

procedure TFInfo.CopyButtonClick(Sender: TObject);
begin
  Clipboard.AsText:= UrlField.Text;
  ShowMessage('Copied to clipboard!');
end;

end.
