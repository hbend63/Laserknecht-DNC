unit usendfile;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, LazSerial, LazSerialSetup, IniFiles;

type

  TState = (CONNECTING, INIT, LOAD, WAITING, DATAOK, TIMEOUT);

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    IdleTimer1: TIdleTimer;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    OpenDialog1: TOpenDialog;
    SerialPort: TLazSerial;
    sb: TStatusBar;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure IdleTimer1Timer(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    fprgPath: string;
    fSerialAnswer: string;
    fData: TStringList;
    fState: TState;
    fBlink: boolean;
    function calcChecksum(s: string): char;
    function checkData(s:string): boolean;
    procedure readSetupParams;
    procedure doSetup;
    procedure loadFile(s: string);
    procedure sendFile;
    procedure sendStr(s: string);
    procedure readData;
    procedure connect;
    procedure reinit;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

procedure TForm1.FormCreate(Sender: TObject);

begin
  fPrgPath:=ExtractFilePath(Application.exeName);
  if not DirectoryExists(fPrgPath+'/cnc-data') then
    CreateDir(fPrgPath+'/cnc-data');
  fData:=TStringList.Create;
  readSetupParams;
  fState:=CONNECTING;
  fBlink:=false;
  if not Application.terminated then
    connect;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  doSetup;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  OpenDialog1.InitialDir:=fPrgPath+'/cnc-data/';
  OpenDialog1.Execute;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  fData.Free;
  SerialPort.Close;
end;

procedure TForm1.IdleTimer1Timer(Sender: TObject);
var leave: boolean;
begin
  leave:=false;
  readData;
  if fState=INIT then begin
    if (SerialPort.DataAvailable) then
    repeat
       case fState of
          WAITING: if (SerialPort.DataAvailable) then
                    readData;
          DATAOK:  begin
                    fBlink:=not fBlink;
                    if fBlink then
                      sb.Panels[2].Text:='WAITING ..'
                    else
                      sb.Panels[2].Text:='WAITING .....';
                    sb.Invalidate;
                 end;
          LOAD: leave:=true;
       end;
    until (leave);
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  fState:=TIMEOUT;
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
    cmd:=copy(s,0,length(s)-2);
    checkSum:=calcCheckSum(cmd);
    sendSum:=s[length(s)-1];
    result := checkSum=sendSum;
end;

procedure TForm1.readSetupParams;
var ini: TIniFile;
    s  : string;
begin
   ini:=TIniFile.Create(fPrgPath+'/config.ini');
   s:=ini.readString('COM','PORTNAME','');
   if (s='') then doSetup;
   with SerialPort do begin
      Close;
      Device:=ini.ReadString('COM','PORTNAME','');
      BaudRate:=StrToBaudRate(ini.ReadString('COM','BAUDRATE',''));
      StopBits:=StrToStopBits(ini.ReadString('COM','STOPBITS',''));
      DataBits:=StrToDataBits(ini.ReadString('COM','DATABITS',''));
      Parity:=StrToParity(ini.ReadString('COM','PARITY',''));
      FlowControl:=StrToFlowControl(ini.ReadString('COM','FLOWCONTROL',''));
   end;
   ini.Free;
   sb.Panels[1].Text:=SerialPort.Device
                      +' bd: '+BaudrateToStr(SerialPort.BaudRate)
                      +' db: '+DataBitsToStr(SerialPort.DataBits)
                      +' sb: '+StopBitsToStr(SerialPort.StopBits)
                      +' parity: '+ParityToStr(SerialPort.Parity)
                      +' flowcontrol: '+FlowControlToStr(SerialPort.FlowControl);
end;

procedure TForm1.doSetup;
var ini: TIniFile;
begin
  SerialPort.ShowSetupDialog;
  ini:=TIniFile.Create(fPrgPath+'/config.ini');
  ini.WriteString('COM','PORTNAME',SerialPort.Device);
  ini.WriteString('COM','BAUDRATE',BaudrateToStr(SerialPort.BaudRate));
  ini.WriteString('COM','STOPBITS',StopBitsToStr(SerialPort.StopBits));
  ini.WriteString('COM','DATABITS',DataBitsToStr(SerialPort.DataBits));
  ini.WriteString('COM','PARITY',ParityToStr(SerialPort.Parity));
  ini.WriteString('COM','FLOWCONTROL',FlowControlToStr(SerialPort.FlowControl));
  ini.Free;
  ShowMessage('Configuration saved, please restart Program.');
  Application.terminate;
end;

procedure TForm1.loadFile(s: string);
var fileName: string;
begin
  fileName:=copy(s,5,length(s)-6);
  if (FileExists(fPrgPath+'/cnc-data/'+fileName) ) then begin
    fState:=LOAD;
    sb.Panels[2].Text:='LOAD '+filename;
    fData.Clear;
    Memo1.Lines.Clear;
    Memo2.Lines.Clear;
    fData.LoadFromFile(fPrgPath+'/cnc-data/'+fileName);
    Label1.Caption:='Inputfile: '+filename;
    Memo1.Lines.AddStrings(fData);
    Application.ProcessMessages;
    sendStr('AAAK'+calcCheckSum('AAAK'));
    sendFile;
  end else begin
     sendStr('AANK01'+calcCheckSum('AANK01'));
     Label1.Caption:='ERR: NO FILE '+fileName;
     reinit;
  end;
end;

procedure TForm1.sendFile;
var i: integer;
    dt: string;
begin
   i:=0;
   sb.Panels[2].Text:='SEND';
   sb.Invalidate;
   dt:='AADA'+fData.Strings[i];
   sendStr(dt+calcCheckSum(dt));
   Sleep(2);
   repeat
     case fState of
        WAITING: begin
                   readData;
                   Memo2.Lines.Add('ANSW: '+fSerialAnswer);
        end;
        DATAOK:  begin
                   fBlink:=not fBlink;
                   if fBlink then
                     sb.Panels[2].Text:='SEND ..'
                   else
                     sb.Panels[2].Text:='SEND .....';
                   sb.invalidate;
                   inc(i);
                   dt:='AADA'+fData.Strings[i];
                   sendStr(dt+calcCheckSum(dt));
                   Sleep(2);
                 end;
     end;
     Memo2.Lines.Add(IntToStr(i)+':');
   until ((i=fData.Count-1) or (fState=TIMEOUT));
   sb.Panels[2].Text:='SEND EOF';
   sb.invalidate;
   //Application.ProcessMessages;
   if (fState <> TIMEOUT) then begin
       sendStr('AAEF'+calcCheckSum('AAEF'));
   end;
   sb.Panels[2].Text:='SEND ok';
   sb.invalidate;
   reinit;
end;

procedure TForm1.sendStr(s: string);
begin
   fSerialAnswer:='';
   SerialPort.WriteData(s+chr($D));
   Timer1.Enabled:=true;
   fState:=WAITING;
   Memo2.Lines.Add('TX: '+s);
end;

procedure TForm1.readData;
var s,s1: string;
    x1,x2: integer;
begin
   while not SerialPort.DataAvailable do;
   s:=SerialPort.ReadData;
   fSerialAnswer:=fSerialAnswer+s;
   x1:=pos('A',fSerialAnswer);
   x2:=pos(#13,fSerialAnswer);
   if ((x1>0) and (x2>x1) ) then begin
     fSerialAnswer:=copy(fSerialAnswer,x1,x2);
     if (checkData(fSerialAnswer)) then  begin
       s1:=copy(fSerialAnswer,3,2);
       if (copy(fSerialAnswer,3,2)='SE')then
          loadFile(s)
       else if (copy(fSerialAnswer,3,2)='AK') then
          fState:=DATAOK;
     end;
     Memo2.Lines.Add('RX: '+fSerialAnswer);
     Timer1.Enabled:=false;
   end;
end;

procedure TForm1.connect;
begin
  SerialPort.Open;
  Memo1.Lines.Clear;
  Memo2.Lines.Clear;
   if (SerialPort.Active) then
      sb.Panels[0].Text:='CONNECTED'
   else
     sb.Panels[0].Text:='DISCONNECTED';
   fState:=INIT;
   IdleTimer1.Enabled:=true;
end;

procedure TForm1.reinit;
begin
   //SerialPort.Close;
   //Connect;

   Sleep(500);
   while SerialPort.DataAvailable do  begin
     SerialPort.ReadData;
     Sleep(10);
   end;

   Memo2.Lines.Add('REINIT');
   fSerialAnswer:='';
   fState:=INIT;
   IdleTimer1.Enabled:=true;
end;

end.

