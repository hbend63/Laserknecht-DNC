unit utransferfile;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ComCtrls, Menus, synaSer, IniFiles, usetup, ufilelist;

type
  TState = (CONNECTING, WAITSTART, LOADFILE, SAVEFILE, SENDDATA, ENDDATA, ERRFILE);

  { TForm1 }

  TForm1 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    mSetup: TMenuItem;
    mFiles: TMenuItem;
    PopupMenu1: TPopupMenu;
    pb: TProgressBar;
    sb: TStatusBar;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure mFilesClick(Sender: TObject);
    procedure mSetupClick(Sender: TObject);
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
    procedure saveDataFile;
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

procedure TForm1.mFilesClick(Sender: TObject);
begin
  Timer1.Enabled:=false;
  with TfFiles.Create(self) do begin
     ShowModal;
     Release;
  end;
  Timer1.Enabled:=true;
end;

procedure TForm1.mSetupClick(Sender: TObject);
begin
  Timer1.Enabled:=false;
  with TfSetup.Create(self) do begin
     ShowModal;
     Release;
  end;
  Timer1.Enabled:=true;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  case fState of
       CONNECTING  : connect;
       WAITSTART   : wait4Start;
       LOADFILE    : loadDataFile;
       SAVEFILE    : saveDataFile;
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
    Timer1.Enabled:=false;
    with TfSetup.Create(self) do begin
       ShowModal;
       release;
    end;
    ini:=TIniFile.Create(fPrgPath+'/config.ini');
    fPortName:=ini.readString('COM','PORTNAME','');
    ini.Free;
    Timer1.Enabled:=true;
end;

procedure TForm1.wait4Start;
var s, s1: string;
begin
  Sleep(100);
  s:=getSerialString;
  if (fSerialPort.LastError<>ErrTimeout) then begin
    if not checkData(s) then exit;
    s1:=copy(s,3,2);
    if (s1='SE')then begin
       fAnswerString:=s;
       fState:=LOADFILE;
    end else if (s1='TS')then begin
        sendStr('AATS'+calcCheckSum('AATS'));
    end else if (s1='ST')then begin
       fAnswerString:=s;
       fState:=SAVEFILE;
    end
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
    pb.Position:=0;
    pb.Max:=fCNCData.Count;
    fState:=SENDDATA;
  end else
    fState:=ERRFILE;
end;

procedure TForm1.saveDataFile;
var fileName, a, com, ccom: string;
    fertig: boolean;
begin
  fileName:=copy(fAnswerString,5,length(fAnswerString)-6);
  if (FileExists(fPrgPath+'/cnc-data/'+fileName) ) then
     sendStr('AANK'+calcCheckSum('AANK'))
  else
  begin
    Label1.Caption:='Outputfile: '+fFilename;
    Label1.Invalidate;
    sendStr('AAAK'+calcCheckSum('AAAK'));
    Memo1.Lines.Clear;
    Memo2.Lines.Clear;
    fertig:=false;
    repeat
      Sleep(50);
      a:=getSerialString;
      com := copy(a,3,2);
      if (com='DA') then begin
        ccom:=copy(a,5,length(a)-6);
        Memo1.Lines.Add(ccom);
        sendStr('AAAK'+calcCheckSum('AAAK'))
      end
      else if (com='EF') then
         fertig:=true;
    until fertig;
    sendStr('AAAK'+calcCheckSum('AAAK'));
    Memo1.Lines.SaveToFile(fPrgPath+'/cnc-data/'+fileName);
  end;
  fState:=WAITSTART;
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
  //while (fSerialPort.WaitingData=0) do;
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
    fSerialPort.Flush;
    Sleep(50);
    a:=getSerialString;
    if (checkData(a)) then
       if (copy(a,3,2)='AK') then
          inc(i);

    if (i mod 10 = 0) then
       pb.StepIt;
  until (i = fCNCData.Count);
  fState:=ENDDATA;
end;

procedure TForm1.sendDataEnd;

begin
  pb.Position:=pb.Max;
  sendStr('AAEF'+calcCheckSum('AAEF'));
  fSerialPort.CloseSocket;
  Connect;
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

