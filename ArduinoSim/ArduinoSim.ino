String inputString="";
bool stringComplete=false;

char calcChecksum(String s)
{
  int sum=0;
  for (int i=0;i<s.length();i++)
    sum+=char(s[i]);
  int modSum=sum % 0x80;
  int checkSum = 0x7F-modSum;
  if (checkSum < 0x20)
    checkSum+=0x40;
  else if (checkSum > 0x7E)
    checkSum-=0x40;   
  return char(checkSum);      
}

void sndString(String s)
{
  s+=calcChecksum(s);
  s+=char(0xD);
  Serial.print(s);
}

enum PrgState {INIT,WAIT,PROCESS};

PrgState state=INIT;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(13,OUTPUT);
  sndString("ABSEZAHN.CNC");
}

void loop() {  
  switch (state)
  {
      case INIT: {
          inputString="";
          if (Serial.available()){
             char inChar = (char)Serial.read();
             if (inChar=='A')
             {                
                inputString+=inChar;
                state=WAIT; 
             }
          }        
      }
      case WAIT: {
        if (Serial.available()){
          char inChar = (char)Serial.read();
          inputString += inChar;
          if (inChar == char(0xd)) 
            state=PROCESS;          
        }
        break;
      } 
     case PROCESS: {
        char c=inputString[inputString.length()-2];
        String s=inputString.substring(0,inputString.length()-2);
        //Serial.println(s.substring(2,4));
        if (c==calcChecksum(s))
        {
          //Serial.println(s.substring(2,4));
          if (s.substring(2,4)=="SE")
            sndString("ABAK");
              //else if (s.substring(2,4)=="AK");
             //sndString("ABAK");            
          else if (s.substring(2,4)=="DA")
            sndString("ABAK"); 
          else if (s.substring(2,4)=="EF")
             sndString("ABAK"); 
          else if (s.substring(2,4)=="NK")
             sndString("ABAK");                              
        }
        else sndString("ABNK01");
        state=INIT;
        break;         
     }   
  }  
  delay(2);
}
