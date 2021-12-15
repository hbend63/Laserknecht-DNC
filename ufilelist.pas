unit ufilelist;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, uffileview,
  FileUtil;

type

  { TfFiles }

  TfFiles = class(TForm)
    ListBox1: TListBox;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure ListBox1DblClick(Sender: TObject);
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

procedure TfFiles.ListBox1DblClick(Sender: TObject);
var strings: TStringList;
begin
  strings:=TStringList.Create;
  strings.LoadFromFile(fPrgPath+'/cnc-data/'+ListBox1.GetSelectedText);
  with TformFileView.Create(self) do begin
    Open(strings);
    ShowModal;
    release;
  end;
end;

procedure TfFiles.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  //CloseAction:=caFree;
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

