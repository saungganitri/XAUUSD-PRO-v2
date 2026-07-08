//+------------------------------------------------------------------+
//| CRiskManager.mqh                                                 |
//| XAUUSD PRO v2.0                                                  |
//+------------------------------------------------------------------+
#ifndef __CRISKMANAGER_MQH__
#define __CRISKMANAGER_MQH__

class CRiskManager
{
private:

   double m_riskPercent;
   double m_maxDailyDD;
   double m_maxSpread;

   double m_dayStartBalance;
   int    m_currentDay;

public:

   // Constructor
   CRiskManager()
   {
      m_riskPercent    = 0.5;
      m_maxDailyDD     = 3.0;
      m_maxSpread      = 300;
      m_dayStartBalance=0;
      m_currentDay=0;
   }

   //=====================================================
   // Initialize
   //=====================================================

   void Initialize(
      double riskPercent,
      double maxDailyDD,
      double maxSpread)
   {
      m_riskPercent = riskPercent;
      m_maxDailyDD  = maxDailyDD;
      m_maxSpread   = maxSpread;

      MqlDateTime tm;
      TimeToStruct(TimeCurrent(),tm);

      m_currentDay=tm.day;

      m_dayStartBalance=
         AccountInfoDouble(
            ACCOUNT_BALANCE);
   }

   //=====================================================
   // Update Day
   //=====================================================

   void UpdateDay()
   {
      MqlDateTime tm;
      TimeToStruct(TimeCurrent(),tm);

      if(tm.day!=m_currentDay)
      {
         m_currentDay=tm.day;

         m_dayStartBalance=
            AccountInfoDouble(
               ACCOUNT_BALANCE);
      }
   }

   //=====================================================
   // Daily DD Check
   //=====================================================

   bool DailyDDAllowed()
   {
      double equity=
         AccountInfoDouble(
            ACCOUNT_EQUITY);

      double dd=
      ((m_dayStartBalance-equity)
      /m_dayStartBalance)*100.0;

      if(dd>=m_maxDailyDD)
      {
         Print(
         "[RISK] Daily DD Limit Hit");

         return false;
      }

      return true;
   }

   //=====================================================
   // Spread Filter
   //=====================================================

   bool SpreadAllowed()
   {
      double spread=
      (
      SymbolInfoDouble(
         _Symbol,SYMBOL_ASK)
      -
      SymbolInfoDouble(
         _Symbol,SYMBOL_BID)
      )/_Point;

      if(spread>m_maxSpread)
      {
         Print(
         "[RISK] Spread Too High");

         return false;
      }

      return true;
   }

   //=====================================================
   // Calculate Lot
   //=====================================================

   double CalculateLot(
      string symbol,
      double stopLossDistance)
   {
      double balance=
      AccountInfoDouble(
         ACCOUNT_BALANCE);

      double riskMoney=
         balance*
         (m_riskPercent/100.0);

      double tickValue=
      SymbolInfoDouble(
         symbol,
         SYMBOL_TRADE_TICK_VALUE);

      double tickSize=
      SymbolInfoDouble(
         symbol,
         SYMBOL_TRADE_TICK_SIZE);

      if(tickValue<=0 ||
         tickSize<=0)
         return 0;

      double valuePerPoint=
         tickValue/tickSize;

      double lot=
      riskMoney/
      (
      stopLossDistance*
      valuePerPoint
      );

      double minLot=
      SymbolInfoDouble(
         symbol,
         SYMBOL_VOLUME_MIN);

      double maxLot=
      SymbolInfoDouble(
         symbol,
         SYMBOL_VOLUME_MAX);

      double stepLot=
      SymbolInfoDouble(
         symbol,
         SYMBOL_VOLUME_STEP);

      lot=MathMax(minLot,lot);
      lot=MathMin(maxLot,lot);

      lot=
      MathFloor(
      lot/stepLot)
      *stepLot;

      return NormalizeDouble(
         lot,2);
   }

   //=====================================================
   // Margin Check
   //=====================================================

   bool MarginAllowed(
      ENUM_ORDER_TYPE type,
      string symbol,
      double volume)
   {
      double price=
      (
      type==
      ORDER_TYPE_BUY
      )
      ?
      SymbolInfoDouble(
         symbol,
         SYMBOL_ASK)
      :
      SymbolInfoDouble(
         symbol,
         SYMBOL_BID);

      double margin=0;

      if(!OrderCalcMargin(
         type,
         symbol,
         volume,
         price,
         margin))
      {
         return false;
      }

      double freeMargin=
      AccountInfoDouble(
         ACCOUNT_MARGIN_FREE);

      return
      (
      freeMargin>
      margin
      );
   }
};

#endif
