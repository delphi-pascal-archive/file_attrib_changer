program FileAttributeChanger;

uses
  Forms,
  Unit1 in 'Unit1.pas' {fmChangeFileAttr};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := '��������� ��������� �����';
  Application.CreateForm(TfmChangeFileAttr, fmChangeFileAttr);
  Application.Run;
end.
