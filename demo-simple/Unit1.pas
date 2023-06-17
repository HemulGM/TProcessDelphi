unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls;

type
  TForm2 = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

uses
  Process;

procedure TForm2.Button1Click(Sender: TObject);
var
  Output: AnsiString;
begin
  RunCommand('cmd', ['/c', 'dir'], Output, [poNoConsole]);
  Memo1.Lines.Add(string(Output));

  var P := TProcess.Create(nil);
  try
    P.ApplicationName := 'cmd';
    P.Parameters.AddStrings(['/c', 'dir']);
  finally
    P.Free;
  end;
end;

initialization
  ReportMemoryLeaksOnShutdown := True;

end.

