//+------------------------------------------------------------------+
//|                                              EA_MA_Cross_IFR.mq5 |
//|                                                     J.S Oliveira |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "J.S Oliveira"
#property link      "https://www.mql5.com"
#property version   "1.00"

//-- includes
#include <ChartObjects/ChartObjectsFibo.mqh>
#include <Trade/Trade.mqh>


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---



double meuArray[4]={3,2,1,17};
int total = 4;
for(int i=0;i<total;i++)
  {
   Print("Valor do meu array["+i+"]",meuArray[i]);
  }


   
  }
  
  
  enum ESTACOES_ANO
    {
     PRIMAVERA,
     VERAO,
     OUTONO,
     INVERNO,
     
    };
    
   ESTACOES_ANO estacao;
   estacao=verao;
   Print(estacao);
//+------------------------------------------------------------------+
