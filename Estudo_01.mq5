//+------------------------------------------------------------------+
//|                                                    Estudo_01.mq5 |
//|                                                     J.S Oliveira |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "J.S Oliveira"
#property link      "https://www.mql5.com"
#property version   "1.01"

// MME
int mm_Handle;
double mm_Buffer[];
int mm_Period = 7;

//IFR
int ifr_Handle;
double ifr_Buffer[];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   mm_Handle = iMA(_Symbol,_Period,mm_Period,0,MODE_EMA,PRICE_CLOSE);
   
   ifr_Handle = iRSI(_Symbol,_Period,3,PRICE_CLOSE);
   
   if(mm_Handle<0 || ifr_Handle<0)
     {
      Alert("Erro to create Handle's indicator : ",GetLastError(),"!");
      return(-1);
     }
     
     ChartIndicatorAdd(0,0,mm_Handle);//add chart to indicator 
     ChartIndicatorAdd(0,1,ifr_Handle);
     
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
IndicatorRelease(mm_Handle); // Remove o indicador quando retirar a EA
IndicatorRelease(ifr_Handle);   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   CopyBuffer(mm_Handle,0,0,3,mm_Buffer); // copia um vetor de tamanho 3 do mm_handle para o mm_buffer
   CopyBuffer(ifr_Handle,0,0,3,ifr_Buffer);
   
   ArraySetAsSeries(mm_Buffer,true);// Ordenando o vetor de dados 
   ArraySetAsSeries(ifr_Buffer,true);
   
   Print("mm_Buffer  = ",mm_Buffer[0]);
   Print("ifr_Buffer = ",ifr_Buffer[0]);
   Print("-------------------------------");
  }
//+------------------------------------------------------------------+
