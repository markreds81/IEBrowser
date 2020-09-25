unit DefaultsDb;

interface

uses
  IniFiles;

type
  TUserDefaults = class(TObject)
  private
    FDefaultsFile: TIniFile;
    FShowStatusBar: Boolean;
    FAutoUpdate: Boolean;
    FIsFirstRun: Boolean;
    procedure LoadDefaults;
    procedure SaveDefaults;
  public
    constructor Create;
    destructor Destroy; override;
    property ShowStatusBar: Boolean read FShowStatusBar write FShowStatusBar;
    property AutoUpdate: Boolean read FAutoUpdate write FAutoUpdate;
    property IsFirstRun: Boolean read FIsFirstRun write FIsFirstRun;
  end;

var
  UserDefaults: TUserDefaults;

implementation

uses
  SysUtils, WinUtils, Forms;

const
  DEFAULTS_KEY_GUI = 'GUI';
  DEFAULTS_KEY_APP = 'APP';

constructor TUserDefaults.Create;
var
  DataPath: string;
begin
  inherited Create;

  DataPath:= GetDataFolder;
  ForceDirectories(DataPath);
  FDefaultsFile:= TIniFile.Create(DataPath + ExtractFileName(ChangeFileExt(Application.ExeName, '.ini')));

  {Defaults}
  FShowStatusBar:= True;
  FAutoUpdate:= True;
  FIsFirstRun:= False;

  {Load defaults from file}
  LoadDefaults;
end;

destructor TUserDefaults.Destroy;
begin
  SaveDefaults;
  FDefaultsFile.Free;
  inherited Destroy;
end;

procedure TUserDefaults.LoadDefaults;
begin
  with FDefaultsFile do
  begin
    FShowStatusBar:= ReadBool(DEFAULTS_KEY_GUI, 'ShowStatusBar', FShowStatusBar);
    FAutoUpdate:= ReadBool(DEFAULTS_KEY_APP, 'AutoUpdate', FAutoUpdate);
    FIsFirstRun:= ReadBool(DEFAULTS_KEY_APP, 'IsFirstRun', FIsFirstRun);
  end;
end;

procedure TUserDefaults.SaveDefaults;
begin
  with FDefaultsFile do
  begin
    WriteBool(DEFAULTS_KEY_GUI, 'ShowStatusBar', FShowStatusBar);
    WriteBool(DEFAULTS_KEY_APP, 'AutoUpdate', FAutoUpdate);
    WriteBool(DEFAULTS_KEY_APP, 'IsFirstRun', FIsFirstRun);

    UpdateFile;
  end;
end;

initialization
  UserDefaults:= TUserDefaults.Create;

finalization
  FreeAndNil(UserDefaults);

end.
