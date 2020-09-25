object FMain: TFMain
  Left = 498
  Top = 235
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'IEBrowser'
  ClientHeight = 385
  ClientWidth = 376
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  Visible = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    376
    385)
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 8
    Top = 8
    Width = 360
    Height = 329
    ActivePage = SessionTab
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object SessionTab: TTabSheet
      Caption = 'Session'
      object GroupBox1: TGroupBox
        Left = 8
        Top = 8
        Width = 337
        Height = 81
        Caption = ' URL '
        TabOrder = 0
        object Label1: TLabel
          Left = 88
          Top = 24
          Width = 119
          Height = 13
          Caption = 'Hostname (or IP address)'
        end
        object Label2: TLabel
          Left = 16
          Top = 24
          Width = 39
          Height = 13
          Caption = 'Protocol'
        end
        object Label3: TLabel
          Left = 264
          Top = 24
          Width = 19
          Height = 13
          Caption = 'Port'
        end
        object HostnameField: TEdit
          Left = 88
          Top = 40
          Width = 169
          Height = 21
          TabOrder = 0
        end
        object ProtocolField: TComboBox
          Left = 16
          Top = 40
          Width = 65
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          ItemIndex = 0
          TabOrder = 1
          Text = 'HTTP'
          Items.Strings = (
            'HTTP'
            'HTTPS')
        end
        object UpDown: TUpDown
          Left = 305
          Top = 40
          Width = 16
          Height = 21
          Associate = PortField
          Min = -32767
          Max = 32767
          Position = 80
          TabOrder = 2
          Thousands = False
        end
        object PortField: TEdit
          Left = 264
          Top = 40
          Width = 41
          Height = 21
          TabOrder = 3
          Text = '80'
        end
      end
      object GroupBox2: TGroupBox
        Left = 8
        Top = 104
        Width = 337
        Height = 185
        Caption = ' Saved Sessions '
        TabOrder = 1
        object SessionList: TListBox
          Left = 16
          Top = 56
          Width = 225
          Height = 113
          ItemHeight = 13
          TabOrder = 0
          OnDblClick = SessionListDblClick
        end
        object NameField: TEdit
          Left = 16
          Top = 24
          Width = 225
          Height = 21
          TabOrder = 1
        end
        object LoadButton: TButton
          Left = 256
          Top = 56
          Width = 65
          Height = 25
          Caption = 'Load'
          TabOrder = 2
          OnClick = LoadButtonClick
        end
        object SaveButton: TButton
          Left = 256
          Top = 88
          Width = 65
          Height = 25
          Caption = 'Save'
          TabOrder = 3
          OnClick = SaveButtonClick
        end
        object DeleteButton: TButton
          Left = 256
          Top = 120
          Width = 65
          Height = 25
          Caption = 'Delete'
          TabOrder = 4
          OnClick = DeleteButtonClick
        end
      end
    end
    object SettingsTab: TTabSheet
      Caption = 'Settings'
      ImageIndex = 1
    end
  end
  object OpenButton: TButton
    Left = 207
    Top = 352
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Open'
    TabOrder = 1
    OnClick = OpenButtonClick
  end
  object CancelButton: TButton
    Left = 293
    Top = 352
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = CancelButtonClick
  end
  object AboutButton: TButton
    Left = 8
    Top = 352
    Width = 75
    Height = 25
    Caption = 'About'
    TabOrder = 3
    OnClick = AboutButtonClick
  end
end
