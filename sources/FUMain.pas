unit FUMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleCtrls, Menus, StdCtrls, ComCtrls;

type
  TFMain = class(TForm)
    PageControl1: TPageControl;
    SessionTab: TTabSheet;
    OpenButton: TButton;
    CancelButton: TButton;
    AboutButton: TButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    HostnameField: TEdit;
    Label2: TLabel;
    ProtocolField: TComboBox;
    Label3: TLabel;
    UpDown: TUpDown;
    PortField: TEdit;
    GroupBox2: TGroupBox;
    SessionList: TListBox;
    NameField: TEdit;
    LoadButton: TButton;
    SaveButton: TButton;
    DeleteButton: TButton;
    SettingsTab: TTabSheet;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure OpenButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure AboutButtonClick(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DeleteButtonClick(Sender: TObject);
    procedure LoadButtonClick(Sender: TObject);
    procedure SessionListDblClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure HostnameFieldKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure PortFieldKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    procedure OpenBrowser(const ACaption: string = '');
  protected
    procedure CreateParams(var AParams: TCreateParams); override;
  public
    { Public declarations }
  end;

var
  FMain: TFMain;

implementation

uses
  WinUtils, FUHidden, FUBrowser, FUAbout, TypInfo;

const
  FOLDER_SAVED = 'saved';

{$R *.dfm}

procedure TFMain.FormClose(Sender: TObject; var Action: TCloseAction);
var
  I, VisibleCount: Integer;
begin
  Action:= caHide;
  VisibleCount:= 0;

  for I:= 0 to Screen.FormCount - 1 do
    if Screen.Forms[I].Visible then
      VisibleCount:= VisibleCount + 1;

  if VisibleCount = 1 then
    FHidden.Close;
end;

procedure TFMain.CreateParams(var AParams: TCreateParams);
begin
  inherited CreateParams(AParams);
  AParams.ExStyle:= AParams.ExStyle or WS_EX_APPWINDOW;
  AParams.WndParent:= GetDesktopWindow;
end;

procedure TFMain.OpenBrowser(const ACaption: string = '');
var
  Browser: TFBrowser;
begin
  Application.CreateForm(TFBrowser, Browser);
  Browser.Url:= LowerCase(ProtocolField.Text) + '://' + HostnameField.Text + ':' + PortField.Text;
  if ACaption <> '' then
    Browser.Caption:= ACaption + ' - IEBrowser'
  else
    Browser.Caption:= HostnameField.Text + ' - IEBrowser';
  Browser.Show;
  Hide;
end;

procedure TFMain.OpenButtonClick(Sender: TObject);
begin
  OpenBrowser;  // open a new browser with current settings
end;

procedure TFMain.CancelButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TFMain.AboutButtonClick(Sender: TObject);
begin
  FAbout.ShowModal;
end;

procedure TFMain.SaveButtonClick(Sender: TObject);
var
  Index: Integer;
  FileName: string;
  Dict: TStringList;
begin
  if Trim(HostnameField.Text) = '' then
  begin
    MessageDlg('Hostname cannot be empty.', mtError, [mbOk], 0);
    HostnameField.SetFocus;
  end
  else if Trim(NameField.Text) = '' then
  begin
    MessageDlg('Session name cannot be empty.', mtError, [mbOk], 0);
    NameField.SetFocus;
  end
  else
  begin
    Index:= SessionList.Items.IndexOf(NameField.Text);
    if (Index >= 0) and (MessageDlg('Session name already exists. Overwrite it?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes) then
    begin
      Dict:= TStringList(SessionList.Items.Objects[Index]);
      FileName:= IncludeTrailingPathDelimiter(GetDataFolder) + FOLDER_SAVED + PathDelim + Dict.Values['Name'] + '.txt';
      if FileExists(FileName) then
        DeleteFile(FileName);
      Dict.Free;
      SessionList.Items.Delete(Index);
    end;
    FileName:= IncludeTrailingPathDelimiter(GetDataFolder) + FOLDER_SAVED;
    if not ForceDirectories(FileName) then
      MessageDlg('Cannot create folder: ' + FileName, mtError, [mbOk], 0)
    else
    begin
      FileName:= FileName + PathDelim + NameField.Text + '.txt';
      Dict:= TStringList.Create;
      Dict.Values['Name']:= NameField.Text;
      Dict.Values['Protocol']:= ProtocolField.Text;
      Dict.Values['Hostname']:= HostnameField.Text;
      Dict.Values['Port']:= PortField.Text;
      try
        Dict.SaveToFile(FileName);
      except
        on E: Exception do MessageDlg(E.Message, mtError, [mbOk], E.HelpContext);
      end;
      SessionList.AddItem(Dict.Values['Name'], Dict);
    end;
  end
end;

procedure TFMain.FormCreate(Sender: TObject);
var
  Style: Integer;
  Path: String;
  Dict: TStringList;
  SearchRec: TSearchRec;
begin
  // setup Port Tedit to accepts numbers only
  Style:= GetWindowLong(PortField.Handle, GWL_STYLE);
  SetWindowLong(PortField.Handle, GWL_STYLE, Style or ES_NUMBER);

  // check data folder for saved sessions
  Path:= GetDataFolder;
  if not DirectoryExists(Path) then
  begin
    ForceDirectories(Path);
    Path:= IncludeTrailingPathDelimiter(Path) + FOLDER_SAVED;
    ForceDirectories(Path);
  end
  else
  begin
    Path:= IncludeTrailingPathDelimiter(Path) + FOLDER_SAVED + PathDelim;
    if FindFirst(Path + '*.txt', faArchive, SearchRec) = 0 then
    begin
      repeat
        Dict:= TStringList.Create;
        try
          Dict.LoadFromFile(Path + SearchRec.Name);
          SessionList.AddItem(Dict.Values['Name'], Dict);
        except
          on E:Exception do MessageDlg(E.Message, mtError, [mbOk], E.HelpContext);
        end;
      until FindNext(SearchRec) <> 0;
      FindClose(SearchRec);
    end
  end;
end;

procedure TFMain.DeleteButtonClick(Sender: TObject);
var
  Index: Integer;
  FileName: String;
begin
  Index:= SessionList.ItemIndex;
  if Index < 0 then
  begin
    MessageDlg('Select the session to delete from list.', mtError, [mbOk], 0);
    SessionList.SetFocus;
  end
  else
  begin
    FileName:= IncludeTrailingPathDelimiter(GetDataFolder) + FOLDER_SAVED + PathDelim + SessionList.Items[Index] + '.txt';
    if DeleteFile(FileName) then
    with SessionList do
    begin
      Items.Objects[ItemIndex].Free;
      SessionList.DeleteSelected;
    end
  end
end;

procedure TFMain.LoadButtonClick(Sender: TObject);
var
  Index: Integer;
  FileName: String;
  Dict: TStringList;
begin
  Index:= SessionList.ItemIndex;
  if Index < 0 then
  begin
    MessageDlg('Select the session to load from list.', mtError, [mbOk], 0);
    SessionList.SetFocus;
  end
  else
  begin
    FileName:= IncludeTrailingPathDelimiter(GetDataFolder) + FOLDER_SAVED + PathDelim + SessionList.Items[Index] + '.txt';
    Dict:= TStringList.Create;
    try
      Dict.LoadFromFile(FileName);
      ProtocolField.Text:= Dict.Values['Protocol'];
      HostnameField.Text:= Dict.Values['Hostname'];
      PortField.Text:= Dict.Values['Port'];
      OpenBrowser(Dict.Values['Name']); // open browser window with loaded values
    finally
      Dict.Free;
    end
  end
end;

procedure TFMain.SessionListDblClick(Sender: TObject);
begin
  LoadButtonClick(Sender);
end;

procedure TFMain.FormDestroy(Sender: TObject);
var
  I: Integer;
begin
  for I:= 0 to SessionList.Count - 1 do
    SessionList.Items.Objects[I].Free;
end;

procedure TFMain.HostnameFieldKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    OpenBrowser;
end;

procedure TFMain.PortFieldKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    OpenBrowser;
end;

end.
