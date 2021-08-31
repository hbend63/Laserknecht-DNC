unit usetup;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  synaser, IniFiles;

type

  { TfSetup }

  TfSetup = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    ComboBox1: TComboBox;
    procedure BitBtn1Click(Sender: TObject);
    procedure ComboBox1DropDown(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    fprgPath: string;
    fIniFile: TIniFile;
  public

  end;

var
  fSetup: TfSetup;

implementation

{$R *.lfm}

{ TfSetup }

procedure TfSetup.ComboBox1DropDown(Sender: TObject);
begin
  ComboBox1.Items.CommaText :=  GetSerialPortNames();
end;

procedure TfSetup.BitBtn1Click(Sender: TObject);
begin
  fIniFile.WriteString('COM','PORTNAME',ComboBox1.Text);
  Close;
end;

procedure TfSetup.FormCreate(Sender: TObject);
begin
  fPrgPath:=ExtractFilePath(Application.exeName);
  ComboBox1.Items.CommaText :=  GetSerialPortNames();
  fIniFile:=TIniFile.Create(fPrgPath+'/config.ini');
  ComboBox1.Text:=fIniFile.readString('COM','PORTNAME','');
end;

procedure TfSetup.FormDestroy(Sender: TObject);
begin
  fIniFile.Free;
end;

end.

