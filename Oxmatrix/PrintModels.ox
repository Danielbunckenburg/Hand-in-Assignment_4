#import <packages/PcGive/pcgive_ects>
#import <packages/arfima/arfima>
#include "PrintModels.oxh"

// Constructor
PrintModels::PrintModels()
  {
  m_oModels    = {};
  i_SE         = TRUE;
  i_scientific = "f";
  i_par        = 3;
  i_unc        = 3;
  }


// De-constructor
PrintModels::~PrintModels()
  {
  delete m_oModels;
  }


//set precision and format for output
PrintModels::SetPrintFormat( se , scientific , par , unc )
  {
  i_SE         = se;
  i_par        = par;
  i_unc        = unc;

  if (scientific == TRUE)
    i_scientific = "g";
  else
    i_scientific = "f";
  }


// Adds model classes. Input must be PcGive, PcGiveGarch, or Arfima classes
//first model is decisive for the remaining inputs
PrintModels::AddModels(...)
  {
  decl i;
  decl arglist = va_arglist();

  // Add all models to the class object m_oModels
  for (i = 0; i < sizeof(arglist); i++)
    {
    if (i == 0)
      {
      m_myclass = classname(arglist[i]);

      if (m_myclass == "PcGive" || m_myclass == "PcGiveGarch" || m_myclass == "Garch" || m_myclass == "Arfima")
        {
        print("\n\nCollecting ", m_myclass, " class models.");
        }
      else
        {
        print("\n\n", m_myclass, " is not a supported class!");
        }
      }

    if (isclass(arglist[i], m_myclass) == TRUE)
      {
      m_oModels ~= arglist[i];
      }
    else
      {
      println("\nError in function AddModels(). Input ", i + 1, " is ", classname(arglist[i]), " and not a valid ", m_myclass, " class!");
      }	  
    }

  // Count the total number of models added
  m_iM = sizeof(m_oModels);
  }


// Set the model names for all models in m_oModels
PrintModels::SetModelNames(const asModelNames)
  {
  if (isarray(asModelNames))
    m_asModelNames = asModelNames;
  else
    oxrunerror("Input error in function SetModelNames(). Input variable must be an array with strings with model names");
  }


//////////////////////////////////////////////////////////////
// PCGIVE ////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////


// Gets all parameter names, joins them, and sort them alphabetically
PrintModels::GetParNamesPCGIVE()
  {
  // Declare and initialize variables
  decl i, j, oModel, asParNames, asParNamesTemp;
  asParNames = {};

  // Loop over all models in m_oModels
  for (i = 0; i < sizeof(m_oModels); i++)
    {
    // Get the PcGive models from m_oModels
    oModel = m_oModels[i];

    // Get the variable names for this model object and add them to asParNames
    asParNamesTemp = oModel.GetParNames();

    for (j = 0; j < sizeof(asParNamesTemp); j++)
      {
      if (strfind(asParNames, asParNamesTemp[j]) == -1)
        asParNames ~= asParNamesTemp[j];
      }
    }

  // Sort parameter names
  asParNames = sortc(asParNames);

  // Set class variable with parameter names
  m_asParNames = asParNames;
  }


// Gets the estimation results from the class object m_oModels
PrintModels::GetResultsPCGIVE()
  {
  // Declare and initialize variables
  decl i, j, mEst, mStdErr, mTRatios, oModel, mEstTemp, mStdErrTemp, mTRatiosTemp, asParNamesTemp;
  decl mSigmaHat, mLogLik, mT, asSampleStart, asSampleEnd, mIC, mARTest, mHeteroTest, mNormTest;
  mEst = mStdErr = mTRatios = nans(sizeof(m_asParNames), m_iM);
  mSigmaHat = mLogLik = mT = nans(1, m_iM);
  mARTest = mHeteroTest = mNormTest = nans(2, m_iM);
  mIC = nans(3, m_iM);
  asSampleStart = asSampleEnd = new array[m_iM];

  for (i = 0; i < sizeof(m_oModels); i++)
    {
    // Get the PcGive Model from m_oModels
    oModel = m_oModels[i];
    oModel.SetPrint(0);

    // Get the estimates, standard errors, and t-ratios
    asParNamesTemp = oModel.GetParNames();

    mEstTemp       = oModel.GetPar();
    //mStdErrTemp    = sqrt(diagonal(oModel.GetCovarRobust()))';//oModel.GetStdErr();

    //use non-robust
    if (oModel.GetCovarRobust() == < > )
      {
      mStdErrTemp    = sqrt(diagonal(oModel.GetCovar()))';//oModel.GetStdErr();
      }
    else
      {
      mStdErrTemp    = sqrt(diagonal(oModel.GetCovarRobust()))';//oModel.GetStdErr();
      }

    mTRatiosTemp   = mEstTemp ./ mStdErrTemp;

    //mEstTemp = oModel.GetPar();
    //mStdErrTemp = oModel.GetStdErr();
    //mTRatiosTemp = mEstTemp ./ mStdErrTemp;

    // Add the estimates, standard errors, and t-ratios
    mEst[strfind(m_asParNames, asParNamesTemp)][i] = mEstTemp;
    mStdErr[strfind(m_asParNames, asParNamesTemp)][i] = mStdErrTemp;
    mTRatios[strfind(m_asParNames, asParNamesTemp)][i] = mTRatiosTemp;

    // Get the estimated residual variance
    mSigmaHat[0][i] = sqrt(oModel.GetResVar());

    // Get the log-likelihood
    mLogLik[0][i] = oModel.GetLogLik();

    // Get the sample information
    mT[0][i] = oModel.GetcT();
    asSampleStart[i] = sprint(oModel.ObsYear(oModel.GetSelStart()), "(", oModel.ObsPeriod(oModel.GetSelStart()), ")");
    asSampleEnd[i]   = sprint(oModel.ObsYear(oModel.GetSelEnd()), "(", oModel.ObsPeriod(oModel.GetSelEnd()), ")");

    // Get the information criteria
    mIC[0][i] = (2 * sizer(mEstTemp) - 2 * mLogLik[0][i]) / mT[0][i];                   // AIC
    mIC[1][i] = (-2 * mLogLik[0][i] + 2 * sizer(mEstTemp) * log(log(mT[0][i]))) / mT[0][i]; // HQ
    mIC[2][i] = (log(mT[0][i]) * sizer(mEstTemp) - 2 * mLogLik[0][i]) / mT[0][i];       // SQ/BIC

    // Get the misspecification tests
    oModel.SetTestDefaults();
    mARTest[][i] = oModel.DoArTest(oModel.GetY(), oModel.GetResiduals(), oModel.GetW(), 1, 5, 0)[][0];
    mHeteroTest[][i] = oModel.HeteroTest(0, 0)[][0];
    mNormTest[][i] = oModel.NormalityTest();
    }

  // Set class variables
  m_mEst          = mEst;
  m_mStdErr       = mStdErr;
  m_mTRatios      = mTRatios;
  m_mSigmaHat     = mSigmaHat;
  m_mLogLik       = mLogLik;
  m_mT            = mT;
  m_asSampleStart = asSampleStart;
  m_asSampleEnd   = asSampleEnd;
  m_mIC           = mIC;
  m_mARTest       = mARTest;
  m_mHeteroTest   = mHeteroTest;
  m_mNormTest     = mNormTest;
  }


