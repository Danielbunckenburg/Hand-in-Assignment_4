#include <oxstd.oxh>
#import <packages/PcGive/pcgive_ects>
#import <packages/arfima/arfima>

// ------------------------------------------------
// Information:
//
// To use the PrintModels module
// Add the following 4 lines to import PrintModels
// ------------------------------------------------
#import <packages/PcGive/pcgive_ects>
#import <packages/PcGive/pcgive_garch>
#import <packages/arfima/arfima>
#import <PrintModels>

run_1()
  {
  //--- Ox code for EQ( 1)
  decl model = new PcGive();

  model.Load("GDP.in7");
  model.Deterministic(-1);

  model.Select(Y_VAR, {"dy", 0, 0});
  model.Select(X_VAR, {"Constant", 0, 0});
  model.Select(Y_VAR, {"dy", 1, 3});

  model.SetSelSample(1975, 1, 2015, 3);
  model.SetMethod(M_OLS);
  model.Estimate();
  model.TestSummary();

  // ------------------------------------------
  // Replace "delete model;" by "return model;"
  // ------------------------------------------
  // delete model;
  return model;
  }

run_2()
  {
  //--- Ox code for EQ( 1)
  decl model = new PcGive();

  model.Load("GDP.in7");
  model.Deterministic(-1);

  model.Select(Y_VAR, {"dy", 0, 0});
  model.Select(X_VAR, {"Constant", 0, 0});
  model.Select(Y_VAR, {"dy", 1, 2});

  model.SetSelSample(1975, 1, 2015, 3);
  model.SetMethod(M_OLS);
  model.Estimate();
  model.TestSummary();

  // ------------------------------------------
  // Replace "delete model;" by "return model;"
  // ------------------------------------------
  // delete model;
  return model;
  }


main()
  {
  // ----------------------------
  // Replace "run_1();" with
  //         "decl m1 = run_1();"
  // ----------------------------
  // run_1();
  // run_2();
  decl m1 = run_1();
  decl m2 = run_2();

  // ----------------------------
  // Use the PrintModels class by
  // adding the following lines.
  // ----------------------------
  decl printmodels = new PrintModels();       // Creates a new class object called "printmodels", which we use to print results of the estimated models we add in the next line.
  printmodels.AddModels(m1, m2 );             // Select models to print.
  printmodels.SetModelNames({"(1)","(2)"});   // Set the model names in the table.
  printmodels.SetPrintFormat(FALSE,TRUE,4,3); // Print format: Use SE , use scientific notation, precision of estimates, precision of standard errors/t-values
  printmodels.PrintTable();                   // Produce tex-table.

  // ------------------------------
  // Delete everything from memory.
  // ------------------------------
  delete m1,m2;
  delete printmodels;
  }
