class CRiskManager
{
private:
   double m_riskPercent;
   double m_maxDailyDD;

public:

   void Initialize();

   double CalculateLot(
      double stopLossDistance);

   bool CheckDailyDD();

   bool CheckSpread();

   bool CheckMargin(
      ENUM_ORDER_TYPE type,
      double volume);

};