// Prints a latex code with estimation results for all models in one table
PrintModels::PrintLatexCodePCGIVE()
  {
  decl uncertainty;

  //HBN
  if (i_SE == TRUE)
    uncertainty = m_mStdErr;
  else
    uncertainty = m_mTRatios;

  decl i, j, k, asParNames;
  asParNames = m_asParNames;

  for (i = 0; i < sizeof(asParNames); i++)
    {
    asParNames[i] = replace(asParNames[i], "_", "\_");
    }

  println("\n\n");
  println("Printing latex results for all models in a single table...");
  println("\n");

  // Print header
  println("\\begin{table}[tbph]");
  println("\\begin{center}");

  if (m_iM > 3) println("\\footnotesize");

  print("\\begin{tabular}{lr");

  for (i = 1; i < m_iM; i++)
    {
    print("r");
    }
  println("}");
  println("\hline");

  // Print model names
  for (i = 0; i < m_iM; i++)
    {
    print("& ", string(m_asModelNames[i]), " ");
    }
  println("\\\\");
  println("\hline");

  // Print estimates and standard errors
  for (i = 0; i < sizer(m_mEst); i++)
    {
    print(asParNames[i]);

    for (j = 0; j < m_iM; j++)
      {
      if (m_mEst[i][j] == .NaN)
        print(" & .");
      else
        //print(" & $\underset{(", strtrim(string(sprint("%8.3f", uncertainty[i][j]))), ")}{", strtrim(string(sprint("%8.3f", m_mEst[i][j]))), "}$");
        //HBN
        print(" & $\underset{(", strtrim(string(sprint("%" + sprint("8.", i_unc, i_scientific) , uncertainty[i][j]))), ")}{", strtrim(string(sprint( "%" + sprint("8.", i_par, i_scientific), m_mEst[i][j]))), "}$");
      }

    println(" \\\\");
    }
  println("\hline");

  // Print residual standard deviation and log-likelihood
  print("$\hat{\sigma}$");

  for (i = 0; i < m_iM; i++)
    {
    print(" & ", strtrim(string(sprint( "%" + sprint("8.", i_par, i_scientific) , m_mSigmaHat[0][i]))));
    }
  println(" \\\\");
  print("Log-lik.");

  for (i = 0; i < m_iM; i++)
    {
    print(" & ", strtrim(string(sprint("%8.3f", m_mLogLik[0][i]))));
    }
  println(" \\\\");
  println("\hline");

  // Print information criteria
  print("AIC");

  for (i = 0; i < m_iM; i++)
    {
    print(" & ", strtrim(string(sprint("%8.3f", m_mIC[0][i]))));
    }
  println(" \\\\");
  print("HQ");

  for (i = 0; i < m_iM; i++)
    {
    print(" & ", strtrim(string(sprint("%8.3f", m_mIC[1][i]))));
    }
  println(" \\\\");
  print("SC/BIC");

  for (i = 0; i < m_iM; i++)
    {
    print(" & ", strtrim(string(sprint("%8.3f", m_mIC[2][i]))));
    }
  println(" \\\\");
  println("\hline");

  // Print information criteria
  print("No autocorr. 1-5");

  for (i = 0; i < m_iM; i++)
    {
    print(" & ", sprint("[", strtrim(string(sprint("%8.2f", m_mARTest[1][i]))), "]"));
    }
  println(" \\\\");
  print("No hetero.");

  for (i = 0; i < m_iM; i++)
    {
    print(" & ", sprint("[", strtrim(string(sprint("%8.2f", m_mHeteroTest[1][i]))), "]"));
    }
  println(" \\\\");
  print("Normality");

  for (i = 0; i < m_iM; i++)
    {
    print(" & ", sprint("[", strtrim(string(sprint("%8.2f", m_mNormTest[1][i]))), "]"));
    }
  println(" \\\\");
  println("\hline");

  // Print estimation sample info
  print("T");

  for (i = 0; i < m_iM; i++)
    {
    print(" & ", m_mT[0][i]);
    }
  println(" \\\\");
  print("Sample start");

  for (i = 0; i < m_iM; i++)
    {
    print(" & ", string(m_asSampleStart[i]));
    }
  println(" \\\\");
  print("Sample end");

  for (i = 0; i < m_iM; i++)
    {
    print(" & ", string(m_asSampleEnd[i]));
    }
  println(" \\\\");


  // Print footer
  println("\hline");
  println("\end{tabular}");
  println("\end{center}");
  println("\\vspace{1em}");

  if (i_SE == TRUE) println("\caption{The table shows estimates of the model in equation (X) with various restrictions imposed. Standard errors in ($\cdot$) and p-values in [$\cdot$] for misspecification tests.}");
  else           println("\caption{The table shows estimates of the model in equation (X) with various restrictions imposed. T-ratios in ($\cdot$) and p-values in [$\cdot$] for misspecification tests.}");
  println("\end{table}");
  }

  
// Prints a latex code with estimation results for all models in one table
PrintModels::PrintSimpleTablePCGIVE()
  {
  decl uncertainty;

  //HBN
  if (i_SE == TRUE)
    uncertainty = m_mStdErr;
  else
    uncertainty = m_mTRatios;

  decl i, j, k, sBar;
  println("\n\n");
  println("Printing results for all models in a single table...");
  println("\n");

  // Create a string with a horizontal line
  sBar = "--------------------";

  for (i = 0; i < m_iM; i++)
    {
    sBar ~= "------------";
    }

  // Print model names
  println(sBar);
  print("                    ");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", string(m_asModelNames[i]));
    }
  println("");
  println(sBar);

  // Print estimates and standard errors
  for (i = 0; i < sizer(m_mEst); i++)
    {
    print("%-20s", m_asParNames[i]);

    for (j = 0; j < m_iM; j++)
      {
      if (m_mEst[i][j] == .NaN)
        print("%12s", ".");
      else
        print("%12s", strtrim(string(sprint("%8.3f", m_mEst[i][j]))));
      }
    println("");
    print("%-20s", "");

    for (j = 0; j < m_iM; j++)
      {
      if (m_mEst[i][j] == .NaN)
        print("%12s", ".");
      else
        print("%12s", sprint("(", strtrim(string(sprint("%8.3f", uncertainty[i][j]))), ")"));
      }
    println("\n\n");
    }
  println(sBar);

  // Print residual standard deviation and log-likelihood
  print("%-20s", "sigma");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", strtrim(string(sprint("%8.3f", m_mSigmaHat[0][i]))));
    }
  println("");
  print("%-20s", "Log-lik.");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", strtrim(string(sprint("%8.3f", m_mLogLik[0][i]))));
    }
  println("");
  println(sBar);

  // Print information criteria
  print("%-20s", "AIC");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", strtrim(string(sprint("%8.3f", m_mIC[0][i]))));
    }
  println("");
  print("%-20s", "HQ");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", strtrim(string(sprint("%8.3f", m_mIC[1][i]))));
    }
  println("");
  print("%-20s", "SC/BIC");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", strtrim(string(sprint("%8.3f", m_mIC[2][i]))));
    }
  println("");
  println(sBar);

  // Print information criteria
  print("%-20s", "No autocorr. 1-5");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", sprint("[", strtrim(string(sprint("%8.2f", m_mARTest[1][i]))), "]"));
    }
  println("");
  print("%-20s", "No hetero.");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", sprint("[", strtrim(string(sprint("%8.2f", m_mHeteroTest[1][i]))), "]"));
    }
  println("");
  print("%-20s", "Normality");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", sprint("[", strtrim(string(sprint("%8.2f", m_mNormTest[1][i]))), "]"));
    }
  println("");
  println(sBar);

  // Print estimation sample info
  print("%-20s", "T");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", sprint(m_mT[0][i]));
    }
  println("");
  print("%-20s", "Sample start");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", string(m_asSampleStart[i]));
    }
  println("");
  print("%-20s", "Sample end");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", string(m_asSampleEnd[i]));
    }
  println("");
  println(sBar);

  if (i_SE == TRUE) println("Table 1. The table shows estimates of the model in equation (X) with various restrictions imposed. Standard errors in (.) and p-values in [.] for misspecification tests.");
  else           println("Table 1. The table shows estimates of the model in equation (X) with various restrictions imposed. T-ratios in (.) and p-values in [.] for misspecification tests.");

  }


