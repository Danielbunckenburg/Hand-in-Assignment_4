#include <oxstd.oxh>
#import <packages/PcGive/pcgive>

run_1()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for EQ( 1)
	decl model = new PcGive();

	model.Load("C:\\Users\\Bruger\\OneDrive - University of Copenhagen\\Polit 2021\\Economics2\\Problemset_5\\Data\\ConsumptionData.in7");
	model.Deterministic(-1);

	model.Select("Y", {"c", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("Y", {"c", 1, 3});
	model.Select("X", {"Trend", 0, 0});
	model.SetSelSample(1971, 4, 2018, 3);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_2()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for EQ( 2)
	decl model = new PcGive();

	model.Load("C:\\Users\\Bruger\\OneDrive - University of Copenhagen\\Polit 2021\\Economics2\\Problemset_5\\Data\\ConsumptionData.in7");
	model.Deterministic(-1);

	model.Select("Y", {"c", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("Y", {"c", 1, 3});
	model.Select("X", {"Trend", 0, 0});
	model.SetRobustSEType(1);
	model.SetSelSample(1971, 4, 2018, 3);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_3()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for EQ( 3)
	decl model = new PcGive();

	model.Load("C:\\Users\\Bruger\\OneDrive - University of Copenhagen\\Polit 2021\\Economics2\\Problemset_5\\Data\\ConsumptionData.in7");
	model.Deterministic(-1);

	model.Select("Y", {"dc", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("Y", {"dc", 1, 2});
	model.Select("X", {"c", 1, 1});
	model.Select("X", {"Trend", 0, 0});
	model.SetRobustSEType(1);
	model.SetSelSample(1971, 4, 2018, 3);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_4()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for EQ( 4)
	decl model = new PcGive();

	model.Load("C:\\Users\\Bruger\\OneDrive - University of Copenhagen\\Polit 2021\\Economics2\\Problemset_5\\Data\\ConsumptionData.in7");
	model.Deterministic(-1);

	model.Select("Y", {"dc", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("Y", {"dc", 1, 1});
	model.Select("X", {"c", 1, 1});
	model.Select("X", {"Trend", 0, 0});
	model.SetRobustSEType(1);
	model.SetSelSample(1971, 4, 2018, 3);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_5()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for EQ( 5)
	decl model = new PcGive();

	model.Load("C:\\Users\\Bruger\\OneDrive - University of Copenhagen\\Polit 2021\\Economics2\\Problemset_5\\Data\\ConsumptionData.in7");
	model.Deterministic(-1);

	model.Select("Y", {"dc", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("Y", {"dc", 1, 1});
	model.Select("X", {"c", 1, 1});
	model.Select("X", {"Trend", 0, 0});
	model.SetSelSample(1971, 4, 2018, 3);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

main()
{
	run_1();
	run_2();
	run_3();
	run_4();
	run_5();
}
