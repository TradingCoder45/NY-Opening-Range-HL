//+------------------------------------------------------------------+
//|                                      NY Opening Range HL.mq5      |
//|                                                                  |
//|        New York Session Opening Candle High / Low                |
//+------------------------------------------------------------------+
#property copyright "Trading Coder"
#property version   "2.00"
#property indicator_chart_window
#property indicator_plots 0

//+------------------------------------------------------------------+
//| INPUTS                                                           |
//+------------------------------------------------------------------+

input ENUM_TIMEFRAMES InpOpeningTF = PERIOD_M15;
// Opening candle timeframe

input int InpNYHour = 9;
// New York opening hour

input int InpNYMinute = 30;
// New York opening minute

input int InpLineBars = 10;
// Length of horizontal lines in opening-TF bars

input bool InpTodayOnly = true;
// true  = today's lines only
// false = all available days in chart history

input bool InpShowLabels = true;
// Show NY High / NY Low labels

input color InpHighColor = clrLimeGreen;
input color InpLowColor  = clrTomato;

input ENUM_LINE_STYLE InpLineStyle = STYLE_SOLID;
input int InpLineWidth = 2;


//+------------------------------------------------------------------+
//| PREFIXES                                                         |
//+------------------------------------------------------------------+

string HIGH_PREFIX = "NYOR_HIGH_";
string LOW_PREFIX  = "NYOR_LOW_";
string TEXT_PREFIX = "NYOR_TEXT_";


//+------------------------------------------------------------------+
//| INITIALIZATION                                                   |
//+------------------------------------------------------------------+

int OnInit()
{
   IndicatorSetString(
      INDICATOR_SHORTNAME,
      "NY Opening Range HL"
   );

   DeleteObjects();

   return(INIT_SUCCEEDED);
}


//+------------------------------------------------------------------+
//| DEINITIALIZATION                                                 |
//+------------------------------------------------------------------+

void OnDeinit(const int reason)
{
   DeleteObjects();
}


//+------------------------------------------------------------------+
//| CALCULATION                                                      |
//+------------------------------------------------------------------+

int OnCalculate(
   const int rates_total,
   const int prev_calculated,
   const datetime &time[],
   const double &open[],
   const double &high[],
   const double &low[],
   const double &close[],
   const long &tick_volume[],
   const long &volume[],
   const int &spread[]
)
{
   if(rates_total < 10)
      return(rates_total);

   static datetime lastBarTime = 0;

   // Rebuild when a new chart candle appears
   if(prev_calculated > 0 &&
      time[0] == lastBarTime)
   {
      return(rates_total);
   }

   lastBarTime = time[0];

   DrawOpeningRanges();

   return(rates_total);
}


//+------------------------------------------------------------------+
//| DRAW ALL OPENING RANGES                                          |
//+------------------------------------------------------------------+

void DrawOpeningRanges()
{
   // ---------------------------------------------------------------
   // Delete existing objects first
   // ---------------------------------------------------------------

   DeleteObjects();

   // ---------------------------------------------------------------
   // Determine the current chart/server day
   // ---------------------------------------------------------------

   datetime currentTime = TimeCurrent();

   MqlDateTime now;
   TimeToStruct(currentTime, now);

   datetime todayStart = MakeDateTime(
      now.year,
      now.mon,
      now.day,
      0,
      0,
      0
   );

   // ---------------------------------------------------------------
   // TODAY ONLY
   // ---------------------------------------------------------------

   if(InpTodayOnly)
   {
      DrawOpeningRangeForDay(todayStart);

      ChartRedraw();

      return;
   }

   // ---------------------------------------------------------------
   // ALL DAYS
   //
   // Instead of guessing how many days are visible, obtain the
   // actual available bars from the chart timeframe.
   // ---------------------------------------------------------------

   int totalBars = Bars(
      _Symbol,
      _Period
   );

   if(totalBars <= 0)
      return;

   // ---------------------------------------------------------------
   // Determine oldest available chart bar
   // ---------------------------------------------------------------

   datetime oldestTime = iTime(
      _Symbol,
      _Period,
      totalBars - 1
   );

   if(oldestTime <= 0)
      return;

   MqlDateTime oldest;
   TimeToStruct(oldestTime, oldest);

   datetime oldestDay = MakeDateTime(
      oldest.year,
      oldest.mon,
      oldest.day,
      0,
      0,
      0
   );

   // ---------------------------------------------------------------
   // Walk through every calendar day
   // ---------------------------------------------------------------

   datetime day = oldestDay;

   while(day <= todayStart)
   {
      DrawOpeningRangeForDay(day);

      day += 86400;
   }

   ChartRedraw();
}


