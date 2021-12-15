unit uffileview;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TformFileView }

  TformFileView = class(TForm)
    Memo1: TMemo;
  private

  public
    procedure Open(Strings:TStringList);

  end;

var
  formFileView: TformFileView;

implementation

{$R *.lfm}

{ TformFileView }

procedure TformFileView.Open(Strings: TStringList);
begin
  Memo1.Lines.AddStrings(Strings);
end;

end.

