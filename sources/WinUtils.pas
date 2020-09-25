unit WinUtils;

interface

uses
  Windows, Forms, Controls, Classes, Messages, Graphics;

const
  VistaFont = 'Segoe UI';
  VistaContentFont = 'Calibri';
  XPContentFont = 'Verdana';
  XPFont = 'Tahoma';

  TD_ICON_BLANK = 0;
  TD_ICON_WARNING = 84;
  TD_ICON_QUESTION = 99;
  TD_ICON_ERROR = 98;
  TD_ICON_INFORMATION = 81;
  TD_ICON_SHIELD_QUESTION = 104;
  TD_ICON_SHIELD_ERROR = 105;
  TD_ICON_SHIELD_OK = 106;
  TD_ICON_SHIELD_WARNING = 107;

  TD_BUTTON_OK = 1;
  TD_BUTTON_YES = 2;
  TD_BUTTON_NO = 4;
  TD_BUTTON_CANCEL = 8;
  TD_BUTTON_RETRY = 16;
  TD_BUTTON_CLOSE = 32;

  TD_RESULT_OK = 1;
  TD_RESULT_CANCEL = 2;
  TD_RESULT_RETRY = 4;
  TD_RESULT_YES = 6;
  TD_RESULT_NO = 7;
  TD_RESULT_CLOSE = 8;

  TD_IDS_WINDOWTITLE = 10;
  TD_IDS_CONTENT = 11;
  TD_IDS_MAININSTRUCTION = 12;
  TD_IDS_VERIFICATIONTEXT = 13;
  TD_IDS_FOOTER = 15;
  TD_IDS_RB_GOOD = 16;
  TD_IDS_RB_OK = 17;
  TD_IDS_RB_BAD = 18;
  TD_IDS_CB_SAVE = 19;

type
  PBoolean = ^Boolean;

  TFileInfoLangAndCP = record
    wLanguage: Word;
    wCodePage: Word;
  end;

  PFileInfoLangAndCP = ^TFileInfoLangAndCP;

  TApplicationInformation = record
    CompanyName: string;
    FileDescription: string;
    FileVersion: string;
    Internalname: string;
    LegalCopyright: string;
    LegalTradeMarks: string;
    OriginalFilename: string;
    ProductName: string;
    ProductVersion: string;
    Comments: string;
    MajorVersion: Integer;
    MinorVersion: Integer;
    Release: Integer;
    Build: Integer;
  end;

  TTASKDIALOG_BUTTON = packed record
    nButtonId: Integer;
    pszButtonText: PWideChar;
  end;

  TTASKDIALOG_BUTTONS = array of TTASKDIALOG_BUTTON;

  TExtendedForm = class(TForm)
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TExtendedMainForm = class(TForm)
  private
    procedure DoApplicationMinimize(Sender: TObject);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WMSysCommand(var Msg: TMessage); message WM_SYSCOMMAND;
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  CheckOSVerForFonts: Boolean = True;
  ExtendedStyle: Integer;
  ExtendedMainForm: TExtendedMainForm;

function GetApplicationInfo: TApplicationInformation;
function GetDataFolder: String;
function IsWindowsVista: Boolean;
procedure EnableExtendedStyleApplication(const AAlways: Boolean);
procedure SetVistaFonts(const AForm: TCustomForm);
procedure SetVistaContentFonts(const AFont: TFont);
procedure SetVistaTreeView(const AHandle: THandle);
procedure SetDesktopIconFonts(const AFont: TFont);
function CompositingEnabled: Boolean;
procedure ExtendGlass(const AHandle: THandle; const AMargins: TRect);
function OpenSaveFileDialog(Parent: TWinControl; const DefExt, Filter, InitialDir, Title: string; var FileName: string; MustExist, OverwritePrompt, NoChangeDir, DoOpen: Boolean): Boolean;
function TaskDialog(Parent: TCustomForm; const Title, Description, Content: string; const Icon, Buttons: integer): Integer;
procedure TaskMessage(Parent: TCustomForm; const Msg: string);
function GetSystemDirectory: string;
function GetWindowsDirectory: string;
function GetTempDirectory: string;
function GetApplicationDirectory: string;
function GetRoamingUserAppDataDirectory: string;
function GetLocalUserAppDataDirectory: string;
function GetRoamingApplicationDataDirectory: string;
function GetLocalApplicationDataDirectory: string;
function ChangeRoamingApplicationDataFileExt(const AFileName, AExtension: string): string;
function ChangeLocalApplicationDataFileExt(const AFileName, AExtension: string): string;
function ExecuteCommand(const ACommandFileName, ACommandArguments, ACommandStdInput, ACommandStdOutput, ACommandStdError: string): Boolean;

