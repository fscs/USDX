unit UUltraQueue;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

type
  TQueueSongEvent = (qseStarted, qseFinished);

function TryGetQueuedSong(const BaseURL: string; out SearchText: UTF8String;
  out Error: string): boolean;
function TryReportQueueSong(const BaseURL: string; Event: TQueueSongEvent;
  const Title, Artist: UTF8String; out Error: string): boolean;

implementation

uses
  Classes,
  SysUtils,
  fphttpclient,
  fpjson,
  opensslsockets;

const
  REQUEST_TIMEOUT_MS = 2000;
  MAX_RESPONSE_BYTES = 65536;
  SONG_EVENT_PATHS: array[TQueueSongEvent] of string =
    ('/startedplaying', '/songfinished');

type
  TQueueResponseStream = class(TStringStream)
    function Write(const Buffer; Count: LongInt): LongInt; override;
  end;

function TQueueResponseStream.Write(const Buffer; Count: LongInt): LongInt;
begin
  if (Count < 0) or (Position + Count > MAX_RESPONSE_BYTES) then
    raise EStreamError.Create('UltraQueue response exceeds 64 KiB');
  Result := inherited Write(Buffer, Count);
end;

function Request(const BaseURL, Endpoint: string; const Body: UTF8String;
  out Response: UTF8String; out Error: string): boolean;
var
  Client: TFPHTTPClient;
  Output: TQueueResponseStream;
  Input: TRawByteStringStream;
  URL: string;
begin
  Result := false;
  Response := '';
  Error := '';
  URL := Trim(BaseURL);
  if URL = '' then
    Exit(true);
  while (Length(URL) > 0) and (URL[Length(URL)] = '/') do
    Delete(URL, Length(URL), 1);

  Client := TFPHTTPClient.Create(nil);
  try
    Client.ConnectTimeout := REQUEST_TIMEOUT_MS;
    Client.IOTimeout := REQUEST_TIMEOUT_MS;
    Client.AllowRedirect := true;
    Output := TQueueResponseStream.Create('');
    try
      try
        if Body = '' then
          Client.Get(URL + Endpoint, Output)
        else
        begin
          Input := TRawByteStringStream.Create(Body);
          try
            Client.AddHeader('Content-Type', 'application/json; charset=utf-8');
            Client.RequestBody := Input;
            try
              Client.Post(URL + Endpoint, Output);
            finally
              Client.RequestBody := nil;
            end;
          finally
            Input.Free;
          end;
        end;
        Response := UTF8String(Output.DataString);
        Result := true;
      except
        on E: Exception do
          Error := E.Message;
      end;
    finally
      Output.Free;
    end;
  finally
    Client.Free;
  end;
end;

function TryGetQueuedSong(const BaseURL: string; out SearchText: UTF8String;
  out Error: string): boolean;
begin
  Result := Request(BaseURL, '/nextsong', '', SearchText, Error);
  SearchText := Trim(SearchText);
end;

function TryReportQueueSong(const BaseURL: string; Event: TQueueSongEvent;
  const Title, Artist: UTF8String; out Error: string): boolean;
var
  Payload: TJSONObject;
  Response: UTF8String;
begin
  Payload := TJSONObject.Create;
  try
    Payload.Add('title', Title);
    Payload.Add('artist', Artist);
    Result := Request(BaseURL, SONG_EVENT_PATHS[Event], UTF8String(Payload.AsJSON),
      Response, Error);
  finally
    Payload.Free;
  end;
end;

end.
