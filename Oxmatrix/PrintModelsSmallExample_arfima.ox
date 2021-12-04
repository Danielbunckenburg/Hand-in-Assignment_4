#include <oxstd.oxh>
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
  //--- Ox code for Arfima( 1)
  decl model = new Arfima();

  model.Load("GDP.in7");
  model.Deterministic(-1);

  model.Select("Y", {"d4y", 0, 0});
  model.Select("X", {"Constant", 0, 0});
  model.Select("X", {"d0804", 0, 0});
  model.ARMA(2,1);
  model.FixD(0);
  model.SetSelSample(1981, 1, 2015, 3);
  model.SetMethod("MPL");
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
  //--- Ox code for Arfima( 2)
  decl model = new Arfima();

  model.Load("GDP.in7");
  model.Deterministic(-1);

  model.Select("Y", {"d4y", 0, 0});
  model.Select("X", {"Constant", 0, 0});
  model.ARMA(4,1);
  model.FixD(0);
  model.FixAR(<2; 3 >);
  model.SetSelSample(1981, 1, 2015, 3);
  model.SetMethod("MPL");
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
  decl m1 = run_1();
  decl m2 = run_2();

  // ----------------------------
  // Use the PrintModels class by
  // adding the following lines.
  // ----------------------------
  decl printmodels = new PrintModels();           // Creates a new class object called "printmodels", which we use to print results of the estimated models we add in the next line.
  printmodels.AddModels(m1, m2);                  // Select models to print.
  printmodels.SetModelNames({"First","Second"});  // Set the model names in the table.
  printmodels.SetPrintFormat(FALSE,TRUE,4,3);     // Print format: Use SE , use scientific notation, precision of estimates, precision of standard errors/t-values
  printmodels.PrintTable();                       // Produce tex-table.

  // ------------------------------
  // Delete everything from memory.
  // ------------------------------
  delete m1, m2;
  delete printmodels;
  }