//+------------------------------------------------------------------+
//| DRAW OPENING RANGE FOR ONE DAY                                   |
//+------------------------------------------------------------------+

void DrawOpeningRangeForDay(datetime dayStart)
{
   MqlDateTime d;
   TimeToStruct(dayStart, d);

   // ---------------------------------------------------------------
   // Calculate NY opening time
   // ---------------------------------------------------------------

   datetime openingTime = GetNYOpeningTime(
      d.year,
      d.mon,
      d.day
   );

   if(openingTime <= 0)
      return;

   // ---------------------------------------------------------------
   // Find opening candle
   // ---------------------------------------------------------------

   int shift = iBarShift(
      _Symbol,
      InpOpeningTF,
      openingTime,
      false
   );

   if(shift < 0)
      return;

   // ---------------------------------------------------------------
   // Get candle time
   // ---------------------------------------------------------------

   datetime candleTime = iTime(
      _Symbol,
      InpOpeningTF,
      shift
   );

   if(candleTime <= 0)
      return;

   // ---------------------------------------------------------------
   // Important:
   //
   // Make sure the candle actually belongs to the requested day.
   // ---------------------------------------------------------------

   MqlDateTime candleDate;
   TimeToStruct(candleTime, candleDate);

   if(candleDate.year != d.year ||
      candleDate.mon  != d.mon  ||
      candleDate.day  != d.day)
   {
      return;
   }

   // ---------------------------------------------------------------
   // Read HIGH / LOW
   // ---------------------------------------------------------------

   double candleHigh = iHigh(
      _Symbol,
      InpOpeningTF,
      shift
   );

   double candleLow = iLow(
      _Symbol,
      InpOpeningTF,
      shift
   );

   if(candleHigh <= 0 ||
      candleLow <= 0)
   {
      return;
   }

   // ---------------------------------------------------------------
   // Make sure the opening candle is actually after NY opening time
   // ---------------------------------------------------------------

   if(candleTime < openingTime)
      return;

   // ---------------------------------------------------------------
   // Calculate line ending time
   // ---------------------------------------------------------------

   int tfSeconds = PeriodSeconds(
      InpOpeningTF
   );

   if(tfSeconds <= 0)
      return;

   datetime endTime =
      candleTime +
      (datetime)(tfSeconds * InpLineBars);

   // ---------------------------------------------------------------
   // Unique date ID
   // ---------------------------------------------------------------

   string dateID = StringFormat(
      "%04d%02d%02d",
      candleDate.year,
      candleDate.mon,
      candleDate.day
   );

   // ---------------------------------------------------------------
   // Object names
   // ---------------------------------------------------------------

   string highName =
      HIGH_PREFIX + dateID;

   string lowName =
      LOW_PREFIX + dateID;

   // ---------------------------------------------------------------
   // DRAW HIGH
   // ---------------------------------------------------------------

   DrawHorizontalSegment(
      highName,
      candleTime,
      candleHigh,
      endTime,
      candleHigh,
      InpHighColor
   );

   // ---------------------------------------------------------------
   // DRAW LOW
   // ---------------------------------------------------------------

   DrawHorizontalSegment(
      lowName,
      candleTime,
      candleLow,
      endTime,
      candleLow,
      InpLowColor
   );

   // ---------------------------------------------------------------
   // LABELS
   // ---------------------------------------------------------------

   if(InpShowLabels)
   {
      string tfName = TimeframeToString(InpOpeningTF);
   
      string highLabel = " NY " + tfName + " High";
      string lowLabel  = " NY " + tfName + " Low";
   
      DrawLabel(
         TEXT_PREFIX + "HIGH_" + dateID,
         endTime,
         candleHigh,
         highLabel,
         InpHighColor
      );
   
      DrawLabel(
         TEXT_PREFIX + "LOW_" + dateID,
         endTime,
         candleLow,
         lowLabel,
         InpLowColor
      );
   }
}


