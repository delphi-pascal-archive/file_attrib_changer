unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms,
  Dialogs, StdCtrls, CheckLst, Buttons;

type
  TfmChangeFileAttr = class(TForm)
    attr_clb: TCheckListBox;
    open_dlg: TOpenDialog;
    fcount_lbl: TLabel;
    fn_edt: TEdit;
    SpeedButton1: TSpeedButton;
    procedure fn_edtDblClick(Sender: TObject);
    procedure fn_edtChange(Sender: TObject);
    procedure attr_clbClickCheck(Sender: TObject);
    procedure attr_clbClick(Sender: TObject);
    procedure refresh_btnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure GetAttr;
    function CheckFN(var fcount:word):boolean;
    function GetFirstFN(var files:string):string;
    procedure UnknownAttr;
  end;

var
  fmChangeFileAttr: TfmChangeFileAttr;

implementation

{$R *.dfm}

procedure TfmChangeFileAttr.fn_edtDblClick(Sender: TObject);
var i:word;
    s:string;
begin
  if open_dlg.Execute then
    begin
      s:='';
      for i:=0 to open_dlg.Files.Count-1 do
        begin
          if s<>'' then s:=s+'|'+open_dlg.Files[i]
            else s:=open_dlg.Files[i];
        end;
      fn_edt.Text:=s;
    end;
  CheckFN(i);
end;

function TfmChangeFileAttr.GetFirstFN(var files:string):string;
var i:integer;
begin
  i:=pos('|',files);
  if i>0 then
    begin
      result:=copy(files,1,i-1);
      delete(files,1,i);
    end
    else result:=files;
end;

function TfmChangeFileAttr.CheckFN(var fcount:word):boolean;
var s,fn:string;
    i:integer;
    fl:boolean;
begin
  s:=fn_edt.Text;
  if fn_edt.Text<>'' then
    begin
      fl:=true;
      fcount:=1;
    end
    else
      begin
        fl:=false;
        fcount:=0;
      end;
  i:=pos('|',s);
  while (i>0)and fl do
    begin
      inc(fcount);
      fn:=copy(s,1,i-1);
      delete(s,1,i);
      if not (fileexists(fn) or DirectoryExists(fn)) then fl:=false;
      i:=pos('|',s);
    end;
  if fl and (fcount=1) then
    if not (fileexists(s) or DirectoryExists(s)) then fl:=false;
  if fl and(fcount>0) then
    begin
      fn_edt.ParentFont:=true;
      attr_clb.Enabled:=true;
      result:=true;
      fcount_lbl.Caption:=inttostr(fcount)+' файл(ов)';
    end
    else
      begin
        fn_edt.Font.Color:=$0000FF; // = Graphics.clRed
        attr_clb.Enabled:=false;
        fcount_lbl.Caption:='Файлы не указаны или указаны не верно';
        result:=false;
      end;
end;

procedure TfmChangeFileAttr.UnknownAttr;
var i:integer;
begin
  for i:=0 to attr_clb.Count-1 do attr_clb.Checked[i]:=false;
end;

procedure TfmChangeFileAttr.GetAttr;
var attr:cardinal;
    fcount:word;
    i:word;
    s,fn:string;

 procedure Switch_AttrCLB(idx:integer; value, fl_first:boolean);
 begin
  with Attr_clb do
    begin
      if fl_first then
        begin
          if value then state[idx]:=cbChecked
            else state[idx]:=cbUnchecked;
        end
        else
        begin
          if value and (state[idx]=cbChecked) then state[idx]:=cbChecked
            else
            if (value and (state[idx]=cbUnchecked))or((not value)and(state[idx]=cbChecked)) then state[idx]:=cbGrayed
              else
              if value and (state[idx]=cbGrayed) then state[idx]:=cbGrayed
                else
                  if (not value)and(state[idx]=cbUnchecked) then state[idx]:=cbUnchecked;
        end;
    end;
 end;

begin
  if not CheckFN(fcount) then
    begin
      UnknownAttr;
      exit;
    end;
  s:=fn_edt.Text;
  attr_clb.AllowGrayed:=true;
  for i:=1 to fcount do
    begin
      fn:=GetFirstFN(s);
      attr:=windows.GetFileAttributes(PChar(fn));
      if (attr and faSysFile)<>0 then Switch_AttrCLB(0,true,(i=1))
        else Switch_AttrCLB(0,false,(i=1));
      if (attr and faHidden)<>0 then Switch_AttrCLB(1,true,(i=1))
        else Switch_AttrCLB(1,false,(i=1));
      if (attr and faReadOnly)<>0 then Switch_AttrCLB(2,true,(i=1))
        else Switch_AttrCLB(2,false,(i=1));
      if (attr and faArchive)<>0 then Switch_AttrCLB(3,true,(i=1))
        else Switch_AttrCLB(3,false,(i=1));
    end;
  attr_clb.AllowGrayed:=false;
end;

procedure TfmChangeFileAttr.fn_edtChange(Sender: TObject);
var fcount:word;
begin
  if not CheckFN(fcount) then exit;
  GetAttr;
end;

procedure TfmChangeFileAttr.attr_clbClickCheck(Sender: TObject);
var attr,a:cardinal;
    i,fcount:word;
    s,fn:string;
begin
  if not CheckFN(fcount) then exit;
  s:=fn_edt.Text;
  case attr_clb.ItemIndex of
    0:a:=faSysFile;
    1:a:=faHidden;
    2:a:=faReadOnly;
    3:a:=faArchive
    else a:=$FFFFFFFF; //для того чтобы a всегда было задано
  end;
  for i:=1 to fcount do
    begin
      fn:=GetFirstFN(s);
      attr:=windows.GetFileAttributes(PChar(fn));
      if attr_clb.State[attr_clb.ItemIndex] in [cbChecked, cbGrayed] then attr:=attr or a
        else attr:=(attr and ($FFFFFFFF - a));
      windows.SetFileAttributes(PChar(fn),attr);
      {windows.SetFileAttributesA(PChar(fn),attr);
      windows.SetFileAttributesW(PWideChar(fn),attr);}
    end;
  //showmessage(inttostr(attr));
  GetAttr;
end;

procedure TfmChangeFileAttr.attr_clbClick(Sender: TObject);
begin
  //attr_clb.Checked[attr_clb.ItemIndex]:=not attr_clb.Checked[attr_clb.ItemIndex];
  attr_clb.OnClickCheck(self);
end;

procedure TfmChangeFileAttr.refresh_btnClick(Sender: TObject);
begin
  GetAttr;
end;

end.
