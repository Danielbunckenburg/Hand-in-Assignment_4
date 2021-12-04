#include <oxstd.oxh>
#import <packages/PcGive/pcgive_garch>

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
  //--- Ox code for VOL( 1)
  decl model = new PcGiveGarch();

  model.Load("SP500Data.in7");
  model.Deterministic(-1);

  model.Select("Y", {"Dlog(sp500)", 0, 0});
  model.Select("X", {"Constant", 0, 0});
  model.GARCH(1, 1);
  model.SetSelSampleByDates(dayofcalendar(1997, 1, 2), dayofcalendar(2018, 2, 27));
  model.SetMethod("ML");
  model.Estimate();

  // ------------------------------------------
  // Replace "delete model;" by "return model;"
  // ------------------------------------------
  // delete model;
  return model;
  }

run_2()
  {
  //--- Ox code for VOL( 3)
  decl model = new PcGiveGarch();

  model.Load("SP500Data.in7");
  model.Deterministic(-1);

  model.Select("Y", {"Dlog(sp500)", 0, 0});
  model.Select("X", {"Constant", 0, 0});
  model.Select("Y", {"Dlog(sp500)", 1, 2});
  model.GARCH(0, 3);
  model.SetSelSampleByDates(dayofcalendar(1997, 1, 6), dayofcalendar(2018, 2, 27));
  model.SetMethod("ML");
  model.Estimate();

  // ------------------------------------------
  // Replace "delete model;" by "return model;"
  // ------------------------------------------
  // delete model;
  return model;
  }

run_3()
  {
  //--- Ox code for VOL( 6)
  decl model = new PcGiveGarch();

  model.Load("SP500Data.in7");
  model.Deterministic(-1);

  model.Select("HX", {"payrollAVG_sur", 0, 0});
  model.Select("Y", {"Dlog(sp500)", 0, 0});
  model.Select("X", {"Constant", 0, 0});
  model.Select("Y", {"Dlog(sp500)", 1, 2});
  model.Select("X", {"payrollAVG_sur", 0, 0});
  model.GARCH(1, 1);
  model.SetSelSampleByDates(dayofcalendar(1997, 1, 6), dayofcalendar(2018, 2, 27));
  model.SetMethod("ML");
  model.Estimate();

  // ------------------------------------------
  // Replace "delete model;" by "return model;"
  // ------------------------------------------
  // delete model;
  return model;
  }

run_4()
  {
  //--- Ox code for VOL( 8)
  decl model = new PcGiveGarch();

  model.Load("SP500Data.in7");
  model.Deterministic(-1);

  model.Select("Y", {"Dlog(sp500)", 0, 0});
  model.Select("X", {"Constant", 0, 0});
  model.Select("Y", {"Dlog(sp500)", 1, 2});
  model.Select("X", {"payrollAVG_sur", 0, 0});
  model.GARCHM_t(1, 1);
  model.SetSelSampleByDates(dayofcalendar(1997, 1, 6), dayofcalendar(2018, 2, 27));
  model.SetMethod("ML");
  model.Estimate();

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
  decl m3 = run_3();
  decl m4 = run_4();

  // ----------------------------
  // Use the PrintModels class by
  // adding the following lines.
  // ----------------------------
  decl printmodels = new PrintModels();                    // Creates a new class object called "printmodels", which we use to print results of the estimated models we add in the next line.
  printmodels.AddModels(m1, m2 , m3, m4);                  // Select models to print.
  printmodels.SetModelNames({"(1)", "(2)", "(3)", "(4)"}); // Set the model names in the table.
  printmodels.SetPrintFormat(TRUE, TRUE, 4, 3);            // Print format: Use SE , use scientific notation, precision of estimates, precision of standard errors/t-values
  printmodels.PrintTable();                                // Produce tex-table.

  // ------------------------------
  // Delete everything from memory.
  // ------------------------------
  delete m1, m2, m3, m4;
  delete printmodels;
  }
