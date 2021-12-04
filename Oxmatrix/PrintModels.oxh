class PrintModels
  {
  PrintModels();
  ~PrintModels();
  AddModels(...);
  SetModelNames(const asModelNames);

  //HBN function splits
  GetParNamesPCGIVE();
  GetResultsPCGIVE();
  PrintSimpleTablePCGIVE();
  PrintLatexCodePCGIVE();

  GetParNamesARCH();
  GetResultsARCH();
  PrintSimpleTableARCH();
  PrintLatexCodeARCH();

  GetParNamesARFIMA();
  GetResultsARFIMA();
  PrintSimpleTableARFIMA();
  PrintLatexCodeARFIMA();

  GetParNamesGARCH();
  GetResultsGARCH();
  PrintSimpleTableGARCH();
  PrintLatexCodeGARCH();  

  PrintTable();
  SetPrintFormat( se , scientific , par , unc );

  decl m_oModels;
  decl m_iM;
  decl m_asModelNames;
  decl m_asParNames;
  decl m_mEst;
  decl m_mStdErr;
  decl m_mTRatios;
  decl m_mStdErrHC;
  decl m_mTRatiosHC;
  decl m_mStdErrHAC;
  decl m_mTRatiosHAC;
  decl m_mT;
  decl m_mSigmaHat;
  decl m_mLogLik;
  decl m_mIC;
  decl m_mARTest;
  decl m_mHeteroTest;
  decl m_mNormTest;
  decl m_asSampleStart;
  decl m_asSampleEnd;

  //HBN extensions
  decl i_SE;
  decl i_scientific;
  decl i_par;
  decl i_unc;
  decl mLaglength;
  decl m_sum;
  decl m_myclass;
  }