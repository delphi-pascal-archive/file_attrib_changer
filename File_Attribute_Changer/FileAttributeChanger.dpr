program FileAttributeChanger;

uses
  Forms,
  Unit1 in 'Unit1.pas' {fmChangeFileAttr};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Изменение атрибутов файла';
  Application.CreateForm(TfmChangeFileAttr, fmChangeFileAttr);
  Application.Run;
end.
