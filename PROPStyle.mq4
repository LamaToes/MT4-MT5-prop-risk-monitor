//+------------------------------------------------------------------+
//| PROP STYLE RISK MONITOR                                          |
//| Created by: LamaToes                                             |
//| Free to use under MIT License                                    |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property strict

input double ReferenceBalance = 100000;
input int PanelCorner = 0; // 0 = Top Left, 2 = Bottom Left

#define MAX_VISIBLE_TRADES 7

string HeaderLabel="PS_Header";
string RiskLabel="PS_Risk";
string MoneyLabel="PS_Money";
string TradeLabels[MAX_VISIBLE_TRADES];

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
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],const double &high[],const double &low[],
                const double &close[],const long &tick_volume[],
                const long &volume[],const int &spread[])
{
   RefreshRates();

   // === FIXED POSITIONS ===
   int yHeader = 165;
   int yRisk   = 25;
   int yTrades = 45;
   int yMoney  = 153;

   // HEADER
   CreateLabel(HeaderLabel,yHeader);
   ObjectSetInteger(0,HeaderLabel,OBJPROP_COLOR,clrWhite);
   ObjectSetInteger(0,HeaderLabel,OBJPROP_FONTSIZE,7);
   ObjectSetString(0,HeaderLabel,OBJPROP_TEXT,"= PROPstyle=by LamaToes");

   // === CALCULATE RISK ===
   double totalRisk=0;
   int tradeCount=0;

   for(int i=0;i<MAX_VISIBLE_TRADES;i++)
   {
      TradeLabels[i]="PS_T"+IntegerToString(i);
      ObjectDelete(0,TradeLabels[i]);
   }

   for(int i=OrdersTotal()-1;i>=0;i--)
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderType()!=OP_BUY && OrderType()!=OP_SELL) continue;
      if(OrderStopLoss()==0) continue;

      double entry=OrderOpenPrice();
      double sl=OrderStopLoss();
      double lots=OrderLots();
      double point=MarketInfo(OrderSymbol(),MODE_POINT);
      double tickv=MarketInfo(OrderSymbol(),MODE_TICKVALUE);

      double risk=MathAbs(entry-sl)/point*tickv*lots;
      totalRisk+=risk;

      if(tradeCount<MAX_VISIBLE_TRADES)
      {
         CreateLabel(TradeLabels[tradeCount],yTrades+tradeCount*15);
         ObjectSetInteger(0,TradeLabels[tradeCount],OBJPROP_COLOR,clrWhite);
         ObjectSetString(0,TradeLabels[tradeCount],OBJPROP_TEXT,
            "#"+IntegerToString(OrderTicket())+" "+OrderSymbol()+"  $"+DoubleToString(risk,2));
      }

      tradeCount++;
   }

   if(tradeCount>MAX_VISIBLE_TRADES)
   {
      int extra=tradeCount-MAX_VISIBLE_TRADES;
      CreateLabel(TradeLabels[MAX_VISIBLE_TRADES-1],yTrades+(MAX_VISIBLE_TRADES-1)*15);
      ObjectSetString(0,TradeLabels[MAX_VISIBLE_TRADES-1],
         OBJPROP_TEXT,"+"+IntegerToString(extra)+" more positions");
         ObjectSetInteger(0,TradeLabels[MAX_VISIBLE_TRADES-1],OBJPROP_COLOR,clrWhite);

   }

   // === RISK % LINE ===
   double percent=(ReferenceBalance>0)?(totalRisk/ReferenceBalance)*100.0:0;

   color pc;
   if(totalRisk==0) pc=clrWhite;
   else if(percent<=1) pc=clrLime;
   else if(percent<=2) pc=clrYellow;
   else pc=clrRed;

   CreateLabel(RiskLabel,yRisk);
   ObjectSetInteger(0,RiskLabel,OBJPROP_COLOR,pc);
   ObjectSetInteger(0,RiskLabel,OBJPROP_FONTSIZE,11);
   ObjectSetString(0,RiskLabel,OBJPROP_TEXT,
      "Risk: "+DoubleToString(percent,2)+"% of "+DoubleToString(ReferenceBalance,0));

   // === MONEY LINE ===
   CreateLabel(MoneyLabel,yMoney);
   ObjectSetInteger(0,MoneyLabel,OBJPROP_COLOR,clrMagenta);
   ObjectSetInteger(0,MoneyLabel,OBJPROP_FONTSIZE,11);
   ObjectSetString(0,MoneyLabel,OBJPROP_TEXT,
      "Total Risk: $"+DoubleToString(totalRisk,2));

   return(rates_total);
}
//+------------------------------------------------------------------+
