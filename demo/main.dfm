object Form1: TForm1
  Left = 0
  Top = 0
  Caption = #38463#37324#20113' OpenAPI V3 '#35843#29992#31034#20363
  ClientHeight = 383
  ClientWidth = 553
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  DesignSize = (
    553
    383)
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 24
    Top = 24
    Width = 505
    Height = 287
    Anchors = [akLeft, akTop, akRight, akBottom]
    ScrollBars = ssBoth
    TabOrder = 0
    WordWrap = False
  end
  object ButtonExit: TButton
    Left = 454
    Top = 348
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #36864#20986
    Default = True
    ModalResult = 8
    TabOrder = 6
    OnClick = ButtonExitClick
  end
  object ButtonGet: TButton
    Left = 24
    Top = 317
    Width = 97
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'GET '#26041#24335#20363#23376
    TabOrder = 1
    OnClick = ButtonGetClick
  end
  object ButtonPostNoBody: TButton
    Left = 136
    Top = 317
    Width = 163
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'POST'#26041#24335#19981#20351#29992' Body '#20363#23376
    TabOrder = 2
    OnClick = ButtonPostNoBodyClick
  end
  object ButtonBodyWithJson: TButton
    Left = 314
    Top = 317
    Width = 215
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'POST '#26041#24335' Body '#20351#29992' Json '#26684#24335#20363#23376
    TabOrder = 3
    OnClick = ButtonBodyWithJsonClick
  end
  object ButtonBodyWithFormData: TButton
    Left = 24
    Top = 348
    Width = 225
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'POST '#26041#24335' Body '#20351#29992' FormData '#26684#24335#20363#23376
    TabOrder = 4
    OnClick = ButtonBodyWithFormDataClick
  end
  object ButtonBodyUpload: TButton
    Left = 255
    Top = 348
    Width = 178
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'POST '#26041#24335' Body '#19978#20256#25991#20214#20363#23376
    TabOrder = 5
    OnClick = ButtonBodyUploadClick
  end
end