implementation

uses
  SysUtils, UxTheme, CommDlg, Dialogs, SHFolder;

const
  dwmapi = 'dwmapi.dll';
  DwmIsCompositionEnabledSig = 'DwmIsCompositionEnabled';
  DwmExtendFrameIntoClientAreaSig = 'DwmExtendFrameIntoClientArea';
  TaskDialogSig = 'TaskDialog';

function GetApplicationInfo: TApplicationInformation;
var
  VersionSize, ValueAsInt, Len, LangLen: Cardinal;
  Buf: PChar;
  LangData: PFileInfoLangAndCP;
  SubBlock, Version: string;
  ValueAsPChar: PChar;
  PosIndex: Integer;
begin
  {Inizializza la struttura risultato}
  Result.CompanyName:= '';
  Result.FileDescription:= '';
  Result.FileVersion:= '';
  Result.Internalname:= '';
  Result.LegalCopyright:= '';
  Result.LegalTradeMarks:= '';
  Result.OriginalFilename:= '';
  Result.ProductName:= '';
  Result.ProductVersion:= '';
  Result.Comments:= '';
  Result.MajorVersion:= -1;
  Result.MinorVersion:= -1;
  Result.Release:= -1;
  Result.Build:= -1;

  {Preleva le info dal file Exe}
  try
    VersionSize:= GetFileVersionInfoSize(PChar(Application.ExeName), ValueAsInt);
    if VersionSize > 0 then
    begin
      Buf:= AllocMem(VersionSize);
      try
        GetFileVersionInfo(PChar(ParamStr(0)), 0, VersionSize, Buf);
        VerQueryValue(Buf, PChar('\\VarFileInfo\\Translation'), Pointer(LangData), LangLen);

        {CompanyName}
        SubBlock:= Format('\\StringFileInfo\\%.4x%.4x\\CompanyName', [LangData^.wLanguage, LangData^.wCodePage]);
        VerQueryValue(Buf, PChar(SubBlock), Pointer(ValueAsPChar), Len);
        Result.CompanyName:= ValueAsPChar;

        {FileDescription}
        SubBlock:= Format('\\StringFileInfo\\%.4x%.4x\\FileDescription', [LangData^.wLanguage, LangData^.wCodePage]);
        VerQueryValue(Buf, PChar(SubBlock), Pointer(ValueAsPChar), Len);
        Result.FileDescription:= ValueAsPChar;

        {FileVersion}
        SubBlock:= Format('\\StringFileInfo\\%.4x%.4x\\FileVersion', [LangData^.wLanguage, LangData^.wCodePage]);
        VerQueryValue(Buf, PChar(SubBlock), Pointer(ValueAsPChar), Len);
        Result.FileVersion:= ValueAsPChar;

        {InternalName}
        SubBlock:= Format('\\StringFileInfo\\%.4x%.4x\\InternalName', [LangData^.wLanguage, LangData^.wCodePage]);
        VerQueryValue(Buf, PChar(SubBlock), Pointer(ValueAsPChar), Len);
        Result.InternalName:= ValueAsPChar;

        {LegalCopyright}
        SubBlock:= Format('\\StringFileInfo\\%.4x%.4x\\LegalCopyright', [LangData^.wLanguage, LangData^.wCodePage]);
        VerQueryValue(Buf, PChar(SubBlock), Pointer(ValueAsPChar), Len);
        Result.LegalCopyright:= ValueAsPChar;

        {LegalTradeMarks}
        SubBlock:= Format('\\StringFileInfo\\%.4x%.4x\\LegalTradeMarks', [LangData^.wLanguage, LangData^.wCodePage]);
        VerQueryValue(Buf, PChar(SubBlock), Pointer(ValueAsPChar), Len);
        Result.LegalTradeMarks:= ValueAsPChar;

        {OriginalFilename}
        SubBlock:= Format('\\StringFileInfo\\%.4x%.4x\\OriginalFilename', [LangData^.wLanguage, LangData^.wCodePage]);
        VerQueryValue(Buf, PChar(SubBlock), Pointer(ValueAsPChar), Len);
        Result.OriginalFilename:= ValueAsPChar;

        {ProductName}
        SubBlock:= Format('\\StringFileInfo\\%.4x%.4x\\ProductName', [LangData^.wLanguage, LangData^.wCodePage]);
        VerQueryValue(Buf, PChar(SubBlock), Pointer(ValueAsPChar), Len);
        Result.ProductName:= ValueAsPChar;

        {ProductVersion}
        SubBlock:= Format('\\StringFileInfo\\%.4x%.4x\\ProductVersion', [LangData^.wLanguage, LangData^.wCodePage]);
        VerQueryValue(Buf, PChar(SubBlock), Pointer(ValueAsPChar), Len);
        Result.ProductVersion:= ValueAsPChar;

        {Comments}
        SubBlock:= Format('\\StringFileInfo\\%.4x%.4x\\Comments', [LangData^.wLanguage, LangData^.wCodePage]);
        VerQueryValue(Buf, PChar(SubBlock), Pointer(ValueAsPChar), Len);
        Result.Comments:= ValueAsPChar;

        {MajorVersion, MinorVersion, Release, Build}
        if Result.FileVersion <> '' then
        begin
          Version:= StringReplace(Result.FileVersion, ',', '.', [rfReplaceAll]);
          PosIndex:= Pos('.', Version);
          if PosIndex > 0 then
          begin
            Result.MajorVersion:= StrToIntDef(Copy(Version, 1, PosIndex - 1), 0);
            Version:= Copy(Version, PosIndex + 1, Length(Version) - PosIndex);
            PosIndex:= Pos('.', Version);
            Result.MinorVersion:= StrToIntDef(Copy(Version, 1, PosIndex - 1), 0);
            Version:= Copy(Version, PosIndex + 1, Length(Version) - PosIndex);
            PosIndex:= Pos('.', Version);
            Result.Release:= StrToIntDef(Copy(Version, 1, PosIndex - 1), 0);
            Result.Build:= StrToIntDef(Copy(Version, PosIndex + 1, Length(Version) - PosIndex), 0);
          end;
        end;
      finally
        FreeMem(Buf, VersionSize);
      end;
    end;
  except
  end;
