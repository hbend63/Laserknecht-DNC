unit ufilelist;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, FileUtil;

type

  { TfFiles }

  TfFiles = class(TForm)
    ListBox1: TListBox;
    procedure FormCreate(Sender: TObject);
  private
    fprgPath: string;
    procedure getFiles;
  public

  end;

var
  fFiles: TfFiles;

implementation

{$R *.lfm}

{ TfFiles }

procedure TfFiles.FormCreate(Sender: TObject);
begin
  fPrgPath:=ExtractFilePath(Application.exeName);
  getFiles;
end;

procedure TfFiles.getFiles;
var
  CNCFiles: TStringList;
  i: integer;
begin
  CNCFiles := TStringList.Create;
  try
    CNCFiles := FindAllFiles(fPrgPath+'/cnc-data', '*.cnc', true);
    for i:=0 to CNCFiles.Count-1 do
       Listbox1.AddItem(ExtractFileName(CNCFiles.Strings[i]),NIL);
  finally
    CNCFiles.Free;
  end;
end;

end.

