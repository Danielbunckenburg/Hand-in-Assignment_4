#include <oxstd.oxh>

// ------------------------------------------------
// Information:
//
// To use the PrintModels module
// Add the following 4 lines to import PrintModels
// ------------------------------------------------
#import <packages/Garch/garch>
#import <packages/PcGive/pcgive_ects>
#import <packages/PcGive/pcgive_garch>
#import <packages/arfima/arfima>
#import <PrintModels>


run_1()
{
	//--- Ox code for G@RCH(1)
	decl model = new Garch();

	model.Load("H:\\Teaching\\EconometricsII\\OxCodeTeaching\\PrintModels\\SP500Data.in7");
	model.Deterministic(-1);

	model.Select("Y", {"Dlog(sp500)", 0, 0});
	model.CSTS(1,1);
	model.DISTRI(0);
	model.ARMA_ORDERS(0,0);
	model.ARFIMA(0);
	model.GARCH_ORDERS(1,1);
	model.MODEL(Garch::EGARCH);
	model.MLE(2);
	model.ITER(0);

	model.SetSelSampleByDates(dayofcalendar(1997, 1, 2), dayofcalendar(2018, 2, 27));
	model.Initialization(<>);
	model.DoEstimation(<>);
	model.Output();


	return model;
}

run_2()
{
	//--- Ox code for G@RCH(2)
	decl model = new Garch();

	model.Load("H:\\Teaching\\EconometricsII\\OxCodeTeaching\\PrintModels\\SP500Data.in7");
	model.Deterministic(-1);

	model.Select("Y", {"Dlog(sp500)", 0, 0});
	model.CSTS(1,1);
	model.DISTRI(0);
	model.ARMA_ORDERS(0,0);
	model.ARFIMA(0);
	model.GARCH_ORDERS(1,1);
	model.MODEL(Garch::GARCH);
	model.MLE(2);
	model.ITER(0);

	model.SetSelSampleByDates(dayofcalendar(1997, 1, 2), dayofcalendar(2018, 2, 27));
	model.Initialization(<>);
	model.DoEstimation(<>);
	model.Output();


	return model;
}

run_3()
{
	//--- Ox code for G@RCH(3)
	decl model = new Garch();

	model.Load("H:\\Teaching\\EconometricsII\\OxCodeTeaching\\PrintModels\\SP500Data.in7");
	model.Deterministic(-1);

	model.Select("Y", {"Dlog(sp500)", 0, 0});
	model.CSTS(1,1);
	model.DISTRI(1);
	model.ARMA_ORDERS(0,0);
	model.ARFIMA(0);
	model.GARCH_ORDERS(1,1);
	model.MODEL(Garch::GARCH);
	model.MLE(2);
	model.ITER(0);

	model.SetSelSampleByDates(dayofcalendar(1997, 1, 2), dayofcalendar(2018, 2, 27));
	model.Initialization(<>);
	model.DoEstimation(<>);
	model.Output();


	return model;
}

run_4()
{
	//--- Ox code for G@RCH(4)
	decl model = new Garch();

	model.Load("H:\\Teaching\\EconometricsII\\OxCodeTeaching\\PrintModels\\SP500Data.in7");
	model.Deterministic(-1);

	model.Select("Y", {"Dlog(sp500)", 0, 0});
	model.Select("X", {"FirstTrade", 0, 0});
	model.Select("X", {"LastTrade", 0, 0});
	model.CSTS(1,1);
	model.DISTRI(1);
	model.ARMA_ORDERS(0,0);
	model.ARFIMA(0);
	model.GARCH_ORDERS(1,1);
	model.MODEL(Garch::GJR);
	model.MLE(2);
	model.ITER(0);

	model.SetSelSampleByDates(dayofcalendar(1997, 1, 2), dayofcalendar(2018, 2, 27));
	model.Initialization(<>);
	model.DoEstimation(<>);
	model.Output();


	return model;
}

run_5()
{
	//--- Ox code for G@RCH(5)
	decl model = new Garch();

	model.Load("H:\\Teaching\\EconometricsII\\OxCodeTeaching\\PrintModels\\SP500Data.in7");
	model.Deterministic(-1);

	model.Select("Z", {"FirstTrade", 0, 0});
	model.Select("Z", {"LastTrade", 0, 0});
	model.Select("Y", {"Dlog(sp500)", 0, 0});
	model.Select("X", {"FirstTrade", 0, 0});
	model.Select("X", {"LastTrade", 0, 0});
	model.CSTS(1,1);
	model.DISTRI(1);
	model.ARMA_ORDERS(0,0);
	model.ARFIMA(0);
	model.GARCH_ORDERS(1,1);
	model.MODEL(Garch::GJR);
	model.MLE(2);
	model.ITER(0);

	model.SetSelSampleByDates(dayofcalendar(1997, 1, 2), dayofcalendar(2018, 2, 27));
	model.Initialization(<>);
	model.DoEstimation(<>);
	model.Output();


	return model;
}

run_6()
{
	//--- Ox code for G@RCH(1)
	decl model = new Garch();

	model.Load("H:\\Teaching\\EconometricsII\\OxCodeTeaching\\PrintModels\\SP500Data.in7");
	model.Deterministic(-1);

	model.Select("Y", {"Dlog(sp500)", 0, 0});
	model.Select("X", {"FirstTrade", 0, 0});
	model.Select("X", {"LastTrade", 0, 0});
	model.CSTS(1,1);
	model.DISTRI(1);
	model.ARMA_ORDERS(1,1);
	model.ARFIMA(0);
	model.GARCH_ORDERS(1,1);
	model.MODEL(Garch::EGARCH);
	model.MLE(2);
	model.ITER(0);

	model.SetSelSampleByDates(dayofcalendar(1997, 1, 2), dayofcalendar(2018, 2, 27));
	model.Initialization(<>);
	model.DoEstimation(<>);
	model.Output();


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
  decl m5 = run_5();
  decl m6 = run_6();

  // ----------------------------
  // Use the PrintModels class by
  // adding the following lines.
  // ----------------------------
  decl printmodels = new PrintModels();                    // Creates a new class object called "printmodels", which we use to print results of the estimated models we add in the next line.
  printmodels.AddModels(m1,m2,m3,m4,m5,m6);                  // Select models to print.
  printmodels.SetModelNames({"(1)","(2)","(3)","(4)","(5)","(6)"}); // Set the model names in the table.
  printmodels.SetPrintFormat(TRUE, TRUE, 4, 3);            // Print format: Use SE , use scientific notation, precision of estimates, precision of standard errors/t-values
  printmodels.PrintTable();                                // Produce tex-table.

  // ------------------------------
  // Delete everything from memory.
  // ------------------------------
//test(m1);  
//print("%v",m1);
  delete m1;
//  delete printmodels;
  }
