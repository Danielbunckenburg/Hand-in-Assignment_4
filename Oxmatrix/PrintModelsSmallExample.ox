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
 // This program requires a licenced version of PcGive Professional.
	//--- Ox code for EQ( 1)
	decl model = new PcGive();

	model.Load("C:\\Users\\Bruger\\OneDrive - University of Copenhagen\\Polit 2021\\Economics2\\Hand-in-Assignment_4\\Data\\Assignment_4.in7");
	model.Deterministic(-1);

	model.Select("Y", {"st", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("Y", {"st", 1, 6});
	model.Select("X", {"isJan", 0, 0});
	model.Select("X", {"isFeb", 0, 0});
	model.Select("X", {"isMar", 0, 0});
	model.Select("X", {"isApr", 0, 0});
	model.Select("X", {"isMay", 0, 0});
	model.Select("X", {"isJun", 0, 0});
	model.Select("X", {"isJul", 0, 0});
	model.Select("X", {"isAug", 0, 0});
	model.Select("X", {"isSep", 0, 0});
	model.Select("X", {"isOct", 0, 0});
	model.Select("X", {"isNov", 0, 0});
	model.Select("X", {"isDec", 0, 0});
	model.SetSelSampleByDates(dayofcalendar(2000, 1, 19), dayofcalendar(2021, 11, 22));
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

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

  // ----------------------------
  // Use the PrintModels class by
  // adding the following lines.
  // ----------------------------
  decl printmodels = new PrintModels();       // Creates a new class object called "printmodels", which we use to print results of the estimated models we add in the next line.
  printmodels.AddModels(m1 );             // Select models to print.
  printmodels.SetModelNames({"(1)"});   // Set the model names in the table.
  printmodels.SetPrintFormat(FALSE,TRUE,4,3); // Print format: Use SE , use scientific notation, precision of estimates, precision of standard errors/t-values
  printmodels.PrintTable();                   // Produce tex-table.

  // ------------------------------
  // Delete everything from memory.
  // ------------------------------
  delete m1;
  delete printmodels;
  }