//////////////////////////////////////////////////////////////
// ARCH //////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////


// Gets all parameter names, joins them, and sort them alphabetically
PrintModels::GetParNamesARCH()
  {
  // Declare and initialize variables
  decl i, j, oModel, asParNames, asParNamesTemp;
  asParNames = {};

  // Loop over all models in m_oModels
  for (i = 0; i < sizeof(m_oModels); i++)
    {
    // Get the PcGive models from m_oModels
    oModel = m_oModels[i];

    // Get the variable names for this model object and add them to asParNames
    asParNamesTemp = oModel.GetParNames();

    decl temp = oModel.GetParTypes();

    for (j = 0; j < sizeof(asParNamesTemp); j++)
      {
      if (temp[j] != " ") asParNamesTemp[j] = sprint(asParNamesTemp[j] + " (", temp[j], ")");
      }

    for (j = 0; j < sizeof(asParNamesTemp); j++)
      {
      if (strfind(asParNames, asParNamesTemp[j]) == -1)
        asParNames ~= asParNamesTemp[j];
      }
    }

  // Sort parameter names
  //asParNames = sortc(asParNames);

  decl Y = {};
  decl X = {};
  decl H = {};
  decl A = {};
  for (decl i = 0; i < rows(asParNames); ++i)
    {
    if ( (asParNames[i])[columns(asParNames[i]) - 3:] .== "(Y)") Y = Y~asParNames[i];
    else if ( (asParNames[i])[columns(asParNames[i]) - 3:] .== "(X)") X = X~asParNames[i];
    else if ( (asParNames[i])[columns(asParNames[i]) - 3:] .== "(H)") H = H~asParNames[i];
    else                                                          A = A~asParNames[i];
    }
  asParNames = sortc(Y) | sortc(X) | sortc(H) | sortc(A);

  // Set class variable with parameter names
  m_asParNames = asParNames;
  }

  
// Gets the estimation results from the class object m_oModels
PrintModels::GetResultsARCH()
  {
  // Declare and initialize variables
  decl i, j, mEst, mStdErr, mTRatios, oModel, mEstTemp, mStdErrTemp, mTRatiosTemp, asParNamesTemp;
  decl mLogLik, mT, asSampleStart, asSampleEnd, mIC, mARTest, mHeteroTest, mNormTest;
  mEst = mStdErr = mTRatios = nans(sizeof(m_asParNames), m_iM);
  decl dfloss = 0;
  mLogLik = mT = nans(1, m_iM);
  mARTest = mHeteroTest = mNormTest = nans(2, m_iM);
  mIC = nans(3, m_iM);
  asSampleStart = asSampleEnd = new array[m_iM];

  for (i = 0; i < sizeof(m_oModels); i++)
    {
    dfloss = 0;
    // Get the PcGive Model from m_oModels
    oModel = m_oModels[i];
    oModel.SetPrint(0);

    // Get the estimates, standard errors, and t-ratios
    asParNamesTemp = oModel.GetParNames();

    decl temp2 = oModel.GetParTypes();

    for (j = 0; j < sizeof(asParNamesTemp); j++)
      {
      if (temp2[j] != " ") asParNamesTemp[j] = sprint(asParNamesTemp[j] + " (", temp2[j], ")");

      if (temp2[j] == "Y") dfloss += 1;
      }

    mEstTemp       = oModel.GetPar();
    //mStdErrTemp    = sqrt(diagonal(oModel.GetCovarRobust()))';//oModel.GetStdErr();

    //use non-robust
    if (oModel.GetCovarRobust() == < > )
      {
      mStdErrTemp    = sqrt(diagonal(oModel.GetCovar()))';//oModel.GetStdErr();
      }
    else
      {
      mStdErrTemp    = sqrt(diagonal(oModel.GetCovarRobust()))';//oModel.GetStdErr();
      }

    mTRatiosTemp   = mEstTemp ./ mStdErrTemp;

    // Add the estimates, standard errors, and t-ratios
    mEst[strfind(m_asParNames, asParNamesTemp)][i] = mEstTemp;
    mStdErr[strfind(m_asParNames, asParNamesTemp)][i] = mStdErrTemp;
    mTRatios[strfind(m_asParNames, asParNamesTemp)][i] = mTRatiosTemp;
    // Get the log-likelihood
    mLogLik[0][i] = oModel.GetLogLik();

    // Get the sample information
    mT[0][i]         = oModel.GetcT();
    decl temp        = oModel.GetSelSample();
    asSampleStart[i] = temp[0:strfind(temp, " - ") - 1];
    asSampleEnd[i]   = temp[strfind(temp, " - ") + 3:];

    // Get the information criteria
    mIC[0][i] = (2 * sizer(mEstTemp) - 2 * mLogLik[0][i]) / mT[0][i];                   // AIC
    mIC[1][i] = (-2 * mLogLik[0][i] + 2 * sizer(mEstTemp) * log(log(mT[0][i]))) / mT[0][i]; // HQ
    mIC[2][i] = (log(mT[0][i]) * sizer(mEstTemp) - 2 * mLogLik[0][i]) / mT[0][i];       // SQ/BIC

    // Get the misspecification tests
    mLaglength  = max(int(sqrt(rows(oModel.GetResiduals()))), 3 * oModel.GetFrequency());

    mARTest[][i]     = PortmanteauTest(oModel.GetResiduals()./sqrt(oModel.GetCondVar()), mLaglength , dfloss, TRUE);
    mHeteroTest[][i] = ArchTest(oModel.GetResiduals()./sqrt(oModel.GetCondVar()), 1, 1, oModel.GetFreeParCount() - 1, TRUE);
    mNormTest[][i]   = NormalityTest(oModel.GetResiduals()./sqrt(oModel.GetCondVar()), TRUE);
    }

  // Set class variables
  m_mEst          = mEst;
  m_mStdErr       = mStdErr;
  m_mTRatios      = mTRatios;
  m_mLogLik       = mLogLik;
  m_mT            = mT;
  m_asSampleStart = asSampleStart;
  m_asSampleEnd   = asSampleEnd;
  m_mIC           = mIC;
  m_mARTest       = mARTest;
  m_mHeteroTest   = mHeteroTest;
  m_mNormTest     = mNormTest;

  m_sum = zeros(1, m_iM);
print(m_asParNames);
  for (decl i = 0; i < rows(m_asParNames); ++i)
    {
    if ((m_asParNames[i]+"    ")[0:5] == "alpha_" && (m_asParNames[i]+"     ")[0:6] != "alpha_0") m_sum += replace(mEst[i][], .NaN, 0);

    if ((m_asParNames[i]+"    ")[0:4] == "beta_" )                                                m_sum += replace(mEst[i][], .NaN, 0);

    //print("\nher...",m_sum);
    }
  }


