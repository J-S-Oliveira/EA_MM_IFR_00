//+------------------------------------------------------------------+
//|                                                        mm_02.mq5 |
//|                                                     J.S Oliveira |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "J.S Oliveira"
#property link      "https://www.mql5.com"
#property version   "1.00"

sinput string s1;//------------Médias Moveis----------
input int mm_rapida_periodo                = 12;            // Periodo Média Rápida
input int mm_lenta_periodo                 = 32;            // Periodo Média Lenta
input ENUM_TIMEFRAMES mm_tempo_grafico     = PERIOD_CURRENT;// Tempo Gráfico
input ENUM_MA_METHOD  mm_metodo            = MODE_EMA;      // Método 
input ENUM_APPLIED_PRICE  mm_preco         = PRICE_CLOSE;   // Preço Aplicado

sinput string s3; //---------------------------
input int num_lots                         = 100;           // Número de Lotes
input double TK                            = 60;            // Take Profit
input double SL                            = 30;            // Stop Loss

sinput string s4; //---------------------------
input string hora_limite_fecha_op          = "17:40";       // Horário Limite Fechar Posição 

//+------------------------------------------------------------------+
//|  Variáveis para os indicadores                                   |
//+------------------------------------------------------------------+
//--- Médias Móveis
// RÁPIDA - menor período
int mm_rapida_Handle;      // Handle controlador da média móvel rápida
double mm_rapida_Buffer[]; // Buffer para armazenamento dos dados das médias

// LENTA - maior período
int mm_lenta_Handle;      // Handle controlador da média móvel lenta
double mm_lenta_Buffer[]; // Buffer para armazenamento dos dados das médias

//+------------------------------------------------------------------+
//| Variáveis para as funçoes                                        |
//+------------------------------------------------------------------+

int magic_number = 123456;   // Nº mágico do robô

MqlRates velas[];            // Variável para armazenar velas
MqlTick tick;                // variável para armazenar ticks 


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
    mm_rapida_Handle = iMA(_Symbol,mm_tempo_grafico,mm_rapida_periodo,0,mm_metodo,mm_preco);
    mm_lenta_Handle  = iMA(_Symbol,mm_tempo_grafico,mm_lenta_periodo,0,mm_metodo,mm_preco);
   
      if(mm_rapida_Handle<0 || mm_lenta_Handle<0 )
     {
      Alert("Erro ao tentar criar Handles para o indicador - erro: ",GetLastError(),"!");
      return(-1);
     }
     
      CopyRates(_Symbol,_Period,0,4,velas);
      ArraySetAsSeries(velas,true);
   
   // Para adicionar no gráfico o indicador:
   ChartIndicatorAdd(0,0,mm_rapida_Handle); 
   ChartIndicatorAdd(0,0,mm_lenta_Handle);

   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
    IndicatorRelease(mm_rapida_Handle);
    IndicatorRelease(mm_lenta_Handle);
  
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
      CopyBuffer(mm_rapida_Handle,0,0,4,mm_rapida_Buffer);
      CopyBuffer(mm_lenta_Handle,0,0,4,mm_lenta_Buffer);
      
    //--- Alimentar Buffers das Velas com dados:
    CopyRates(_Symbol,_Period,0,4,velas);
    ArraySetAsSeries(velas,true);
   
    // Ordenar o vetor de dados:
    ArraySetAsSeries(mm_rapida_Buffer,true);
    ArraySetAsSeries(mm_lenta_Buffer,true);
    
    // Alimentar com dados variável de tick
    SymbolInfoTick(_Symbol,tick);
    
    // LOGICA PARA ATIVAR COMPRA 
    bool compra_mm_cros = mm_rapida_Buffer[0] > mm_lenta_Buffer[0] &&
                          mm_rapida_Buffer[2] < mm_lenta_Buffer[2] ;
    // LÓGICA PARA ATIVAR VENDA
    bool venda_mm_cros = mm_lenta_Buffer[0] > mm_rapida_Buffer[0] &&
                         mm_lenta_Buffer[2] < mm_rapida_Buffer[2];
                         
    bool Comprar = false; // Pode comprar?
    bool Vender  = false; // Pode vender?
    
    
       Comprar = compra_mm_cros;
       Vender  = venda_mm_cros;
    
    //retorna true se tivermos uma nova vela
    bool temosNovaVela  =  TemosNovaVela();
    
    //Toda vez que existir uma nova vela entrar nesse 'if'
    if(temosNovaVela)
      {
       //condição compra:
       if(Comprar && PositionSelect(_Symbol)==false)
         {
          desenhaLinhaVertical("Compra",vela[1].time,clrBlue);
          CompraAMercado();
         }
       //condição de venda:
       if(Vender && PositionSelect(_Symbol)==false)
         {
          desenhaLinhaVertical("Venda",velas[1].tie,clrRed);
          VendaAMercado();
         }
      }
      
      
      if(TimeToString(TimeCurrent(),TIME_MINUTES)  == hora_limite_fecha_op && PositionSelect(_Symbol) == true)
        {
        
        Print("-----> Fim do Tempo Operacional:Encerrar Posições Abertas!");
        if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY )
          {
           FecharCompra();
          }
          else if(PositionGetInteger(POSITION_TYPE)   == POSITION_TYPE_SELL)
                 {
                  FecharVenda();
                 }
         
        }
  }
//+------------------------------------------------------------------+
