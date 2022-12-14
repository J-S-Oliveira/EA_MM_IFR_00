//+------------------------------------------------------------------+
//|                                                    Estudo_02.mq5 |
//|                                                     J.S Oliveira |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "J.S Oliveira"
#property link      "https://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//|  Begin                                                           |
//+------------------------------------------------------------------+
sinput group                                    "MOVIE AVERANGE DEFINITIONS"
input int ma_fast_period                        =  9;
input int ma_slow_period                        = 21;
input ENUM_TIMEFRAMES ma_time_frame             = PERIOD_CURRENT;
input ENUM_MA_METHOD ma_method                  = MODE_EMA;
input ENUM_APPLIED_PRICE ma_price               = PRICE_CLOSE;

sinput group                                    "MANEGMENT"
input int num_lots                              = 100;
input double TK                                 = 60;
input double SL                                 = 30;
input string limit_close_op                     = "17:40";

//+------------------------------------------------------------------+
//|  Variables for indicators                                        |
//+------------------------------------------------------------------+

int      ma_fast_Handle;
double   ma_fast_Buffer[];

int      ma_slow_Handle;
double   ma_slow_Buffer[];


//+------------------------------------------------------------------+
//|  Variables for function                                          |
//+------------------------------------------------------------------+

int magic_number                                =  123456;
MqlRates  candle[];
MqlTick   tick;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
        if(ma_fast_period > ma_slow_period)
        {
         Alert("ERRO SMALLER NUMBER FOR FAST MEDIA   ",GetLastError(),"!");
         return(-1);
        }
        
      ma_fast_Handle =  iMA(_Symbol,ma_time_frame,ma_fast_period,0,ma_method,ma_price);
      ma_slow_Handle =  iMA(_Symbol,ma_time_frame,ma_slow_period,0,ma_method,ma_price);
      
      if(ma_fast_Handle<0 || ma_slow_Handle <0)
        {
         Alert("ERRO TRYING TO CREATE HANDLES FOR IMA",GetLastError(),"!");
         return(-1);
        }
         
         
        CopyRates(_Symbol,_Period,0,4,candle);
        ArraySetAsSeries(candle,true);
        
        ChartIndicatorAdd(0,0,ma_fast_Handle);
        ChartIndicatorAdd(0,0,ma_slow_Handle); 
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
         IndicatorRelease(ma_fast_Handle); // deveria tirar os indicadores quando o robo sai do grafico mas n esta fazendo isso!
         IndicatorRelease(ma_slow_Handle);
         
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

      CopyBuffer(ma_fast_Handle,0,0,4,ma_fast_Buffer);
      CopyBuffer(ma_slow_Handle,0,0,4,ma_slow_Buffer);
      
      CopyRates(_Symbol,_Period,0,4,candle);
      ArraySetAsSeries(candle,true);
      
      ArraySetAsSeries(ma_fast_Buffer,true);
      ArraySetAsSeries(ma_slow_Buffer,true);
      
      SymbolInfoTick(_Symbol,tick);
      
      
      // LOGIC TO ACTIVE THE BUY
      bool buy_ma_cros  =  ma_fast_Buffer[0] >  ma_slow_Buffer[0] &&
                           ma_fast_Buffer[2] <  ma_slow_Buffer[2] ;
                           
                      
      // LOGIC TO ACTIVE THE SELL
      bool sell_ma_cros =  ma_slow_Buffer[0] >  ma_fast_Buffer[0] &&
                           ma_slow_Buffer[2] <  ma_fast_Buffer[2] ;
   
  }
//+------------------------------------------------------------------+
