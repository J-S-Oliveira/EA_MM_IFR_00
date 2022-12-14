//+------------------------------------------------------------------+
//|                                              CruzamentoMedia.mq5 |
//|                                      Copyright 2020,Lethan Corp. |
//|                           https://www.mql5.com/pt/users/14134597 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020,Lethan Corp."
#property link      "https://www.mql5.com/pt/users/14134597"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include <CruzamentoMedia\Libraries\Service\Engine.mqh>

#include <ClassControlPanel.mqh>
#include <Trade\SymbolInfo.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CEngine *engine;
CControlPainel      ObjName(0,0.25,0.75,5,5,CORNER_LEFT_UPPER, "Painel Medias Moveis");
CSymbolInfo       CurrentRates;

input group   "moving average"
input int                ma_fast_perio        = 8;
input int                ma_fast_shift        = 0;
input ENUM_MA_METHOD     ma_fast_method       = MODE_EMA;
input ENUM_APPLIED_PRICE ma_fast_appied_price = PRICE_CLOSE;
input int                ma_slow_perio        = 17;
input int                ma_slow_shift        = 0;
input ENUM_MA_METHOD     ma_slow_method       = MODE_EMA;
input ENUM_APPLIED_PRICE ma_slow_appied_price = PRICE_CLOSE;
input group   "Expert"
sinput uint            magicNumber     = 123;
sinput ulong           desvPts         = 0;
sinput double          inpLot          = 1;
sinput TypeEvent       inpEvent        = EVENT_NEW_BAR;
sinput bool            reversePosition = false;
sinput string          startTime       = "10:40";
sinput string          endTime         = "16:06";
sinput string          closingTime     = "17:32";

bool                m_state = true;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   ObjName.CreatePanel();
   ObjName.CreateText("  Ativo         Tipo       Volume      Preço Atual ",clrBlack,9);
   ObjName.CreateText("------------------------------------------------------",clrBlack,9);
   ObjName.CreateText("",clrBlack,9);
   ObjName.CreateButton("Play",clrBlack,clrGreen);
   ObjName.CreateButton("Pause",clrBlack,clrRed);
   ObjName.CreateText("Estado Negociações  ",clrBlack);
   ObjName.CreateText("Position result: 0.0",clrBlack);
   CurrentRates.Name(Symbol());
//--- moving average configuration

   if(engine == NULL)
      engine = new CEngine();
   
   engine.m_fast_ma.Symbol(Symbol());
   engine.m_fast_ma.Timeframe(Period());
   engine.m_fast_ma.MaPeriod(ma_fast_perio);
   engine.m_fast_ma.MaShift(ma_fast_shift);
   engine.m_fast_ma.MaMethod(ma_fast_method);
   engine.m_fast_ma.AppliedPrice(ma_fast_appied_price);
   engine.m_fast_ma.MaInit();

   engine.m_slow_ma.Symbol(Symbol());
   engine.m_slow_ma.Timeframe(Period());
   engine.m_slow_ma.MaPeriod(ma_slow_perio);
   engine.m_slow_ma.MaShift(ma_slow_shift);
   engine.m_slow_ma.MaMethod(ma_slow_method);
   engine.m_slow_ma.AppliedPrice(ma_slow_appied_price);
   engine.m_slow_ma.MaInit();

//-- Expert configuration
   engine.MagicNumber(magicNumber);
   engine.Deviation(desvPts);
   engine.Lot(inpLot);
   engine.ReversePosition(reversePosition);
   engine.Time(startTime, endTime, closingTime);
   engine.Event(inpEvent);

   if(engine.OnInit())
      return(INIT_SUCCEEDED);

   return(INIT_FAILED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   if(engine!=NULL)
     {
      delete engine;
      engine=NULL;
     }

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   ::Painel();
   if(m_state)
      engine.OnTick();
  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long& lparam,
                  const double& dparam,
                  const string& sparam
                 )
  {
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      if(ObjName.ButtonGetState(1))
        {
         m_state = true;
         ObjName.ButtonSetState(1,false);
        }

      if(ObjName.ButtonGetState(2))
        {
         m_state = false;
         ObjName.ButtonSetState(2,false);
        }

     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Painel(void)
  {
  
   ObjName.PanelModifyInteger(PANEL_BGCOLOR,clrAliceBlue);
   ObjName.PanelModifyInteger(PANEL_BORDERCOLOR,clrAquamarine);
   ObjName.PanelModifyInteger(PANEL_BORDERTYPE,BORDER_SUNKEN);
   ObjName.PanelModifyInteger(PANEL_CORNERPOSITION,CORNER_LEFT_UPPER);
   
   CurrentRates.RefreshRates();

   if(engine.Comprado())
      ObjName.TextModifyString(3,TEXT_TEXTSHOW,Symbol()+"      BUY           "+(string)inpLot+"            "+(string)CurrentRates.Last());

   if(engine.Vendido())
      ObjName.TextModifyString(3,TEXT_TEXTSHOW,Symbol()+"      SELL          "+(string)inpLot+"            "+(string)CurrentRates.Last());
   else
      ObjName.TextModifyString(3,TEXT_TEXTSHOW,Symbol()+"                    "+(string)inpLot+"            "+(string)CurrentRates.Last());
   
   string estado_negociacao = (m_state)?"Ativo":"Pausado";
   ObjName.TextModifyString(4,TEXT_TEXTSHOW,"Estado Negociações "+estado_negociacao);

   double Result=GetPositionResult();
   string SResult=DoubleToString(Result,2);
   ObjName.TextModifyString(5,TEXT_TEXTSHOW,"Position result: "+SResult);

   if(Result>0)
     {
      ObjName.TextModifyInteger(5,TEXT_FONTCOLOR,clrGreen);
      return;
     }
   if(Result<0)
     {
      ObjName.TextModifyInteger(5,TEXT_FONTCOLOR,clrRed);
     }
   else
     {
      ObjName.TextModifyInteger(5,TEXT_FONTCOLOR,clrBlack);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetPositionResult(void)
  {
   double temp=0;
   int N=PositionsTotal();
   ulong Ticket;
   for(int i=N-1; i>=0; i--)
     {
      Ticket=PositionGetTicket(i);
      temp+=PositionGetDouble(POSITION_PROFIT);
     }
   return temp;

  }