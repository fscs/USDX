program TestUltraQueue;

{$MODE Delphi}
{$CODEPAGE UTF8}
{$ASSERTIONS ON}

uses
  SysUtils,
  UUltraQueue;

var
  BaseURL, Error: string;
  SearchText: UTF8String;
  Started: QWord;
  I: integer;

begin
  BaseURL := ParamStr(1);
  Assert(TryGetQueuedSong(BaseURL + '/good/', SearchText, Error));
  Assert(SearchText = UTF8String('Björk 東京'));
  for I := 1 to 20 do
  begin
    Assert(TryReportQueueSong(BaseURL + '/good', qseStarted,
      UTF8String('Björk "東京"' + #10 + '\'), UTF8String('Artist'), Error));
    Assert(TryReportQueueSong(BaseURL + '/good', qseFinished,
      UTF8String('Björk "東京"' + #10 + '\'), UTF8String('Artist'), Error));
  end;
  Assert(not TryGetQueuedSong(BaseURL + '/error', SearchText, Error));
  Assert((SearchText = '') and (Error <> ''));
  Assert(not TryGetQueuedSong(BaseURL + '/oversized', SearchText, Error));
  Assert((SearchText = '') and (Error <> ''));
  Started := GetTickCount64;
  Assert(not TryGetQueuedSong(BaseURL + '/stall', SearchText, Error));
  Assert((GetTickCount64 - Started < 5000) and (Error <> ''));
  Assert(TryGetQueuedSong('', SearchText, Error));
  Assert((SearchText = '') and (Error = ''));
  WriteLn('UltraQueue transport checks passed');
end.
