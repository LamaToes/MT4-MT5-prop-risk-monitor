//+------------------------------------------------------------------+
//| PROP STYLE RISK MONITOR - SAFETY PACK                            |
//| Created by: LamaToes                                             |
//| Enhanced with comprehensive safety features                      |
//| Free to use under MIT License                                    |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property strict

input double ReferenceBalance = 0;               // Reference Balance
input int    PanelCorner = 0;                    // Panel Corner (0=Top Left, 2=Bottom Left)
input bool   TrackBalanceDown = false;           // Track Balance Down Only
input bool   AutoTrackBalance = false;           // Auto Track Balance

// === SAFETY SETTINGS ===
input double MaxTotalRiskPercent = 5.0;          // Max Total Risk % (Alert Threshold)
input double MaxPerTradeRiskPercent = 2.0;       // Max Per Trade Risk % (Alert Threshold)
input int    MaxOpenPositions = 10;              // Max Open Positions (Alert Threshold)
input bool   UseEquityInsteadOfBalance = false;  // Use Equity Instead of Balance
input bool   EnableAlerts = true;                // Enable Audio/Visual Alerts
input bool   ShowTradesWithoutSL = true;         // Show Trades Without Stop Loss

// === DAILY LOSS LIMIT TRACKING ===
input bool   TrackDailyLoss = false;             // Track Daily Loss Limit
input double DailyLossLimitPercent = 5.0;        // Daily Loss Limit %
input double DailyLossLimitDollar = 5000;        // Daily Loss Limit $ (0 = use % only)
input string SessionResetTime = "00:00";         // Session Reset Time (HH:MM)

// === TRAILING DRAWDOWN (for Prop Firms) ===
input bool   TrackTrailingDrawdown = false;      // Track Trailing Drawdown
input double TrailingDrawdownPercent = 10.0;     // Trailing Drawdown %
input double TrailingDrawdownDollar = 10000;     // Trailing Drawdown $ (0 = use % only)

#define MAX_VISIBLE_TRADES 5

string HeaderLabel="PS_Header";
string RiskLabel="PS_Risk";
string MoneyLabel="PS_Money";
string BalanceLabel="PS_Balance";
string WarningLabel="PS_Warning";
string AlertLabel="PS_Alert";
string DailyLossLabel="PS_DailyLoss";
string TrailingDDLabel="PS_TrailingDD";
string NoSLLabel="PS_NoSL";
string PositionCountLabel="PS_PosCount";
string TradeLabels[MAX_VISIBLE_TRADES];

double CurrentTrackedBalance = 0;
double SessionStartBalance = 0;
double SessionStartEquity = 0;
double HighestBalance = 0;
double HighestEquity = 0;
datetime LastResetTime = 0;
bool AlertTriggered = false;