// Prints a latex code with estimation results for all models in one table
PrintModels::PrintLatexCodeARCH()
  {
  decl uncertainty;

  //HBN
  if (i_SE == TRUE)
    uncertainty = m_mStdErr;
  else
    uncertainty = m_mTRatios;

  decl i, j, k, asParNames;
  asParNames = m_asParNames;

  for (i = 0; i < sizeof(asParNames); i++)
    {
    asParNames[i] = replace(asParNames[i], "_", "\_");
    }

  println("\n\n");
  println("Printing latex results for all models in a single table...");
  println("\n");

  // Print header
  println("\\begin{table}[tbph]");
  println("\\begin{center}");

  if (m_iM > 3) println("\\footnotesize");

  print("\\begin{tabular}{lr");

  for (i = 1; i < m_iM; i++)
    {
    print("r");
    }
  println("}");
  println("\hline");

  // Print model names
  for (i = 0; i < m_iM; i++)
    {
    print("& ", string(m_asModelNames[i]), " ");
    }
  println("\\\\");
  println("\hline");

  // Print estimates and standard errors
  for (i = 0; i < sizer(m_mEst); i++)
    {
    print(asParNames[i]);

    for (j = 0; j < m_iM; j++)
      {
      if (m_mEst[i][j] == .NaN)
        print(" & .");
      else
        //print(" & $\underset{(", strtrim(string(sprint("%8.3f", uncertainty[i][j]))), ")}{", strtrim(string(sprint("%8.3f", m_mEst[i][j]))), "}$");
        //HBN
        print(" & $\underset{(", strtrim(string(sprint("%#" + sprint("8.", i_unc, i_scientific) , uncertainty[i][j]))), ")}{", strtrim(string(sprint( "%#" + sprint("8.", i_par, i_scientific), m_mEst[i][j]))), "}$");
      }

    println(" \\\\");
    }
  println("\hline");

  // Print sum
  print("alpha(1)+beta(1)");

  for (i = 0; i < m_iM; i++)
    {
    print(" & ", strtrim(string(sprint("%8.3f", m_sum[0][i]))));
    }
  println(" \\\\");
  println("\hline");

  // Print log-likelihood
  print("Log-lik.");

  for (i = 0; i < m_iM; i++)
    {
    print(" & ", strtrim(string(sprint("%8.3f", m_mLogLik[0][i]))));
    }
  println(" \\\\");
  println("\hline");

  // Print information criteria
  print("AIC");

  for (i = 0; i < m_iM; i++)
    {
    print(" & ", strtrim(string(sprint("%8.3f", m_mIC[0][i]))));
    }
  println(" \\\\");
  print("HQ");

  for (i = 0; i < m_iM; i++)
    {
    print(" & ", strtrim(string(sprint("%8.3f", m_mIC[1][i]))));
    }
  println(" \\\\");
  print("SC/BIC");

  for (i = 0; i < m_iM; i++)
    {
    print(" & ", strtrim(string(sprint("%8.3f", m_mIC[2][i]))));
    }
  println(" \\\\");
  println("\hline");

  // Print information criteria
  print("Portmanteau, 1-", int(mLaglength));

  for (i = 0; i < m_iM; i++)
    {
    print(" & ", sprint("[", strtrim(string(sprint("%8.2f", m_mARTest[1][i]))), "]"));
    }
  println(" \\\\");
  print("No ARCH(1)");

  for (i = 0; i < m_iM; i++)
    {
    print(" & ", sprint("[", strtrim(string(sprint("%8.2f", m_mHeteroTest[1][i]))), "]"));
    }
  println(" \\\\");
  print("Normality");

  for (i = 0; i < m_iM; i++)
    {
    print(" & ", sprint("[", strtrim(string(sprint("%8.2f", m_mNormTest[1][i]))), "]"));
    }
  println(" \\\\");
  println("\hline");

  // Print estimation sample info
  print("T");

  for (i = 0; i < m_iM; i++)
    {
    print(" & ", m_mT[0][i]);
    }
  println(" \\\\");
  print("Sample start");

  for (i = 0; i < m_iM; i++)
    {
    print(" & ", string(m_asSampleStart[i]));
    }
  println(" \\\\");
  print("Sample end");

  for (i = 0; i < m_iM; i++)
    {
    print(" & ", string(m_asSampleEnd[i]));
    }
  println(" \\\\");


  // Print footer
  println("\hline");
  println("\end{tabular}");
  println("\end{center}");
  println("\\vspace{1em}");

  if (i_SE == TRUE) println("\caption{The table shows estimates of the model in equation (X) with various restrictions imposed. Standard errors in ($\cdot$) and p-values in [$\cdot$] for misspecification tests.}");
  else           println("\caption{The table shows estimates of the model in equation (X) with various restrictions imposed. T-ratios in ($\cdot$) and p-values in [$\cdot$] for misspecification tests.}");
  println("\end{table}");

  }


// Prints a latex code with estimation results for all models in one table
PrintModels::PrintSimpleTableARCH()
  {
  decl uncertainty;

  //HBN
  if (i_SE == TRUE)
    uncertainty = m_mStdErr;
  else
    uncertainty = m_mTRatios;

  decl i, j, k, sBar;
  println("\n\n");
  println("Printing results for all models in a single table...");
  println("\n");

  // Create a string with a horizontal line
  sBar = "--------------------";

  for (i = 0; i < m_iM; i++)
    {
    sBar ~= "------------";
    }

  // Print model names
  println(sBar);
  print("                    ");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", string(m_asModelNames[i]));
    }
  println("");
  println(sBar);

  // Print estimates and standard errors
  for (i = 0; i < sizer(m_mEst); i++)
    {
    print("%-20s", m_asParNames[i]);

    for (j = 0; j < m_iM; j++)
      {
      if (m_mEst[i][j] == .NaN)
        print("%12s", ".");
      else
        print("%12s", strtrim(string(sprint("%8.3f", m_mEst[i][j]))));
      }
    println("");
    print("%-20s", "");

    for (j = 0; j < m_iM; j++)
      {
      if (m_mEst[i][j] == .NaN)
        print("%12s", ".");
      else
        print("%12s", sprint("(", strtrim(string(sprint("%8.3f", uncertainty[i][j]))), ")"));
      }
    println("\n\n");
    }
  println(sBar);


  // Print sum
  print("%-20s", "alpha(1)+beta(1)");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", strtrim(string(sprint("%8.3f", m_sum[0][i]))));
    }
  println("");
  println(sBar);


  // Print log-likelihood
  print("%-20s", "Log-lik.");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", strtrim(string(sprint("%8.3f", m_mLogLik[0][i]))));
    }
  println("");
  println(sBar);


  // Print information criteria
  print("%-20s", "AIC");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", strtrim(string(sprint("%8.3f", m_mIC[0][i]))));
    }
  println("");
  print("%-20s", "HQ");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", strtrim(string(sprint("%8.3f", m_mIC[1][i]))));
    }
  println("");
  print("%-20s", "SC/BIC");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", strtrim(string(sprint("%8.3f", m_mIC[2][i]))));
    }
  println("");
  println(sBar);

  // Print information criteria
  print("%-20s", sprint("Portmanteau, 1-", int(mLaglength)));

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", sprint("[", strtrim(string(sprint("%8.2f", m_mARTest[1][i]))), "]"));
    }
  println("");
  print("%-20s", "No ARCH(1)");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", sprint("[", strtrim(string(sprint("%8.2f", m_mHeteroTest[1][i]))), "]"));
    }
  println("");
  print("%-20s", "Normality");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", sprint("[", strtrim(string(sprint("%8.2f", m_mNormTest[1][i]))), "]"));
    }
  println("");
  println(sBar);

  // Print estimation sample info
  print("%-20s", "T");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", sprint(m_mT[0][i]));
    }
  println("");
  print("%-20s", "Sample start");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", string(m_asSampleStart[i]));
    }
  println("");
  print("%-20s", "Sample end");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", string(m_asSampleEnd[i]));
    }
  println("");
  println(sBar);

  if (i_SE == TRUE) println("Table 1. The table shows estimates of the model in equation (X) with various restrictions imposed. Standard errors in (.) and p-values in [.] for misspecification tests.");
  else           println("Table 1. The table shows estimates of the model in equation (X) with various restrictions imposed. T-ratios in (.) and p-values in [.] for misspecification tests.");

  }


