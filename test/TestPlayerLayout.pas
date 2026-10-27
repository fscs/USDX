program TestPlayerLayout;

{$MODE Delphi}
{$ASSERTIONS ON}

uses
  Math,
  UPlayerLayout;

const
  COUNTS: array[0..12] of integer = (1, 2, 3, 5, 6, 7, 12, 18, 25, 33, 129, 257, 1025);

var
  Count, Screens, Screen, PlayerIndex, LocalIndex, I, J, Total: integer;
  Grid: TPlayerGrid;
  Rect, Other: TPlayerSlotRect;
  Config: TSingPlayerLayoutConfig;
  Lane: TSingLaneLayout;
  Colors: array of integer;

begin
  // Uneven splits must preserve every player's identity, including indices above 255.
  for Count in COUNTS do
    for Screens := 1 to 4 do
    begin
      Total := 0;
      for Screen := 1 to Screens do
        Inc(Total, GetScreenPlayerCount(Count, Screens, Screen));
      Assert(Total = Count);
      Assert(GetScreenPlayerCount(Count, Screens, 1) -
        GetScreenPlayerCount(Count, Screens, Screens) <= 1);
      for PlayerIndex := 0 to Count - 1 do
      begin
        Screen := GetPlayerScreen(PlayerIndex, Count, Screens);
        LocalIndex := GetPlayerIndexOnScreen(PlayerIndex, Count, Screens);
        Assert(InRange(Screen, 1, Screens));
        Assert(InRange(LocalIndex, 0, GetScreenPlayerCount(Count, Screens, Screen) - 1));
        Assert(GetFirstPlayerIndexForScreen(Count, Screens, Screen) + LocalIndex = PlayerIndex);
      end;
    end;

  // Grid slots must fit within the available area and remain separate.
  for Count in COUNTS do
  begin
    Grid := GetScorePlayerGrid(Count, 760, 420, 1);
    Assert(Grid.Cols * Grid.Rows >= Count);
    for I := 0 to Count - 1 do
    begin
      Rect := GetPlayerSlotRect(I, Grid, 20, 110, 760, 420);
      Assert((Rect.W > 0) and (Rect.H > 0));
      Assert((Rect.X >= 20) and (Rect.Y >= 110));
      Assert((Rect.X + Rect.W <= 780) and (Rect.Y + Rect.H <= 530));
      for J := 0 to I - 1 do
      begin
        Other := GetPlayerSlotRect(J, Grid, 20, 110, 760, 420);
        Assert((Rect.X + Rect.W <= Other.X) or (Other.X + Other.W <= Rect.X) or
          (Rect.Y + Rect.H <= Other.Y) or (Other.Y + Other.H <= Rect.Y));
      end;
    end;
  end;

  Config := Default(TSingPlayerLayoutConfig);
  Config.ColumnContainerLeft := 20;
  Config.ColumnContainerWidth := 760;
  Config.ColumnContainerTopReserved := 110;
  Config.ColumnContainerTopNoLyrics := 50;
  Config.LaneHeightReserved := 365;
  Config.LaneHeightNoLyrics := 425;
  Config.ColumnGap := 20;
  Config.BaseLineSpacing := 15;
  Config.GuideLineCount := 5;
  Config.RowAnchorGuideIndex := 3;
  Config.WidgetScaleBaseWidth := 355;
  Config.WidgetScaleMin := 0.2;
  for Count in COUNTS do
    for I := 0 to Count - 1 do
    begin
      Lane := GetSingLaneLayout(Count, I, Config, Odd(I));
      Assert((Lane.GridCols > 0) and (Lane.GridRows > 0));
      Assert(Lane.ColumnRight > Lane.ColumnLeft);
      Assert(Lane.NoteLineSpacing > 0);
    end;
  Lane := GetSingLaneLayout(0, 0, Config);
  Assert(Lane.ColumnWidth = 0);
  Assert(GetPlayerScreen(-1, 18, 2) = 0);
  Assert(GetScreenPlayerCount(18, 0, 1) = 0);

  // A finite palette must allow reuse instead of recursing forever.
  SetLength(Colors, 1025);
  for I := 0 to High(Colors) do
    Colors[I] := I mod 16 + 1;
  for I := 0 to High(Colors) do
    Assert(InRange(FindAvailablePlayerColor(I, I, 1, Length(Colors), 16, Colors), 1, 16));
  Colors[0] := 1;
  Colors[1] := 2;
  Assert(FindAvailablePlayerColor(1, 2, 1, 3, 16, Colors) = 3);
  Assert(FindAvailablePlayerColor(1, 2, -1, 3, 16, Colors) = 16);
  WriteLn('Player layout checks passed');
end.
