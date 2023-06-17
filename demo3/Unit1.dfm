object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 230
  ClientWidth = 551
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  TextHeight = 16
  object Label1: TLabel
    Left = 7
    Top = 202
    Width = 412
    Height = 16
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 
      'This program captures the output of a console program, using TPr' +
      'ocess'
  end
  object Memo1: TMemo
    Left = 6
    Top = 6
    Width = 537
    Height = 189
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Lines.Strings = (
      'Output:')
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object Button1: TButton
    Left = 434
    Top = 199
    Width = 109
    Height = 24
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Run Command'
    TabOrder = 1
    OnClick = Button1Click
  end
end