//////////////////////////////////////////////////////////////
// ARFIMA ////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////


// Gets all parameter names from all models, joins them, and sort them alphabetically
PrintModels::GetParNamesARFIMA()
  {
  // Declare and initialize variables
  decl i, j, oModel, asParNames, asParNamesTemp;
  asParNames = {};

  // Loop over all models in m_oModels
  for (i = 0; i < sizeof(m_oModels); i++)
    {
    // Get the PcGive models from m_oModels
    oModel = m_oModels[i];

    // Get the variable names for this model object and add them to asParNames
    asParNamesTemp = oModel.GetParNames();

    for (j = 0; j < sizeof(asParNamesTemp); j++)
      {
      if (strfind(asParNames, asParNamesTemp[j]) == -1)
        asParNames ~= asParNamesTemp[j];
      }
    }

  // Sort parameter names
  asParNames = sortc(asParNames);

  // Set class variable with parameter names
  m_asParNames = asParNames;
  }


// Gets the estimation results from the class object m_oModels
PrintModels::GetResultsARFIMA()
  {
  // Declare and initialize variables
  decl i, j, mEst, mStdErr, mTRatios, oModel, mEstTemp, mStdErrTemp, mTRatiosTemp, asParNamesTemp;
  decl mSigmaHat, mLogLik, mT, asSampleStart, asSampleEnd, mIC, mARTest, mHeteroTest, mNormTest;
  mEst = mStdErr = mTRatios = nans(sizeof(m_asParNames), m_iM);
  mSigmaHat = mLogLik = mT = nans(1, m_iM);
  mARTest = mHeteroTest = mNormTest = nans(2, m_iM);
  mIC = nans(3, m_iM);
  asSampleStart = asSampleEnd = new array[m_iM];

  for (i = 0; i < sizeof(m_oModels); i++)
    {
    // Get the PcGive Model from m_oModels
    oModel = m_oModels[i];
    oModel.SetPrint(0);

    // Get the estimates, standard errors, and t-ratios
    asParNamesTemp = oModel.GetParNames();
    mEstTemp = oModel.GetPar();
    mStdErrTemp = oModel.GetStdErr();
    mTRatiosTemp = mEstTemp ./ mStdErrTemp;

    // Add the estimates, standard errors, and t-ratios
    mEst[strfind(m_asParNames, asParNamesTemp)][i] = mEstTemp;
    mStdErr[strfind(m_asParNames, asParNamesTemp)][i] = mStdErrTemp;
    mTRatios[strfind(m_asParNames, asParNamesTemp)][i] = mTRatiosTemp;

    // Get the estimated residual variance
    mSigmaHat[0][i] = sqrt(oModel.GetSigma2());

    // Get the log-likelihood
    mLogLik[0][i] = oModel.GetLogLik();

    // Get the sample information
    mT[0][i] = oModel.GetcT();
    asSampleStart[i] = sprint(oModel.ObsYear(oModel.GetSelStart()), "(", oModel.ObsPeriod(oModel.GetSelStart()), ")");
    asSampleEnd[i]   = sprint(oModel.ObsYear(oModel.GetSelEnd()), "(", oModel.ObsPeriod(oModel.GetSelEnd()), ")");

    // Get the information criteria
    mIC[0][i] = (2 * sizer(mEstTemp) - 2 * mLogLik[0][i]) / mT[0][i];                   // AIC
    mIC[1][i] = (-2 * mLogLik[0][i] + 2 * sizer(mEstTemp) * log(log(mT[0][i]))) / mT[0][i]; // HQ
    mIC[2][i] = (log(mT[0][i]) * sizer(mEstTemp) - 2 * mLogLik[0][i]) / mT[0][i];       // SQ/BIC

    // Get the misspecification tests
    decl cparma = rows(deleteifr(mEstTemp, mEstTemp .== 0)) - 1; //oModel.m_cARMA ? int(sumc(oModel.m_vIsFreePar[1 : oModel.m_cARMA])) : 0;
    mLaglength  = max(int(sqrt(rows(oModel.GetResiduals()))), 3 * oModel.GetFrequency());

    mARTest[][i]     = PortmanteauTest(oModel.GetResiduals(), mLaglength , cparma, TRUE);
    mHeteroTest[][i] = ArchTest(oModel.GetResiduals(), 1, 1, oModel.GetFreeParCount() - 1, TRUE);
    mNormTest[][i]   = NormalityTest(oModel.GetResiduals(), TRUE);
    }

  // Set class variables
  m_mEst          = mEst;
  m_mStdErr       = mStdErr;
  m_mTRatios      = mTRatios;
  m_mSigmaHat     = mSigmaHat;
  m_mLogLik       = mLogLik;
  m_mT            = mT;
  m_asSampleStart = asSampleStart;
  m_asSampleEnd   = asSampleEnd;
  m_mIC           = mIC;
  m_mARTest       = mARTest;
  m_mHeteroTest   = mHeteroTest;
  m_mNormTest     = mNormTest;
  }

  
