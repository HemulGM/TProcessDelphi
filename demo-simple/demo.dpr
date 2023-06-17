program demo;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form2},
  Process in '..\Process.pas',
  Pipes in '..\Pipes.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
