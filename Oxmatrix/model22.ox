#include <oxstd.oxh>
#import <packages/PcGive/pcgive>

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
	model.SetSelSampleByDates(dayofcalendar(2000, 1, 19), dayofcalendar(2021, 11, 22));
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_2()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for SYS( 2)
	decl model = new PcGive();

	model.Load("C:\\Users\\Bruger\\OneDrive - University of Copenhagen\\Polit 2021\\Economics2\\Hand-in-Assignment_4\\Data\\Assignment_4.in7");
	model.Deterministic(-1);

	model.Select("Y", {"st", 0, 0});
	model.Select("Y", {"isSep", 0, 0});
	model.Select("Y", {"isFeb", 0, 0});
	model.Select("Y", {"isMar", 0, 0});
	model.Select("Y", {"isApr", 0, 0});
	model.Select("Y", {"isMay", 0, 0});
	model.Select("Y", {"isJun", 0, 0});
	model.Select("Y", {"isJul", 0, 0});
	model.Select("Y", {"isAug", 0, 0});
	model.Select("Y", {"isOct", 0, 0});
	model.Select("Y", {"isNov", 0, 0});
	model.Select("Y", {"isDec", 0, 0});
	model.Select("Y", {"st", 1, 6});
	model.Select("U", {"Constant", 0, 0});
	model.SetModelClass("SYSTEM");
	model.SetSelSampleByDates(dayofcalendar(2000, 1, 19), dayofcalendar(2021, 11, 22));
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_3()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for EQ( 1)
	decl model = new PcGive();

	model.Load("C:\\Users\\Bruger\\OneDrive - University of Copenhagen\\Polit 2021\\Economics2\\Hand-in-Assignment_4\\Data\\Assignment_4.in7");
	model.Deterministic(-1);

	model.Select("Y", {"st", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("Y", {"st", 1, 5});
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
	model.SetSelSampleByDates(dayofcalendar(2000, 1, 18), dayofcalendar(2021, 11, 22));
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_4()
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

	delete model;
}

main()
{
	run_1();
	run_2();
	run_3();
	run_4();
}