// Prints a latex code with estimation results for all models in one table
PrintModels::PrintLatexCodeARFIMA()
  {
  decl uncertainty;

  //HBN
  if (i_SE == TRUE)
    uncertainty = m_mStdErr;
  else
    uncertainty = m_mTRatios;

  decl i, j, k, asParNames;
  asParNames = m_asParNames;

  for (i = 0; i < sizeof(asParNames); i++)
    {
    asParNames[i] = replace(asParNames[i], "_", "\_");
    }

  println("\n\n");
  println("Printing latex results for all models in a single table...");
  println("\n");

  // Print header
  println("\\begin{table}[tbph]");
  println("\\begin{center}");

  if (m_iM > 3) println("\\footnotesize");

  print("\\begin{tabular}{lr");

  for (i = 1; i < m_iM; i++)
    {
    print("r");
    }
  println("}");
  println("\hline");

  // Print model names
  for (i = 0; i < m_iM; i++)
    {
    print("& ", string(m_asModelNames[i]), " ");
    }
  println("\\\\");
  println("\hline");

  // Print estimates and standard errors
  for (i = 0; i < sizer(m_mEst); i++)
    {
    print(asParNames[i]);

    for (j = 0; j < m_iM; j++)
      {
      if (m_mEst[i][j] == .NaN)
        print(" & .");
      else
        //print(" & $\underset{(", strtrim(string(sprint("%8.3f", uncertainty[i][j]))), ")}{", strtrim(string(sprint("%8.3f", m_mEst[i][j]))), "}$");
        //HBN
        print(" & $\underset{(", strtrim(string(sprint("%" + sprint("8.", i_unc, i_scientific) , uncertainty[i][j]))), ")}{", strtrim(string(sprint( "%" + sprint("8.", i_par, i_scientific), m_mEst[i][j]))), "}$");
      }

    println(" \\\\");
    }
  println("\hline");

  // Print residual standard deviation and log-likelihood
  print("$\hat{\sigma}$");

  for (i = 0; i < m_iM; i++)
    {
    print(" & ", strtrim(string(sprint( "%" + sprint("8.", i_par, i_scientific) , m_mSigmaHat[0][i]))));
    }
  println(" \\\\");
  print("Log-lik.");

  for (i = 0; i < m_iM; i++)
    {
    print(" & ", strtrim(string(sprint("%8.3f", m_mLogLik[0][i]))));
    }
  println(" \\\\");
  println("\hline");

  // Print information criteria
  print("AIC");

  for (i = 0; i < m_iM; i++)
    {
    print(" & ", strtrim(string(sprint("%8.3f", m_mIC[0][i]))));
    }
  println(" \\\\");
  print("HQ");

  for (i = 0; i < m_iM; i++)
    {
    print(" & ", strtrim(string(sprint("%8.3f", m_mIC[1][i]))));
    }
  println(" \\\\");
  print("SC/BIC");

  for (i = 0; i < m_iM; i++)
    {
    print(" & ", strtrim(string(sprint("%8.3f", m_mIC[2][i]))));
    }
  println(" \\\\");
  println("\hline");

  // Print information criteria
  print("No autocorr. 1-", int(mLaglength));

  for (i = 0; i < m_iM; i++)
    {
    print(" & ", sprint("[", strtrim(string(sprint("%8.2f", m_mARTest[1][i]))), "]"));
    }
  println(" \\\\");
  print("No hetero.");

  for (i = 0; i < m_iM; i++)
    {
    print(" & ", sprint("[", strtrim(string(sprint("%8.2f", m_mHeteroTest[1][i]))), "]"));
    }
  println(" \\\\");
  print("Normality");

  for (i = 0; i < m_iM; i++)
    {
    print(" & ", sprint("[", strtrim(string(sprint("%8.2f", m_mNormTest[1][i]))), "]"));
    }
  println(" \\\\");
  println("\hline");

  // Print estimation sample info
  print("T");

  for (i = 0; i < m_iM; i++)
    {
    print(" & ", m_mT[0][i]);
    }
  println(" \\\\");
  print("Sample start");

  for (i = 0; i < m_iM; i++)
    {
    print(" & ", string(m_asSampleStart[i]));
    }
  println(" \\\\");
  print("Sample end");

  for (i = 0; i < m_iM; i++)
    {
    print(" & ", string(m_asSampleEnd[i]));
    }
  println(" \\\\");


  // Print footer
  println("\hline");
  println("\end{tabular}");
  println("\end{center}");
  println("\\vspace{1em}");

  if (i_SE == TRUE) println("\caption{The table shows estimates of the model in equation (X) with various restrictions imposed. Standard errors in ($\cdot$) and p-values in [$\cdot$] for misspecification tests.}");
  else           println("\caption{The table shows estimates of the model in equation (X) with various restrictions imposed. T-ratios in ($\cdot$) and p-values in [$\cdot$] for misspecification tests.}");
  println("\end{table}");
  }

  
// Prints a latex code with estimation results for all models in one table
PrintModels::PrintSimpleTableARFIMA()
  {
  decl uncertainty;

  //HBN
  if (i_SE == TRUE)
    uncertainty = m_mStdErr;
  else
    uncertainty = m_mTRatios;

  decl i, j, k, sBar;
  println("\n\n");
  println("Printing results for all models in a single table...");
  println("\n");

  // Create a string with a horizontal line
  sBar = "--------------------";

  for (i = 0; i < m_iM; i++)
    {
    sBar ~= "------------";
    }

  // Print model names
  println(sBar);
  print("                    ");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", string(m_asModelNames[i]));
    }
  println("");
  println(sBar);

  // Print estimates and standard errors
  for (i = 0; i < sizer(m_mEst); i++)
    {
    print("%-20s", m_asParNames[i]);

    for (j = 0; j < m_iM; j++)
      {
      if (m_mEst[i][j] == .NaN)
        print("%12s", ".");
      else
        print("%12s", strtrim(string(sprint("%8.3f", m_mEst[i][j]))));
      }
    println("");
    print("%-20s", "");

    for (j = 0; j < m_iM; j++)
      {
      if (m_mEst[i][j] == .NaN)
        print("%12s", ".");
      else
        print("%12s", sprint("(", strtrim(string(sprint("%8.3f", uncertainty[i][j]))), ")"));
      }
    println("\n\n");
    }
  println(sBar);

  // Print residual standard deviation and log-likelihood
  print("%-20s", "sigma");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", strtrim(string(sprint("%8.3f", m_mSigmaHat[0][i]))));
    }
  println("");
  print("%-20s", "Log-lik.");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", strtrim(string(sprint("%8.3f", m_mLogLik[0][i]))));
    }
  println("");
  println(sBar);

  // Print information criteria
  print("%-20s", "AIC");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", strtrim(string(sprint("%8.3f", m_mIC[0][i]))));
    }
  println("");
  print("%-20s", "HQ");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", strtrim(string(sprint("%8.3f", m_mIC[1][i]))));
    }
  println("");
  print("%-20s", "SC/BIC");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", strtrim(string(sprint("%8.3f", m_mIC[2][i]))));
    }
  println("");
  println(sBar);

  // Print information criteria
  print("%-20s", sprint("No autocorr. 1-", int(mLaglength)));

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", sprint("[", strtrim(string(sprint("%8.2f", m_mARTest[1][i]))), "]"));
    }
  println("");
  print("%-20s", "No hetero.");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", sprint("[", strtrim(string(sprint("%8.2f", m_mHeteroTest[1][i]))), "]"));
    }
  println("");
  print("%-20s", "Normality");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", sprint("[", strtrim(string(sprint("%8.2f", m_mNormTest[1][i]))), "]"));
    }
  println("");
  println(sBar);

  // Print estimation sample info
  print("%-20s", "T");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", sprint(m_mT[0][i]));
    }
  println("");
  print("%-20s", "Sample start");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", string(m_asSampleStart[i]));
    }
  println("");
  print("%-20s", "Sample end");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", string(m_asSampleEnd[i]));
    }
  println("");
  println(sBar);

  if (i_SE == TRUE) println("Table 1. The table shows estimates of the model in equation (X) with various restrictions imposed. Standard errors in (.) and p-values in [.] for misspecification tests.");
  else           println("Table 1. The table shows estimates of the model in equation (X) with various restrictions imposed. T-ratios in (.) and p-values in [.] for misspecification tests.");
  }