//+------------------------------------------------------------------+
//| DRAW HORIZONTAL LINE SEGMENT                                     |
//+------------------------------------------------------------------+

void DrawHorizontalSegment(
   string name,
   datetime time1,
   double price1,
   datetime time2,
   double price2,
   color clr
)
{
   if(ObjectFind(0, name) < 0)
   {
      ObjectCreate(
         0,
         name,
         OBJ_TREND,
         0,
         time1,
         price1,
         time2,
         price2
      );
   }
   else
   {
      ObjectMove(
         0,
         name,
         0,
         time1,
         price1
      );

      ObjectMove(
         0,
         name,
         1,
         time2,
         price2
      );
   }

   ObjectSetInteger(
      0,
      name,
      OBJPROP_COLOR,
      clr
   );

   ObjectSetInteger(
      0,
      name,
      OBJPROP_STYLE,
      InpLineStyle
   );

   ObjectSetInteger(
      0,
      name,
      OBJPROP_WIDTH,
      InpLineWidth
   );

   ObjectSetInteger(
      0,
      name,
      OBJPROP_RAY_RIGHT,
      false
   );

   ObjectSetInteger(
      0,
      name,
      OBJPROP_RAY_LEFT,
      false
   );

   ObjectSetInteger(
      0,
      name,
      OBJPROP_BACK,
      false
   );

   ObjectSetInteger(
      0,
      name,
      OBJPROP_SELECTABLE,
      false
   );

   ObjectSetInteger(
      0,
      name,
      OBJPROP_SELECTED,
      false
   );

   ObjectSetInteger(
      0,
      name,
      OBJPROP_HIDDEN,
      true
   );
}


//+------------------------------------------------------------------+
//| DRAW TEXT LABEL                                                  |
//+------------------------------------------------------------------+

void DrawLabel(
   string name,
   datetime time,
   double price,
   string text,
   color clr
)
{
   if(ObjectFind(0, name) < 0)
   {
      ObjectCreate(
         0,
         name,
         OBJ_TEXT,
         0,
         time,
         price
      );
   }
   else
   {
      ObjectMove(
         0,
         name,
         0,
         time,
         price
      );
   }

   ObjectSetString(
      0,
      name,
      OBJPROP_TEXT,
      text
   );

   ObjectSetString(
      0,
      name,
      OBJPROP_FONT,
      "Arial"
   );

   ObjectSetInteger(
      0,
      name,
      OBJPROP_FONTSIZE,
      8
   );

   ObjectSetInteger(
      0,
      name,
      OBJPROP_COLOR,
      clr
   );

   ObjectSetInteger(
      0,
      name,
      OBJPROP_ANCHOR,
      ANCHOR_LEFT
   );

   ObjectSetInteger(
      0,
      name,
      OBJPROP_SELECTABLE,
      false
   );

   ObjectSetInteger(
      0,
      name,
      OBJPROP_HIDDEN,
      true
   );
}


//+------------------------------------------------------------------+
//| MAKE DATETIME                                                    |
//+------------------------------------------------------------------+

datetime MakeDateTime(
   int year,
   int month,
   int day,
   int hour,
   int minute,
   int second
)
{
   MqlDateTime dt;

   ZeroMemory(dt);

   dt.year = year;
   dt.mon  = month;
   dt.day  = day;
   dt.hour = hour;
   dt.min  = minute;
   dt.sec  = second;

   return(StructToTime(dt));
}


//+------------------------------------------------------------------+
//| GET NY OPENING TIME                                              |
//+------------------------------------------------------------------+

datetime GetNYOpeningTime(
   int year,
   int month,
   int day
)
{
   // ---------------------------------------------------------------
   // New York:
   //
   // EST = UTC-5
   // EDT = UTC-4
   // ---------------------------------------------------------------

   bool dst = IsNewYorkDST(
      year,
      month,
      day
   );

   int utcOffset;

   if(dst)
      utcOffset = -4;
   else
      utcOffset = -5;

   // ---------------------------------------------------------------
   // NY local 09:30
   // ---------------------------------------------------------------

   datetime nyTime = MakeDateTime(
      year,
      month,
      day,
      InpNYHour,
      InpNYMinute,
      0
   );

   // ---------------------------------------------------------------
   // NY -> UTC
   // ---------------------------------------------------------------

   datetime utcTime =
      nyTime - utcOffset * 3600;

   // ---------------------------------------------------------------
   // UTC -> broker server time
   //
   // Use current server/UTC offset.
   // ---------------------------------------------------------------

   datetime serverNow = TimeTradeServer();
   datetime utcNow    = TimeGMT();

   long serverOffset =
      (long)(serverNow - utcNow);

   datetime serverTime =
      utcTime + serverOffset;

   return(serverTime);
}


