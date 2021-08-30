unit utransferfile;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ComCtrls, synaSer, IniFiles;

type
  TState = (CONNECTING, WAITSTART, LOADFILE, SENDDATA, ENDDATA, ERRFILE);

  { TForm1 }

  TForm1 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    sb: TStatusBar;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    fSerialPort: TBlockSerial;
    fPortName: string;
    fState: TState;
    fprgPath: string;
    fCNCData: TStringList;
    fAnswerString: string;
    fFileName: string;
    procedure connect;
    procedure doSetup;
    procedure wait4Start;
    procedure loadDataFile;
    function getSerialString: string;
    function calcChecksum(s: string): char;
    function checkData(s:string): boolean;
    procedure sendDataFile;
    procedure sendDataEnd;
    procedure showFileError;
    procedure sendStr(s: string);
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var ini: TIniFile;
    s  : string;
begin
  Memo1.Lines.Clear;
  Memo2.Lines.Clear;
  fSerialPort:= TBlockSerial.Create;
  fPrgPath:=ExtractFilePath(Application.exeName);
  if not DirectoryExists(fPrgPath+'/cnc-data') then
    CreateDir(fPrgPath+'/cnc-data');
  ini:=TIniFile.Create(fPrgPath+'/config.ini');
  s:=ini.readString('COM','PORTNAME','');
  ini.Free;
  if (s='') then doSetup;
  fPortName:=s;
  fCNCData:=TStringList.Create;
  fAnswerString:='';
  fFileName:='';
  fState:=CONNECTING;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  fCNCData.Free;
  fSerialPort.Free;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  case fState of
       CONNECTING  : connect;
       WAITSTART   : wait4Start;
       LOADFILE    : loadDataFile;
       SENDDATA    : sendDataFile;
       ENDDATA     : sendDataEnd;
       ERRFILE     : showFileError;
   end;
end;

procedure TForm1.connect;
begin
  fSerialPort.Connect(fPortName);
  Sleep(100);
  fSerialPort.Config(9600,8,'n',SB1,false,false);
  Sleep(100);
  sb.Panels[0].Text:='connected '+fPortName;
  fState:=WAITSTART;
end;

procedure TForm1.doSetup;
var ini: TIniFile;
begin
    ini:=TIniFile.Create(fPrgPath+'/config.ini');
    ini.WriteString('COM','PORTNAME','COM1');
    ini.Free;
    ShowMessage('Please set Port in config.ini');
    Application.Terminate;
end;

procedure TForm1.wait4Start;
var s, s1: string;
begin
  Sleep(100);
  s:=getSerialString;
  if (fSerialPort.LastError<>ErrTimeout) then begin
    if not checkData(s) then exit;
    s1:=copy(s,3,2);
    if (s1='SE' )then begin
       fAnswerString:=s;
       fState:=LOADFILE;
    end;
  end;
end;

procedure TForm1.loadDataFile;
begin
  Memo1.Lines.Clear;
  Memo2.Lines.Clear;
  fFileName:=copy(fAnswerString,5,length(fAnswerString)-6);
  if (FileExists(fPrgPath+'/cnc-data/'+fFileName) ) then begin
    sb.Panels[2].Text:='LOAD '+fFilename;
    fCNCData.Clear;
    fCNCData.LoadFromFile(fPrgPath+'/cnc-data/'+fFileName);
    Label1.Caption:='Inputfile: '+fFilename;
    Memo1.Lines.AddStrings(fCNCData);
    sendStr('AAAK'+calcCheckSum('AAAK'));
    fState:=SENDDATA;
  end else
    fState:=ERRFILE;
end;

function TForm1.getSerialString: string;
var s: string;
    c: char;
    sEnd, sStart: boolean;
    n, i: integer;
begin
  s:='';
  sEnd:=false;
  sStart:=false;
  n:= fSerialPort.WaitingData;
  i:=0;
  while ((i < n) and not sEnd) do begin
   inc(i);
   c:=char(fSerialPort.RecvByte(50));
   if (c='A') then
        sStart:=true;
   if (c=#13) then
        sEnd:=true;
   if (sStart) then
       s:=s+c;
   if (sStart and sEnd) then begin
      Memo2.Lines.Add('RX: '+s);
      result:=s;
   end;
  end;
end;

function TForm1.calcChecksum(s: string): char;
var
    i: integer;
    sum: integer;
    modsum: byte;
    checksum: byte;
begin
  if (s='') then exit;
  sum:=0;
  // Addiere alle Bytes
  for i:= 1 to length(s) do
    sum:=sum+byte(s[i]);
  // Modulo $80
  modsum:=sum mod $80;
  // Checksumme
  checkSum:= $7F-modSum;
  // Checksumme muß zwischen $20 und $7E liegen
  if (CheckSum < $20) then checkSum:=checkSum+$40
  else
    if (CheckSum > $7e) then checkSum:=checkSum-$40;
  result:=char(checkSum);
end;

function TForm1.checkData(s: string): boolean;
var cmd: string;
    checkSum: char;
    sendSum: char;
begin
    if (s='') then exit;
    cmd:=copy(s,0,length(s)-2);
    checkSum:=calcCheckSum(cmd);
    sendSum:=s[length(s)-1];
    result := checkSum=sendSum;
end;

procedure TForm1.sendDataFile;
var i: integer;
    s,a: string;
begin
  sb.Panels[2].Text:='SEND '+fFilename;
  Application.ProcessMessages;
  i:=0;
  repeat
    s:='AADA'+fCNCData.Strings[i];
    sendStr(s+calcCheckSum(s));
    while (not fSerialPort.CanRead(10)) do;
    if (fSerialPort.LastError <> ErrTimeout) then begin
      a:=getSerialString;
      if (checkData(a)) then
       if (copy(a,3,2)='AK') then
          inc(i);
    end;
  until (i = fCNCData.Count-1);
  fState:=ENDDATA;
end;

procedure TForm1.sendDataEnd;
var a: string;
begin
  sendStr('AAEF'+calcCheckSum('AAEF'));
  while (not fSerialPort.CanRead(10)) do;
    if (fSerialPort.LastError <> ErrTimeout) then
      a:=getSerialString;
    if (checkData(a)) then
       if (copy(a,3,2)='AK') then begin
         sb.Panels[2].Text:='SEND '+fFilename+' OK';
         fSerialPort.Flush;
         fSerialPort.Purge;
         fState:=WAITSTART;
       end;
end;

procedure TForm1.showFileError;
begin
  sendStr('AANK01'+calcCheckSum('AANK01'));
  Label1.Caption:='ERR: NO FILE '+fFileName;
  fState:=WAITSTART;
end;

procedure TForm1.sendStr(s: string);
begin
   fSerialPort.SendString(s+chr($D));
   Memo2.Lines.Add('TX: '+s);
end;




end.