// Gets the estimation results and prints them in a table and as a latex code
PrintModels::PrintTable()
  {
  if (m_myclass == "PcGive")
    {
    GetParNamesPCGIVE();
    GetResultsPCGIVE();
    PrintSimpleTablePCGIVE();
    PrintLatexCodePCGIVE();
    }
  else if (m_myclass == "PcGiveGarch")
    {
    GetParNamesARCH();
    GetResultsARCH();
    PrintSimpleTableARCH();
    PrintLatexCodeARCH();
    }
  else if (m_myclass == "Arfima")
    {
    GetParNamesARFIMA();
    GetResultsARFIMA();
    PrintSimpleTableARFIMA();
    PrintLatexCodeARFIMA();
    }
  else if (m_myclass == "Garch")
    {
    GetParNamesGARCH();
    GetResultsGARCH();
    PrintSimpleTableGARCH();
    PrintLatexCodeGARCH();
    }
  }


//////////////////////////////////////////////////////////////
// G@RCH //////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////

// Gets all parameter names, joins them, and sort them
PrintModels::GetParNamesGARCH()
  {
  // Declare and initialize variables
  decl i, j, oModel, asParNamesTemp;
  decl asParNamesM, asParNamesV, asParNamesE;
  
  asParNamesM = {};
  asParNamesV = {};
  asParNamesE = {};
  
  // Loop over all models in m_oModels
  for (i = 0; i < sizeof(m_oModels); i++)
    {
    // Get the  models
    oModel = m_oModels[i];

    // Get the variable names for this model object and add them to asParNames
    asParNamesTemp = oModel.GetParNames();

    for (j = 0; j < sizeof(asParNamesTemp); j++)
      {
      if(strfind((asParNamesM~asParNamesV~asParNamesE), asParNamesTemp[j]) == -1)
	    {
        if(strfind(asParNamesTemp[j],"AR(") >= 0)
		  {
		  asParNamesM ~= asParNamesTemp[j];
		  }
        else if(strfind(asParNamesTemp[j],"MA(") >= 0)
		  {
		  asParNamesM ~= asParNamesTemp[j];
		  }
        else if(strfind(asParNamesTemp[j],"(M)") >= 0)
		  {
		  asParNamesM ~= asParNamesTemp[j];
		  }
        else if(strfind(asParNamesTemp[j],"(V)") >= 0)
		  {
		  asParNamesV ~= asParNamesTemp[j];
		  }
        else if(strfind(asParNamesTemp[j],"ARCH(Alpha") >= 0)
		  {
		  asParNamesV ~= asParNamesTemp[j];
		  }
        else if(strfind(asParNamesTemp[j],"ARCH(Beta") >= 0)
		  {
		  asParNamesV ~= asParNamesTemp[j];
		  }
        else
		  {
		  asParNamesE ~= asParNamesTemp[j];
		  }
		}
      }
    }

  m_asParNames = asParNamesM~asParNamesV~asParNamesE;
  //print("\n\nher...",asParNamesM,asParNamesV,asParNamesE,m_asParNames);
  }

  
// Gets the estimation results from the class object m_oModels
PrintModels::GetResultsGARCH()
  {
  // Declare and initialize variables
  decl mEst, mStdErr, mTRatios, oModel, mEstTemp, mStdErrTemp, mTRatiosTemp, asParNamesTemp;
  decl mLogLik, mT, asSampleStart, asSampleEnd, mIC, mARTest, mHeteroTest, mNormTest;

  mEst = mStdErr = mTRatios = nans(sizeof(m_asParNames), m_iM);
  mLogLik = mT = nans(1, m_iM);
  mARTest = mHeteroTest = mNormTest = nans(2, m_iM);
  mIC = nans(3, m_iM);
  asSampleStart = asSampleEnd = new array[m_iM];

  for(decl i = 0; i < sizeof(m_oModels); i++)
    {
    // Get the Model
    oModel = m_oModels[i];
    oModel.SetPrint(0);

    // Get the estimates, standard errors, and t-ratios
    asParNamesTemp = oModel.GetParNames();
    mEstTemp       = oModel.GetValue("m_vPar");
    mStdErrTemp    = oModel.GetValue("m_vStdErrors")';
  
	mTRatiosTemp   = mEstTemp ./ mStdErrTemp;

	// Add the estimates, standard errors, and t-ratios
    mEst[strfind(m_asParNames, asParNamesTemp)][i] = mEstTemp;
    mStdErr[strfind(m_asParNames, asParNamesTemp)][i] = mStdErrTemp;
    mTRatios[strfind(m_asParNames, asParNamesTemp)][i] = mTRatiosTemp;

	// Get the log-likelihood
    mLogLik[0][i] = oModel.GetValue("m_dLogLik");

    // Get the sample information
    decl temp        = oModel.GetSelSample();
    asSampleStart[i] = temp[0:strfind(temp, " - ") - 1];
    asSampleEnd[i]   = temp[strfind(temp, " - ") + 3:];
    //asSampleStart[i] = oModel.GetValue("m_iYear1");
    //asSampleEnd[i]   = oModel.GetValue("m_iT2est");
    mT[0][i]         = oModel.GetValue("m_cT");

    // Get the information criteria
    mIC[0][i] = (2 * sizer(mEstTemp) - 2 * mLogLik[0][i]) / mT[0][i];                   // AIC
    mIC[1][i] = (-2 * mLogLik[0][i] + 2 * sizer(mEstTemp) * log(log(mT[0][i]))) / mT[0][i]; // HQ
    mIC[2][i] = (log(mT[0][i]) * sizer(mEstTemp) - 2 * mLogLik[0][i]) / mT[0][i];       // SQ/BIC

    // Get the misspecification tests
    mLaglength  = 5;//max(int(sqrt(rows(oModel.GetResiduals()))), 3 * oModel.GetFrequency());
	decl dfloss      = 0;
	
	decl stdres = oModel.GetValue("m_vE")./sqrt(oModel.GetValue("m_vSigma2"));
	
    mARTest[][i]     = PortmanteauTest(stdres, mLaglength , dfloss, TRUE);
    mHeteroTest[][i] = ArchTest(stdres, 1, 1, rows(oModel.GetParNames()) - 1, TRUE);
    mNormTest[][i]   = NormalityTest(stdres, TRUE);
    }

  // Set class variables
  m_mEst          = mEst;
  m_mStdErr       = mStdErr;
  m_mTRatios      = mTRatios;
  m_mLogLik       = mLogLik;
  m_mT            = mT;
  m_asSampleStart = asSampleStart;
  m_asSampleEnd   = asSampleEnd;
  m_mIC           = mIC;
  m_mARTest       = mARTest;
  m_mHeteroTest   = mHeteroTest;
  m_mNormTest     = mNormTest;
//print("\n\nfinal...",oModel.GetValue("m_vE")./sqrt(oModel.GetValue("m_vSigma2")));
  }


