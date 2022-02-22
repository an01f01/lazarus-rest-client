unit rclient;

{$mode objfpc}{$H+}

interface

uses
    {$IFDEF UNIX}cthreads, {$ENDIF}Classes, SysUtils, Forms, Controls, Graphics,
    Dialogs, StdCtrls, fphttpapp, httpdefs, httproute,
    opensslsockets, fphttpclient, fpjson, jsonparser;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Memo1: TMemo;
    Memo2: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    httpClient: TFPHttpClient;
    jArr: TJSONArray;
    response: string;
    ResponseRest : TStringStream;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

procedure timeEndpoint(req: TRequest; res: TResponse);
{ This is our time endpoint function }
var
  jObject : TJSONObject;
begin
  jObject := TJSONObject.Create;
  try
    jObject.Strings['time'] := TimeToStr(Time);
    res.Content := jObject.AsJSON;
    res.Code := 200;
    res.ContentType := 'application/json';
    res.ContentLength := length(res.Content);
    res.SendContent;
  finally
    jObject.Free;
  end;
end;

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
  i : integer;
begin          
  Memo1.Lines.Clear();
  Memo2.Lines.Clear();
end;

procedure TForm1.Button1Click(Sender: TObject);
begin         
  httpClient := TFPHTTPClient.Create(nil);
  httpClient.RequestBody := TRawByteStringStream.Create(Memo1.Text);
  ResponseRest := TStringStream.Create('');
  try
     try
        httpClient.Post(Edit1.Text, ResponseRest);
        Memo2.Lines.Add('Response Code is ' + inttostr(httpClient.ResponseStatusCode));
        Memo2.Lines.Add(httpClient.ResponseStatusText);
        Memo2.Lines.Add(ResponseRest.DataString);
     except on E:Exception do
        Memo2.Lines.Add('something bad happened : ' + E.Message);
     end;
  finally
    httpClient.RequestBody.Free;
    httpClient.Free;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  try
     response := TFPHTTPClient.SimpleGet(Edit1.Text);
     Memo2.Lines.Add(response);
   except on E:Exception do
     Memo2.Lines.Add('something bad happened : ' + E.Message);
   end;
end;

end.

