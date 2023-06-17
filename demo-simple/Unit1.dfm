object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Form2'
  ClientHeight = 359
  ClientWidth = 540
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 17
  object Label1: TLabel
    Left = 113
    Top = 11
    Width = 286
    Height = 17
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'This program captures the output of a command'
  end
  object Memo1: TMemo
    Left = 7
    Top = 48
    Width = 526
    Height = 304
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Lines.Strings = (
      'Output:'
      '')
    TabOrder = 0
  end
  object Button1: TButton
    Left = 7
    Top = 7
    Width = 102
    Height = 27
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Run Command'
    TabOrder = 1
    OnClick = Button1Click
  end
end