// Prints a latex code with estimation results for all models in one table
PrintModels::PrintLatexCodeGARCH()
  {
  decl uncertainty;

  //HBN
  if (i_SE == TRUE)
    uncertainty = m_mStdErr;
  else
    uncertainty = m_mTRatios;

  decl i, j, k, asParNames;
  asParNames = m_asParNames;

  for (i = 0; i < sizeof(asParNames); i++)
    {
    asParNames[i] = replace(asParNames[i], "_", "\_");
    }

  println("\n\n");
  println("Printing latex results for all models in a single table...");
  println("\n");

  // Print header
  println("\\begin{table}[tbph]");
  println("\\begin{center}");

  if (m_iM > 3) println("\\footnotesize");

  print("\\begin{tabular}{lr");

  for (i = 1; i < m_iM; i++)
    {
    print("r");
    }
  println("}");
  println("\hline");

  // Print model names
  for (i = 0; i < m_iM; i++)
    {
    print("& ", string(m_asModelNames[i]), " ");
    }
  println("\\\\");
  println("\hline");

  // Print estimates and standard errors
  for (i = 0; i < sizer(m_mEst); i++)
    {
    print(asParNames[i]);

    for (j = 0; j < m_iM; j++)
      {
      if (m_mEst[i][j] == .NaN)
        print(" & .");
      else
        //print(" & $\underset{(", strtrim(string(sprint("%8.3f", uncertainty[i][j]))), ")}{", strtrim(string(sprint("%8.3f", m_mEst[i][j]))), "}$");
        //HBN
        print(" & $\underset{(", strtrim(string(sprint("%#" + sprint("8.", i_unc, i_scientific) , uncertainty[i][j]))), ")}{", strtrim(string(sprint( "%#" + sprint("8.", i_par, i_scientific), m_mEst[i][j]))), "}$");
      }

    println(" \\\\");
    }
  println("\hline");

  // Print log-likelihood
  print("Log-lik.");
  for (i = 0; i < m_iM; i++)
    {
    print(" & ", strtrim(string(sprint("%8.3f", m_mLogLik[0][i]))));
    }
  println(" \\\\");
  println("\hline");

  // Print information criteria
  print("AIC");
  for (i = 0; i < m_iM; i++)
    {
    print(" & ", strtrim(string(sprint("%8.3f", m_mIC[0][i]))));
    }
  println(" \\\\");
  print("HQ");
  for (i = 0; i < m_iM; i++)
    {
    print(" & ", strtrim(string(sprint("%8.3f", m_mIC[1][i]))));
    }
  println(" \\\\");

  print("SC/BIC");
  for (i = 0; i < m_iM; i++)
    {
    print(" & ", strtrim(string(sprint("%8.3f", m_mIC[2][i]))));
    }
  println(" \\\\");
  println("\hline");

  // Print information criteria
  print("Portmanteau(5)");
  for (i = 0; i < m_iM; i++)
    {
    print(" & ", sprint("[", strtrim(string(sprint("%8.2f", m_mARTest[1][i]))), "]"));
    //print(" & ", "...");
    }
  println(" \\\\");

  print("No ARCH(1)");
  for (i = 0; i < m_iM; i++)
    {
    print(" & ", sprint("[", strtrim(string(sprint("%8.2f", m_mHeteroTest[1][i]))), "]"));
    //print(" & ", "...");
    }
  println(" \\\\");

  print("Normality");
  for (i = 0; i < m_iM; i++)
    {
    print(" & ", sprint("[", strtrim(string(sprint("%8.2f", m_mNormTest[1][i]))), "]"));
    //print(" & ", "...");
    }
  println(" \\\\");
  println("\hline");

  // Print estimation sample info
  print("T");
  for (i = 0; i < m_iM; i++)
    {
    print(" & ", m_mT[0][i]);
    }
  println(" \\\\");

  print("Sample start");
  for (i = 0; i < m_iM; i++)
    {
    print(" & ", string(m_asSampleStart[i]));
    }
  println(" \\\\");
  print("Sample end");

  for (i = 0; i < m_iM; i++)
    {
    print(" & ", string(m_asSampleEnd[i]));
    }
  println(" \\\\");


  // Print footer
  println("\hline");
  println("\end{tabular}");
  println("\end{center}");
  println("\\vspace{1em}");

  if (i_SE == TRUE) println("\caption{The table shows estimates of the model in equation (X) with various restrictions imposed. Standard errors in ($\cdot$) and p-values in [$\cdot$] for misspecification tests.}");
  else           println("\caption{The table shows estimates of the model in equation (X) with various restrictions imposed. T-ratios in ($\cdot$) and p-values in [$\cdot$] for misspecification tests.}");
  println("\end{table}");

  }


// Prints a latex code with estimation results for all models in one table
PrintModels::PrintSimpleTableGARCH()
  {
  decl uncertainty;

  //HBN
  if (i_SE == TRUE)
    uncertainty = m_mStdErr;
  else
    uncertainty = m_mTRatios;

  decl i, j, k, sBar;
  println("\n\n");
  println("Printing results for all models in a single table...");
  println("\n");

  // Create a string with a horizontal line
  sBar = "--------------------";

  for (i = 0; i < m_iM; i++)
    {
    sBar ~= "------------";
    }

  // Print model names
  println(sBar);
  print("                    ");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", string(m_asModelNames[i]));
    }
  println("");
  println(sBar);

  // Print estimates and standard errors
  for (i = 0; i < sizer(m_mEst); i++)
    {
    print("%-20s", m_asParNames[i]);

    for (j = 0; j < m_iM; j++)
      {
      if (m_mEst[i][j] == .NaN)
        print("%12s", ".");
      else
        print("%12s", strtrim(string(sprint("%8.3f", m_mEst[i][j]))));
      }
    println("");
    print("%-20s", "");

    for (j = 0; j < m_iM; j++)
      {
      if (m_mEst[i][j] == .NaN)
        print("%12s", ".");
      else
        print("%12s", sprint("(", strtrim(string(sprint("%8.3f", uncertainty[i][j]))), ")"));
      }
    println("\n\n");
    }
  println(sBar);

  // Print log-likelihood
  print("%-20s", "Log-lik.");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", strtrim(string(sprint("%8.3f", m_mLogLik[0][i]))));
    }
  println("");
  println(sBar);


  // Print information criteria
  print("%-20s", "AIC");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", strtrim(string(sprint("%8.3f", m_mIC[0][i]))));
    }
  println("");
  print("%-20s", "HQ");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", strtrim(string(sprint("%8.3f", m_mIC[1][i]))));
    }
  println("");
  print("%-20s", "SC/BIC");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", strtrim(string(sprint("%8.3f", m_mIC[2][i]))));
    }
  println("");
  println(sBar);

  // Print information criteria
  print("%-20s", sprint("Portmanteau(5)"));

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", sprint("[", strtrim(string(sprint("%8.2f", m_mARTest[1][i]))), "]"));
    }
  println("");
  print("%-20s", "No ARCH(1)");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", sprint("[", strtrim(string(sprint("%8.2f", m_mHeteroTest[1][i]))), "]"));
    }
  println("");
  print("%-20s", "Normality");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", sprint("[", strtrim(string(sprint("%8.2f", m_mNormTest[1][i]))), "]"));
    }
  println("");
  println(sBar);

  // Print estimation sample info
  print("%-20s", "T");

  for (i = 0; i < m_iM; i++)
    {
    print("%12s", sprint(m_mT[0][i]));
    }
  println("");
//  print("%-20s", "Sample start");
//
//  for (i = 0; i < m_iM; i++)
//    {
//    print("%12s", string(m_asSampleStart[i]));
//    }
//  println("");
//  print("%-20s", "Sample end");
//
//  for (i = 0; i < m_iM; i++)
//    {
//    print("%12s", string(m_asSampleEnd[i]));
//    }
//  println("");
  println(sBar);

  if (i_SE == TRUE) println("Table 1. The table shows estimates of the model in equation (X) with various restrictions imposed. Standard errors in (.) and p-values in [.] for misspecification tests.");
  else           println("Table 1. The table shows estimates of the model in equation (X) with various restrictions imposed. T-ratios in (.) and p-values in [.] for misspecification tests.");

  }
  