end;

function GetDataFolder: String;
var
  path: array[0..MAX_PATH] of Char;
begin
  if SHGetFolderPath(0, CSIDL_APPDATA, 0, CSIDL_LOCAL_APPDATA, path) = S_OK then
    Result:= IncludeTrailingPathDelimiter(Path) + ChangeFileExt(ExtractFileName(Application.ExeName), '')
  else
    Result:= ExtractFilePath(Application.ExeName);
end;

{ IsWindowsVista: return True if Windows OS if Vista o greater}
function IsWindowsVista: Boolean;
var
  VerInfo: TOSVersioninfo;
begin
  VerInfo.dwOSVersionInfoSize:= SizeOf(TOSVersionInfo);
  GetVersionEx(VerInfo);
  Result:= (VerInfo.dwMajorVersion >= 6);
end;

procedure EnableExtendedStyleApplication(const AAlways: Boolean);
begin
  if AAlways or IsWindowsVista then
  begin
    ExtendedStyle:= GetWindowLong(Application.Handle, GWL_EXSTYLE);
    SetWindowLong(Application.Handle, GWL_EXSTYLE, ExtendedStyle or WS_EX_TOOLWINDOW and not WS_EX_APPWINDOW);
  end;
end;

{ SetVistaFonts: parameter must be a Form}
procedure SetVistaFonts(const AForm: TCustomForm);
begin
  if (IsWindowsVista or not CheckOSVerForFonts) and not SameText(AForm.Font.Name, VistaFont) and (Screen.Fonts.IndexOf(VistaFont) >= 0) then
  begin
    AForm.Font.Size:= AForm.Font.Size + 1;
    AForm.Font.Name:= VistaFont;
  end;
