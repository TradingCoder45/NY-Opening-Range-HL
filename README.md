# NY Opening Range HL

A MetaTrader 5 (MT5) indicator that identifies the New York session opening candle and draws horizontal lines at its High and Low.

The indicator is designed for traders who want to monitor the New York opening range and study price reactions, breakouts, and rejections around these levels.

## Features

- Detects the New York session opening time.
- Supports a configurable opening candle timeframe.
- Draws the opening candle High and Low as horizontal line segments.
- Configurable line length in candles.
- Supports M1, M5, M15, M30, H1, and other MT5 timeframes.
- Automatically adjusts the label according to the selected timeframe.
- Optional labels:
  - `NY M15 High`
  - `NY M15 Low`
- Can display only the current day's levels.
- Can display historical NY opening levels.
- Handles New York daylight-saving-time changes.
- Works on XAUUSD and other instruments.

## Example

With:

- Opening Time: 09:30 New York time
- Opening Timeframe: M15
- Line Length: 10 bars

The indicator draws:

```text
NY M15 High  ──────────────────

              NY Opening Candle

NY M15 Low   ──────────────────

| Input           | Description                                               |
| --------------- | --------------------------------------------------------- |
| `InpOpeningTF`  | Timeframe used to determine the NY opening candle         |
| `InpNYHour`     | New York opening hour                                     |
| `InpNYMinute`   | New York opening minute                                   |
| `InpLineBars`   | Number of opening-timeframe bars for the horizontal lines |
| `InpTodayOnly`  | Show only today's levels or historical levels             |
| `InpShowLabels` | Enable/disable High and Low labels                        |
| `InpHighColor`  | Color of the NY High line                                 |
| `InpLowColor`   | Color of the NY Low line                                  |
| `InpLineStyle`  | Line style                                                |
| `InpLineWidth`  | Line width                                                |

Typical Configuration

For a 09:30 New York opening range using M15:

InpOpeningTF  = PERIOD_M15
InpNYHour     = 9
InpNYMinute   = 30
InpLineBars   = 10
InpTodayOnly  = true
InpShowLabels = true

The resulting levels will be labeled:

NY M15 High
NY M15 Low

Changing the timeframe to M5 automatically changes the labels to:

NY M5 High
NY M5 Low
Historical Levels

Set:

InpTodayOnly = false

to display the NY opening High/Low levels for historical trading days available in the chart's data.

Set:

InpTodayOnly = true

to display only the current day's NY opening range.

Trading Use

The indicator is intended primarily as a market-structure and research tool.

The NY opening High and Low can be used to study:

Breakouts
Breakout failures
Rejections
Retests
Momentum continuation
Range expansion
Support/resistance behavior

The indicator itself does not execute trades and does not provide trading signals.

Installation
Download or clone the repository.
Copy NY Opening Range HL.mq5 into:
MQL5/Indicators/
Open MetaTrader 5.
Open MetaEditor.
Compile the indicator.
Attach it to the desired chart.
Notes

The indicator converts the configured New York opening time to broker/server time and accounts for US daylight-saving-time rules.

Always verify the plotted opening candle against your broker's XAUUSD chart before using the levels for automated trading or strategy testing, because broker server-time conventions can differ.

License

No license is currently specified.