//+------------------------------------------------------------------+
void OnInit()
{
   // Initialize tracked balance
   if(CurrentTrackedBalance == 0)
   {
      CurrentTrackedBalance = ReferenceBalance;
   }
   
   // Initialize session tracking
   SessionStartBalance = AccountBalance();
   SessionStartEquity = AccountEquity();
   HighestBalance = AccountBalance();
   HighestEquity = AccountEquity();
   LastResetTime = TimeCurrent();
   
   // Validate settings
   if(ReferenceBalance <= 0)
   {
      Alert("WARNING: Please set ReferenceBalance in indicator settings!");
   }
}
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Clean up all objects on removal
   ObjectDelete(0,HeaderLabel);
   ObjectDelete(0,RiskLabel);
   ObjectDelete(0,MoneyLabel);
   ObjectDelete(0,BalanceLabel);
   ObjectDelete(0,WarningLabel);
   ObjectDelete(0,AlertLabel);
   ObjectDelete(0,DailyLossLabel);
   ObjectDelete(0,TrailingDDLabel);
   ObjectDelete(0,NoSLLabel);
   ObjectDelete(0,PositionCountLabel);
   
   for(int i=0;i<MAX_VISIBLE_TRADES;i++)
   {
      ObjectDelete(0,"PS_T"+IntegerToString(i));
   }
}
//+------------------------------------------------------------------+
void CheckSessionReset()
{
   if(!TrackDailyLoss && !TrackTrailingDrawdown) return;
   
   MqlDateTime currentTime, lastTime;
   TimeToStruct(TimeCurrent(), currentTime);
   TimeToStruct(LastResetTime, lastTime);
   
   // Parse reset time
   string parts[];
   int split = StringSplit(SessionResetTime, ':', parts);
   int resetHour = (split >= 1) ? (int)StringToInteger(parts[0]) : 0;
   int resetMinute = (split >= 2) ? (int)StringToInteger(parts[1]) : 0;
   
   // Check if we've passed the reset time
   bool shouldReset = false;
   
   if(currentTime.day != lastTime.day)
   {
      // Different day - check if we've passed reset time today
      if(currentTime.hour > resetHour || 
         (currentTime.hour == resetHour && currentTime.min >= resetMinute))
      {
         shouldReset = true;
      }
   }
   else if(currentTime.hour == resetHour && currentTime.min >= resetMinute && 
           lastTime.hour < resetHour)
   {
      // Same day, but crossed reset time
      shouldReset = true;
   }
   
   if(shouldReset)
   {
      SessionStartBalance = AccountBalance();
      SessionStartEquity = AccountEquity();
      LastResetTime = TimeCurrent();
      AlertTriggered = false;
   }
   
   // Update highest values for trailing drawdown
   if(AccountBalance() > HighestBalance) HighestBalance = AccountBalance();
   if(AccountEquity() > HighestEquity) HighestEquity = AccountEquity();
}
//+------------------------------------------------------------------+
void CreateLabel(string name,int y)
{
   ObjectDelete(0,name);
   ObjectCreate(0,name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_CORNER,PanelCorner);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);
   ObjectSetString(0,name,OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
}
//+------------------------------------------------------------------+
void UpdateTrackedBalance()
{
   double currentBalance = UseEquityInsteadOfBalance ? AccountEquity() : AccountBalance();
   
   if(AutoTrackBalance)
   {
      // Auto track: always use current balance/equity
      CurrentTrackedBalance = currentBalance;
   }
   else if(TrackBalanceDown)
   {
      // Track down only: update only if balance drops below initial reference
      if(currentBalance < ReferenceBalance)
      {
         CurrentTrackedBalance = currentBalance;
      }
      else
      {
         CurrentTrackedBalance = ReferenceBalance;
      }
   }
   else
   {
      // Default: use fixed reference balance
      CurrentTrackedBalance = ReferenceBalance;
   }
}
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],const double &high[],const double &low[],
                const double &close[],const long &tick_volume[],
                const long &volume[],const int &spread[])
{
   RefreshRates();
   UpdateTrackedBalance();
   CheckSessionReset();

   // === FIXED POSITIONS ===
   int yStart = 20;
   int yRisk = yStart;
   int yMoney = yStart + 18;
   int yBalance = yStart + 36;
   int yPosCount = yStart + 54;
   int yNoSL = yStart + 72;
   int yTrades = yStart + 95;
   int yDailyLoss = yStart + 195;
   int yTrailingDD = yStart + 213;
   int yWarning = yStart + 231;
   int yAlert = yStart + 249;
   int yHeader = yStart + 267;

   // HEADER
   CreateLabel(HeaderLabel,yHeader);
   ObjectSetInteger(0,HeaderLabel,OBJPROP_COLOR,clrWhite);
   ObjectSetInteger(0,HeaderLabel,OBJPROP_FONTSIZE,7);
   ObjectSetString(0,HeaderLabel,OBJPROP_TEXT,"= PROPstyle=by LamaToes");

   // === CALCULATE RISK ===
   double totalRisk=0;
   int tradeCount=0;
   int tradesWithoutSL=0;
   double maxSingleTradeRisk=0;
   
   // Clear old labels
   for(int i=0;i<MAX_VISIBLE_TRADES;i++)
   {
      TradeLabels[i]="PS_T"+IntegerToString(i);
      ObjectDelete(0,TradeLabels[i]);
   }

   // Loop through all orders
   for(int i=OrdersTotal()-1;i>=0;i--)
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderType()!=OP_BUY && OrderType()!=OP_SELL) continue;
      
      // Check for trades without SL
      if(OrderStopLoss()==0)
      {
         tradesWithoutSL++;
         continue;
      }

      double entry=OrderOpenPrice();
      double sl=OrderStopLoss();
      double lots=OrderLots();
      int orderType=OrderType();
      double point=MarketInfo(OrderSymbol(),MODE_POINT);
      double tickv=MarketInfo(OrderSymbol(),MODE_TICKVALUE);
      
      // Check if SL is at break even (no risk)
      if(MathAbs(sl - entry) < point * 2) // Within 2 pips = break even
      {
         continue; // Skip break-even trades, no risk
      }
      
      // Determine if position has profit locked in (SL beyond entry)
      bool isProfitLocked = false;
      if(orderType == OP_BUY && sl > entry) isProfitLocked = true;
      if(orderType == OP_SELL && sl < entry) isProfitLocked = true;

      double risk=MathAbs(entry-sl)/point*tickv*lots;
      double riskPercent = (CurrentTrackedBalance > 0) ? (risk/CurrentTrackedBalance)*100.0 : 0;
      
      // Only add to total risk if not profit-locked
      if(!isProfitLocked)
      {
         totalRisk+=risk;
         if(risk > maxSingleTradeRisk) maxSingleTradeRisk = risk;
      }

      if(tradeCount<MAX_VISIBLE_TRADES)
      {
         CreateLabel(TradeLabels[tradeCount],yTrades+tradeCount*15);
         
         // Color code by risk/profit
         color tc = clrWhite;
         string prefix = "";
         
         if(isProfitLocked)
         {
            tc = clrLime;
            prefix = "+";
         }
         else
         {
            if(riskPercent > MaxPerTradeRiskPercent) tc = clrRed;
            else if(riskPercent > MaxPerTradeRiskPercent*0.75) tc = clrYellow;
         }
         
         ObjectSetInteger(0,TradeLabels[tradeCount],OBJPROP_COLOR,tc);
         ObjectSetString(0,TradeLabels[tradeCount],OBJPROP_TEXT,
            "#"+IntegerToString(OrderTicket())+" "+OrderSymbol()+"  $"+DoubleToString(risk,2)+
            " ("+prefix+DoubleToString(riskPercent,2)+"%)");
      }

      tradeCount++;
   }

   if(tradeCount>MAX_VISIBLE_TRADES)
   {
      int extra=tradeCount-MAX_VISIBLE_TRADES;
      CreateLabel(TradeLabels[MAX_VISIBLE_TRADES-1],yTrades+(MAX_VISIBLE_TRADES-1)*15);
      ObjectSetString(0,TradeLabels[MAX_VISIBLE_TRADES-1],
         OBJPROP_TEXT,"+"+IntegerToString(extra)+" more positions");
      ObjectSetInteger(0,TradeLabels[MAX_VISIBLE_TRADES-1],OBJPROP_COLOR,clrGray);
   }

   // === TOTAL RISK % LINE ===
   double percent=(CurrentTrackedBalance>0)?(totalRisk/CurrentTrackedBalance)*100.0:0;

   color pc;
   if(totalRisk==0) pc=clrWhite;
   else if(percent<=1) pc=clrLime;
   else if(percent<=2) pc=clrYellow;
   else if(percent<=MaxTotalRiskPercent) pc=clrOrange;
   else pc=clrRed;

   CreateLabel(RiskLabel,yRisk);
   ObjectSetInteger(0,RiskLabel,OBJPROP_COLOR,pc);
   ObjectSetInteger(0,RiskLabel,OBJPROP_FONTSIZE,11);
   ObjectSetString(0,RiskLabel,OBJPROP_TEXT,
      "Total Risk: "+DoubleToString(percent,2)+"% of "+DoubleToString(CurrentTrackedBalance,0));

   // === MONEY LINE ===
   CreateLabel(MoneyLabel,yMoney);
   ObjectSetInteger(0,MoneyLabel,OBJPROP_COLOR,clrMagenta);
   ObjectSetInteger(0,MoneyLabel,OBJPROP_FONTSIZE,10);
   ObjectSetString(0,MoneyLabel,OBJPROP_TEXT,
      "Total Risk: $"+DoubleToString(totalRisk,2));

   // === BALANCE DISPLAY ===
   CreateLabel(BalanceLabel,yBalance);
   ObjectSetInteger(0,BalanceLabel,OBJPROP_COLOR,clrGray);
   ObjectSetInteger(0,BalanceLabel,OBJPROP_FONTSIZE,8);
   string balanceMode = "";
   if(AutoTrackBalance) balanceMode = " [Auto]";
   else if(TrackBalanceDown) balanceMode = " [Down Only]";
   else balanceMode = " [Fixed]";
   string balanceType = UseEquityInsteadOfBalance ? "Equity" : "Balance";
   ObjectSetString(0,BalanceLabel,OBJPROP_TEXT,
      "Tracking "+balanceType+": $"+DoubleToString(CurrentTrackedBalance,2)+balanceMode);

   // === POSITION COUNT ===
   CreateLabel(PositionCountLabel,yPosCount);
   color posColor = (tradeCount > MaxOpenPositions) ? clrRed : clrGray;
   ObjectSetInteger(0,PositionCountLabel,OBJPROP_COLOR,posColor);
   ObjectSetInteger(0,PositionCountLabel,OBJPROP_FONTSIZE,9);
   ObjectSetString(0,PositionCountLabel,OBJPROP_TEXT,
      "Open Positions: "+IntegerToString(tradeCount)+" / "+IntegerToString(MaxOpenPositions));

   // === TRADES WITHOUT STOP LOSS WARNING ===
   if(ShowTradesWithoutSL && tradesWithoutSL > 0)
   {
      CreateLabel(NoSLLabel,yNoSL);
      ObjectSetInteger(0,NoSLLabel,OBJPROP_COLOR,clrOrangeRed);
      ObjectSetInteger(0,NoSLLabel,OBJPROP_FONTSIZE,9);
      ObjectSetString(0,NoSLLabel,OBJPROP_TEXT,
         "WARNING: "+IntegerToString(tradesWithoutSL)+" trade(s) WITHOUT Stop Loss!");
   }
   else
   {
      ObjectDelete(0,NoSLLabel);
   }

   // === DAILY LOSS TRACKING ===
   if(TrackDailyLoss)
   {
      double currentValue = UseEquityInsteadOfBalance ? AccountEquity() : AccountBalance();
      double sessionStart = UseEquityInsteadOfBalance ? SessionStartEquity : SessionStartBalance;
      double dailyLoss = sessionStart - currentValue;
      double dailyLossPercent = (sessionStart > 0) ? (dailyLoss / sessionStart) * 100.0 : 0;
      
      double limit = DailyLossLimitDollar > 0 ? DailyLossLimitDollar : (sessionStart * DailyLossLimitPercent / 100.0);
      double limitPercent = DailyLossLimitPercent;
      
      color dlColor = clrGray;
      if(dailyLoss >= limit * 0.8) dlColor = clrOrange;
      if(dailyLoss >= limit) dlColor = clrRed;
      
      CreateLabel(DailyLossLabel,yDailyLoss);
      ObjectSetInteger(0,DailyLossLabel,OBJPROP_COLOR,dlColor);
      ObjectSetInteger(0,DailyLossLabel,OBJPROP_FONTSIZE,9);
      ObjectSetString(0,DailyLossLabel,OBJPROP_TEXT,
         "Daily Loss: $"+DoubleToString(dailyLoss,2)+" ("+DoubleToString(dailyLossPercent,2)+
         "%) / Limit: $"+DoubleToString(limit,2));
      
      // Alert if exceeded
      if(dailyLoss >= limit && EnableAlerts && !AlertTriggered)
      {
         Alert("DAILY LOSS LIMIT EXCEEDED! $"+DoubleToString(dailyLoss,2));
         AlertTriggered = true;
      }
   }
   else
   {
      ObjectDelete(0,DailyLossLabel);
   }

   // === TRAILING DRAWDOWN TRACKING ===
   if(TrackTrailingDrawdown)
   {
      double currentValue = UseEquityInsteadOfBalance ? AccountEquity() : AccountBalance();
      double highest = UseEquityInsteadOfBalance ? HighestEquity : HighestBalance;
      double drawdown = highest - currentValue;
      double drawdownPercent = (highest > 0) ? (drawdown / highest) * 100.0 : 0;
      
      double ddLimit = TrailingDrawdownDollar > 0 ? TrailingDrawdownDollar : 
                       (highest * TrailingDrawdownPercent / 100.0);
      
      color ddColor = clrGray;
      if(drawdown >= ddLimit * 0.8) ddColor = clrOrange;
      if(drawdown >= ddLimit) ddColor = clrRed;
      
      CreateLabel(TrailingDDLabel,yTrailingDD);
      ObjectSetInteger(0,TrailingDDLabel,OBJPROP_COLOR,ddColor);
      ObjectSetInteger(0,TrailingDDLabel,OBJPROP_FONTSIZE,9);
      ObjectSetString(0,TrailingDDLabel,OBJPROP_TEXT,
         "Trailing DD: $"+DoubleToString(drawdown,2)+" ("+DoubleToString(drawdownPercent,2)+
         "%) / Limit: $"+DoubleToString(ddLimit,2));
      
      // Alert if exceeded
      if(drawdown >= ddLimit && EnableAlerts)
      {
         Alert("TRAILING DRAWDOWN LIMIT REACHED! $"+DoubleToString(drawdown,2));
      }
   }
   else
   {
      ObjectDelete(0,TrailingDDLabel);
   }

   // === COMPREHENSIVE WARNING SYSTEM ===
   string warnings = "";
   color warnColor = clrGray;
   
   if(percent > MaxTotalRiskPercent)
   {
      warnings += "TOTAL RISK EXCEEDED ("+DoubleToString(percent,2)+"%) ";
      warnColor = clrRed;
      if(EnableAlerts && !AlertTriggered)
      {
         Alert("Total Risk Exceeded: "+DoubleToString(percent,2)+"%");
         AlertTriggered = true;
      }
   }
   
   if(tradeCount > MaxOpenPositions)
   {
      warnings += "TOO MANY POSITIONS ("+IntegerToString(tradeCount)+") ";
      warnColor = clrRed;
   }
   
   if(tradesWithoutSL > 0 && ShowTradesWithoutSL)
   {
      warnings += "MISSING STOP LOSS ";
      if(warnColor != clrRed) warnColor = clrOrange;
   }
   
   double maxSingleRiskPercent = (CurrentTrackedBalance > 0) ? 
                                  (maxSingleTradeRisk/CurrentTrackedBalance)*100.0 : 0;
   if(maxSingleRiskPercent > MaxPerTradeRiskPercent)
   {
      warnings += "SINGLE TRADE RISK HIGH ("+DoubleToString(maxSingleRiskPercent,2)+"%) ";
      if(warnColor != clrRed) warnColor = clrOrange;
   }
   
   if(CurrentTrackedBalance <= 0)
   {
      warnings = "PLEASE SET REFERENCE BALANCE IN SETTINGS!";
      warnColor = clrRed;
   }
   
   if(warnings != "")
   {
      CreateLabel(WarningLabel,yWarning);
      ObjectSetInteger(0,WarningLabel,OBJPROP_COLOR,warnColor);
      ObjectSetInteger(0,WarningLabel,OBJPROP_FONTSIZE,9);
      ObjectSetString(0,WarningLabel,OBJPROP_TEXT,warnings);
   }
   else
   {
      ObjectDelete(0,WarningLabel);
   }
   
   // === STATUS MESSAGE ===
   if(warnings == "" && totalRisk > 0)
   {
      CreateLabel(AlertLabel,yAlert);
      ObjectSetInteger(0,AlertLabel,OBJPROP_COLOR,clrLime);
      ObjectSetInteger(0,AlertLabel,OBJPROP_FONTSIZE,8);
      ObjectSetString(0,AlertLabel,OBJPROP_TEXT,"All safety checks passed");
   }
   else
   {
      ObjectDelete(0,AlertLabel);
   }

   return(rates_total);
}
//+------------------------------------------------------------------+