end;

{ SetVistaContentFonts: parameter must be something like Memo.Font for memos,
  Richedits, etc...}
procedure SetVistaContentFonts(const AFont: TFont);
begin
  if (IsWindowsVista or not CheckOSVerForFonts) and not SameText(AFont.Name, VistaContentFont) and (Screen.Fonts.IndexOf(VistaContentFont) >= 0) then
  begin
    AFont.Size:= AFont.Size + 2;
    AFont.Name:= VistaContentFont;
  end;
end;

{ SetVistaTreeView: handle must be a handle of a treeview component eg,
  TreeView.Handle}
procedure SetVistaTreeView(const AHandle: THandle);
begin
  if IsWindowsVista then
    SetWindowTheme(AHandle, 'explorer', nil);
end;

procedure SetDefaultFonts(const AFont: TFont);
begin
  AFont.Handle := GetStockObject(DEFAULT_GUI_FONT);
end;

{ SetDesktopIconFonts: set default font to be the same as the desktop icons
  font otherwise, uses default windows font }
procedure SetDesktopIconFonts(const AFont: TFont);
var
  LogFont: TLogFont;
begin
  if SystemParametersInfo(SPI_GETICONTITLELOGFONT, SizeOf(LogFont), @LogFont, 0) then
    AFont.Handle:= CreateFontIndirect(LogFont)
  else
    SetDefaultFonts(AFont);
end;

function CompositingEnabled: Boolean;
var
  DLLHandle: THandle;
  DwmIsCompositionEnabledProc: function(pfEnabled: PBoolean): HRESULT; stdcall;
  Enabled: Boolean;
begin
  Result:= False;
  if IsWindowsVista then
  begin
    DLLHandle:= LoadLibrary(dwmapi);
    if DLLHandle <> 0 then
    begin
      @DwmIsCompositionEnabledProc:= GetProcAddress(DLLHandle, DwmIsCompositionEnabledSig);
      if (@DwmIsCompositionEnabledProc <> nil) then
      begin
        DwmIsCompositionEnabledProc(@Enabled);
        Result:= Enabled;
      end;
      FreeLibrary(DLLHandle);
    end;
  end;
end;

