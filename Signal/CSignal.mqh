class CSignal
{
private:
   int m_rsiHandle;
   int m_emaHandle;
   int m_adxHandle;
   int m_atrHandle;

public:

   bool Initialize();

   bool BuySignal();

   bool SellSignal();

   double GetScore();
};