//+------------------------------------------------------------------+
//| NEW YORK DST                                                     |
//+------------------------------------------------------------------+

bool IsNewYorkDST(
   int year,
   int month,
   int day
)
{
   // January / February
   if(month < 3)
      return(false);

   // December
   if(month > 11)
      return(false);

   // ---------------------------------------------------------------
   // Second Sunday in March
   // ---------------------------------------------------------------

   datetime marchFirst = MakeDateTime(
      year,
      3,
      1,
      0,
      0,
      0
   );

   MqlDateTime march;
   TimeToStruct(
      marchFirst,
      march
   );

   int firstSundayMarch =
      1 + ((7 - march.day_of_week) % 7);

   int secondSundayMarch =
      firstSundayMarch + 7;

   // ---------------------------------------------------------------
   // First Sunday in November
   // ---------------------------------------------------------------

   datetime novemberFirst = MakeDateTime(
      year,
      11,
      1,
      0,
      0,
      0
   );

   MqlDateTime november;
   TimeToStruct(
      novemberFirst,
      november
   );

   int firstSundayNovember =
      1 + ((7 - november.day_of_week) % 7);

   // ---------------------------------------------------------------
   // March
   // ---------------------------------------------------------------

   if(month == 3)
   {
      if(day < secondSundayMarch)
         return(false);

      return(true);
   }

   // ---------------------------------------------------------------
   // November
   // ---------------------------------------------------------------

   if(month == 11)
   {
      if(day >= firstSundayNovember)
         return(false);

      return(true);
   }

   // ---------------------------------------------------------------
   // April -> October
   // ---------------------------------------------------------------

   return(true);
}


//+------------------------------------------------------------------+
//| DELETE INDICATOR OBJECTS                                         |
//+------------------------------------------------------------------+

void DeleteObjects()
{
   int total = ObjectsTotal(
      0,
      -1,
      -1
   );

   for(int i = total - 1; i >= 0; i--)
   {
      string name = ObjectName(
         0,
         i,
         -1,
         -1
      );

      if(StringFind(
            name,
            HIGH_PREFIX
         ) == 0)
      {
         ObjectDelete(
            0,
            name
         );
      }
      else
      if(StringFind(
            name,
            LOW_PREFIX
         ) == 0)
      {
         ObjectDelete(
            0,
            name
         );
      }
      else
      if(StringFind(
            name,
            TEXT_PREFIX
         ) == 0)
      {
         ObjectDelete(
            0,
            name
         );
      }
   }
}


string TimeframeToString(ENUM_TIMEFRAMES tf)
{
   switch(tf)
   {
      case PERIOD_M1:
         return "M1";

      case PERIOD_M2:
         return "M2";

      case PERIOD_M3:
         return "M3";

      case PERIOD_M4:
         return "M4";

      case PERIOD_M5:
         return "M5";

      case PERIOD_M6:
         return "M6";

      case PERIOD_M10:
         return "M10";

      case PERIOD_M12:
         return "M12";

      case PERIOD_M15:
         return "M15";

      case PERIOD_M20:
         return "M20";

      case PERIOD_M30:
         return "M30";

      case PERIOD_H1:
         return "H1";

      case PERIOD_H2:
         return "H2";

      case PERIOD_H3:
         return "H3";

      case PERIOD_H4:
         return "H4";

      case PERIOD_H6:
         return "H6";

      case PERIOD_H8:
         return "H8";

      case PERIOD_H12:
         return "H12";

      case PERIOD_D1:
         return "D1";

      case PERIOD_W1:
         return "W1";

      case PERIOD_MN1:
         return "MN1";
   }

   return "TF";
}
//+------------------------------------------------------------------+