{ ExtendGlass: from http://www.delphipraxis.net/topic93221,next.html}
procedure ExtendGlass(const AHandle: THandle; const AMargins: TRect);
type
  _MARGINS = packed record
    cxLeftWidth: Integer;
    cxRightWidth: Integer;
    cyTopHeight: Integer;
    cyBottomHeight: Integer;
  end;
  PMargins = ^_MARGINS;
  TMargins = _MARGINS;
var
  DLLHandle: THandle;
  DwmExtendFrameIntoClientAreaProc: function(destWnd: HWND; const pMarInset: PMargins): HRESULT; stdcall;
  Margins: TMargins;
begin
  if IsWindowsVista and CompositingEnabled then
  begin
    DLLHandle:= LoadLibrary(dwmapi);
    if DLLHandle <> 0 then
    begin
      @DwmExtendFrameIntoClientAreaProc := GetProcAddress(DLLHandle, DwmExtendFrameIntoClientAreaSig);
      if (@DwmExtendFrameIntoClientAreaProc <> nil) then
      begin
        ZeroMemory(@Margins, SizeOf(Margins));
        Margins.cxLeftWidth := AMargins.Left;
        Margins.cxRightWidth := AMargins.Right;
        Margins.cyTopHeight := AMargins.Top;
        Margins.cyBottomHeight := AMargins.Bottom;
        DwmExtendFrameIntoClientAreaProc(AHandle, @Margins);
      end;
      FreeLibrary(DLLHandle);
    end;
  end;
end;

function ReplaceStr(Str, SearchStr, ReplaceStr: string): string;
begin
  while Pos(SearchStr, Str) <> 0 do
  begin
    Insert(ReplaceStr, Str, Pos(SearchStr, Str));
    System.Delete(Str, Pos(SearchStr, Str), Length(SearchStr));
  end;
  Result := Str;
end;

function OpenSaveFileDialog(Parent: TWinControl; const DefExt, Filter,
  InitialDir, Title: string; var FileName: string; MustExist, OverwritePrompt,
  NoChangeDir, DoOpen: Boolean): Boolean;
var
  ofn: TOpenFileName;
  szFile: array[0..MAX_PATH] of Char;
begin
  Result:= False;
  FillChar(ofn, SizeOf(TOpenFileName), 0);
  with ofn do
  begin
    lStructSize := SizeOf(TOpenFileName);
    hwndOwner := Parent.Handle;
    lpstrFile := szFile;
    nMaxFile := SizeOf(szFile);
    if (Title <> '') then
      lpstrTitle := PChar(Title);
    if (InitialDir <> '') then
      lpstrInitialDir := PChar(InitialDir);
    StrPCopy(lpstrFile, FileName);
    lpstrFilter := PChar(ReplaceStr(Filter, '|', #0)+#0#0);
    if DefExt <> '' then
      lpstrDefExt := PChar(DefExt);
  end;

  if MustExist then ofn.Flags := ofn.Flags or OFN_FILEMUSTEXIST;
  if OverwritePrompt then ofn.Flags := ofn.Flags or OFN_OVERWRITEPROMPT;
  if NoChangeDir then ofn.Flags := ofn.Flags or OFN_NOCHANGEDIR;

  if DoOpen then
  begin
    if GetOpenFileName(ofn) then
    begin
      Result := True;
      FileName := StrPas(szFile);
    end;
  end
  else
  begin
    if GetSaveFileName(ofn) then
    begin
      Result := True;
      FileName := StrPas(szFile);
    end;
  end
end;

{ TaskDialog: from http://www.tmssoftware.com/atbdev5.htm}
function TaskDialog(Parent: TCustomForm; const Title, Description,
  Content: string; const Icon, Buttons: integer): Integer;
label normal;
var
  DLLHandle: THandle;
  res: integer;
  assignprob : boolean;
  S, Dmy: string;
  wTitle, wDescription, wContent: array[0..1024] of widechar;
  Btns: TMsgDlgButtons;
  DlgType: TMsgDlgType;
  TaskDialogProc: function(HWND: THandle; hInstance: THandle; cTitle,
    cDescription, cContent: pwidechar; Buttons: Integer; Icon: integer;
    ResButton: pinteger): Integer; cdecl stdcall;
begin
  Result := 0;
  assignprob := false;
  if IsWindowsVista then
  begin
    DLLHandle := LoadLibrary(comctl32);
    if DLLHandle >= 32 then
    begin
      @TaskDialogProc := GetProcAddress(DLLHandle, TaskDialogSig);

      // mbb(assigned(taskdialogproc));

      if Assigned(TaskDialogProc) then
      begin
        StringToWideChar(Title, wTitle, SizeOf(wTitle));
        StringToWideChar(Description, wDescription, SizeOf(wDescription));

        //Get rid of line breaks, may be here for backwards compat but not
        //needed with Task Dialogs
        S := StringReplace(Content, #10, '', [rfReplaceAll]);
        S := StringReplace(S, #13, '', [rfReplaceAll]);
        StringToWideChar(S, wContent, SizeOf(wContent));

        TaskDialogProc(Parent.Handle, 0, wTitle, wDescription, wContent, Buttons, Icon, @res);

        Result := mrOK;

        case res of
          TD_RESULT_CANCEL : Result := mrCancel;
          TD_RESULT_RETRY : Result := mrRetry;
          TD_RESULT_YES : Result := mrYes;
          TD_RESULT_NO : Result := mrNo;
          TD_RESULT_CLOSE : Result := mrAbort;
        end;
      end
      else assignprob := true;
     FreeLibrary(DLLHandle);
     // mySysError;
     if assignprob then goto normal;
    end;
  end else
  begin
    normal:
    Btns := [];
    if Buttons and TD_BUTTON_OK = TD_BUTTON_OK then
      Btns := Btns + [MBOK];

    if Buttons and TD_BUTTON_YES = TD_BUTTON_YES then
      Btns := Btns + [MBYES];

    if Buttons and TD_BUTTON_NO = TD_BUTTON_NO then
      Btns := Btns + [MBNO];

    if Buttons and TD_BUTTON_CANCEL = TD_BUTTON_CANCEL then
      Btns := Btns + [MBCANCEL];

    if Buttons and TD_BUTTON_RETRY = TD_BUTTON_RETRY then
      Btns := Btns + [MBRETRY];

    if Buttons and TD_BUTTON_CLOSE = TD_BUTTON_CLOSE then
      Btns := Btns + [MBABORT];

    DlgType := mtCustom;

    case Icon of
      TD_ICON_WARNING : DlgType := mtWarning;
      TD_ICON_QUESTION : DlgType := mtConfirmation;
      TD_ICON_ERROR : DlgType := mtError;
      TD_ICON_INFORMATION: DlgType := mtInformation;
    end;

    Dmy := Description;
    if Content <> '' then
     begin
       if Dmy <> '' then Dmy := Dmy + #$D#$A + #$D#$A;
       Dmy := Dmy + Content;
     end;
    result := MessageDlg(Dmy, DlgType, Btns, 0);
  end;
end;

procedure TaskMessage(Parent: TCustomForm; const Msg: string);
begin
  TaskDialog(Parent, '', '', Msg, TD_ICON_BLANK, TD_BUTTON_OK);
end;

{ TExtendedForm }

constructor TExtendedForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  if IsWindowsVista then
    SetVistaFonts(Self);
end;

procedure TExtendedForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);

  if IsWindowsVista then
    Params.WndParent:= ExtendedMainForm.Handle; //Application.MainForm.Handle;
end;

{ TExtendedMainForm }

constructor TExtendedMainForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  if IsWindowsVista then
  begin
    ExtendedMainForm:= Self;
    Application.OnMinimize:= DoApplicationMinimize;
    SetVistaFonts(Self);
  end;
end;

procedure TExtendedMainForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);

  if IsWindowsVista then
    Params.ExStyle:= Params.ExStyle and not WS_EX_TOOLWINDOW or WS_EX_APPWINDOW;
end;

procedure TExtendedMainForm.DoApplicationMinimize(Sender: TObject);
begin
  if IsWindowsVista then
  begin
    // draw the main form before we minimize it
    ShowWindow(Handle, SW_SHOW); // so Vista can get a thumbnail at startup
    Application.Processmessages;  // allow time for form to be drawn
    ShowWindow(Handle, SW_MINIMIZE);
  end;
end;

procedure TExtendedMainForm.WMSysCommand(var Msg: TMessage);
begin
  if IsWindowsVista then
  begin
    case (Msg.WParam and $FFF0) of
      SC_MINIMIZE, SC_RESTORE, SC_MAXIMIZE:
        begin
          Msg.Result:= DefWindowProc(Self.Handle, Msg.Msg, Msg.WParam, Msg.LParam);
          ShowWindow(Application.Handle, SW_HIDE);
        end;
      else inherited;
     end;
  end
  else inherited;
end;

function GetSystemDirectory: string;
var
  oBuffer: array[0..MAX_PATH - 1] of Char;
  sTemp: string;
begin
  SetString(sTemp, oBuffer, Windows.GetSystemDirectory(oBuffer, MAX_PATH));
  Result:= IncludeTrailingPathDelimiter(sTemp);
end;

function GetWindowsDirectory: string;
var
  oBuffer: array[0..MAX_PATH - 1] of Char;
  sTemp: string;
begin
  SetString(sTemp, oBuffer, Windows.GetWindowsDirectory(oBuffer, MAX_PATH));
  Result:= IncludeTrailingPathDelimiter(sTemp);
end;

function GetTempDirectory: string;
var
  oBuffer: array[0..MAX_PATH - 1] of Char;
  sTemp: string;
begin
  SetString(sTemp, oBuffer, Windows.GetTempPath(MAX_PATH, oBuffer));
  Result:= IncludeTrailingPathDelimiter(sTemp);
end;

function GetApplicationDirectory: string;
var
  sTemp: string;
begin
  sTemp:= ExtractFilePath(Application.ExeName);
  Result:= IncludeTrailingPathDelimiter(sTemp);
end;

function GetRoamingUserAppDataDirectory: string;
var
  oBuffer: array[0..MAX_PATH - 1] of Char;
  sTemp: string;
begin
  Result:= '';
  if SHGetFolderPath(0, CSIDL_APPDATA, 0, 0, oBuffer) = 0 then
  begin
    sTemp:= StrPas(oBuffer);
    Result:= IncludeTrailingPathDelimiter(sTemp);
  end;
end;

function GetLocalUserAppDataDirectory: string;
var
  oBuffer: array[0..MAX_PATH - 1] of Char;
  sTemp: string;
begin
  Result:= '';
  if SHGetFolderPath(0, CSIDL_LOCAL_APPDATA, 0, 0, oBuffer) = 0 then
  begin
    sTemp:= StrPas(oBuffer);
    Result:= IncludeTrailingPathDelimiter(sTemp);
  end;
end;

function GetRoamingApplicationDataDirectory: string;
begin
  Result:= GetRoamingUserAppDataDirectory + Application.Title + '\';
  ForceDirectories(Result);
end;

function GetLocalApplicationDataDirectory: string;
begin
  Result:= GetLocalUserAppDataDirectory + Application.Title + '\';
  ForceDirectories(Result);
end;

function ChangeRoamingApplicationDataFileExt(const AFileName, AExtension: string): string;
var
  sTemp: string;
begin
  sTemp:= ChangeFileExt(AFileName, AExtension);
  sTemp:= ExtractFileName(sTemp);
  Result:= GetRoamingApplicationDataDirectory + sTemp;
end;

function ChangeLocalApplicationDataFileExt(const AFileName, AExtension: string): string;
var
  sTemp: string;
begin
  sTemp:= ChangeFileExt(AFileName, AExtension);
  sTemp:= ExtractFileName(sTemp);
  Result:= GetLocalApplicationDataDirectory + sTemp;
end;

function ExecuteCommand(const ACommandFileName, ACommandArguments,
  ACommandStdInput, ACommandStdOutput, ACommandStdError: string): Boolean;
const
  API_ID = '[function: ExecuteCommand]: ';
var
  hAppProcess, hAppThread, hInputFile, hOutputFile, hErrorFile: THandle;
  oSecAttrs: TSecurityAttributes;
  oStartupInfo: TStartupInfo;
  oProcessInfo: TProcessInformation;
begin
  Result:= False;

  if (ACommandStdInput <> '') and (not FileExists(ACommandStdInput)) then
    raise Exception.CreateFmt('%s Input file %s does not exist', [API_ID, ACommandStdInput]);

  hAppProcess:= 0;
  hAppThread:= 0;
  hInputFile:= 0;
  hOutputFile:= 0;
  hErrorFile:= 0;

  try
    FillChar(oSecAttrs, SizeOf(oSecAttrs), #0);
    oSecAttrs.nLength:= SizeOf(oSecAttrs);
    oSecAttrs.lpSecurityDescriptor:= nil;
    oSecAttrs.bInheritHandle:= TRUE;

    if ACommandStdInput <> '' then
    begin
      hInputFile:= CreateFile(PChar(ACommandStdInput),
                              GENERIC_READ or GENERIC_WRITE,
                              FILE_SHARE_READ or FILE_SHARE_WRITE,
                              @oSecAttrs,
                              OPEN_ALWAYS,
                              FILE_ATTRIBUTE_NORMAL or FILE_FLAG_WRITE_THROUGH,
                              0);
      if hInputFile = INVALID_HANDLE_VALUE then
        raise Exception.CreateFmt('%s WinApi function CreateFile returned an invalid file handle value for the input file %s', [API_ID, ACommandStdInput]);
    end;

    if ACommandStdOutput <> '' then
    begin
      hOutputFile:= CreateFile(PChar(ACommandStdOutput),
                               GENERIC_READ or GENERIC_WRITE,
                               FILE_SHARE_READ or FILE_SHARE_WRITE,
                               @oSecAttrs,
                               CREATE_ALWAYS,
                               FILE_ATTRIBUTE_NORMAL or FILE_FLAG_WRITE_THROUGH,
                               0);
      if hOutputFile = INVALID_HANDLE_VALUE then
        raise Exception.CreateFmt('%s WinApi function CreateFile returned an invalid file handle value for the output file %s', [API_ID,ACommandStdOutput]);
    end;

    if ACommandStdError <> '' then
    begin
      hErrorFile:= CreateFile(PChar(ACommandStdError),
                              GENERIC_READ or GENERIC_WRITE,
                              FILE_SHARE_READ or FILE_SHARE_WRITE,
                              @oSecAttrs,
                              CREATE_ALWAYS,
                              FILE_ATTRIBUTE_NORMAL or FILE_FLAG_WRITE_THROUGH,
                              0);
      if hErrorFile = INVALID_HANDLE_VALUE then
        raise Exception.CreateFmt('%s WinApi function CreateFile returned an invalid file handle value for the error file %s', [API_ID,ACommandStdOutput]);
    end;

    FillChar(oStartupInfo, SizeOf(oStartupInfo), #0);
    oStartupInfo.cb:= SizeOf(oStartupInfo);
    oStartupInfo.dwFlags:= STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
    oStartupInfo.wShowWindow:= SW_HIDE;
    oStartupInfo.hStdInput:= hInputFile;
    oStartupInfo.hStdOutput:= hOutputFile;
    oStartupInfo.hStdError:= hErrorFile;

    Result:= CreateProcess(PChar(ACommandFileName),
                           PChar(ACommandArguments),
                           nil,
                           nil,
                           TRUE,
                           HIGH_PRIORITY_CLASS,
                           nil,
                           nil,
                           oStartupInfo,
                           oProcessInfo);
    if Result then
    begin
      WaitForSingleObject(oProcessInfo.hProcess, INFINITE);
      hAppProcess:= oProcessInfo.hProcess;
      hAppThread:= oProcessInfo.hThread;
    end
    else
      raise Exception.CreateFmt('%s Create process failure', [API_ID]);
  finally
    if hInputFile <> 0 then
      CloseHandle(hInputFile);
    if hOutputFile <> 0 then
      CloseHandle(hOutputFile);
    if hErrorFile <> 0 then
      CloseHandle(hErrorFile);
    if hAppThread <> 0 then
      CloseHandle(hAppThread);
    if hAppProcess <> 0 then
      CloseHandle(hAppProcess);
  end;
end;

end.
