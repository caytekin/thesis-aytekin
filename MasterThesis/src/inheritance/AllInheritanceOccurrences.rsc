module inheritance::AllInheritanceOccurrences


import IO;
import Map;
import Set;
import Relation;
import List;
import ListRelation;
import DateTime;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import inheritance::InheritanceDataTypes;
import inheritance::InheritanceModules;
import inheritance::InternalReuse;
import inheritance::ExternalReuse;
import inheritance::SubtypeInheritance;
import inheritance::DowncallCases;
import inheritance::OtherInheritanceCases;





// TODO: introduce log mechanism





private rel [inheritanceKey, inheritanceType] getCC_CI_II_NonFR_Relations (rel [loc child, loc parent] inheritRelation, M3 projectM3) {
	rel [inheritanceKey, inheritanceType] CC_CI_II_NonFR_Relations = {};
	set [loc] allClassesAndInterfacesInProject = getAllClassesAndInterfacesInProject(projectM3);
	set [inheritanceKey] allInheritanceRels = getInheritanceRelations(projectM3);
	CC_CI_II_NonFR_Relations += {<<child, parent>, CLASS_CLASS> | <child, parent> <- inheritRelation, isClass(child), isClass(parent)};
	CC_CI_II_NonFR_Relations += {<<child, parent>, CLASS_INTERFACE> | <child, parent> <- inheritRelation, isClass(child), isInterface(parent)};
	CC_CI_II_NonFR_Relations += {<<child, parent>, INTERFACE_INTERFACE> | <child, parent> <- inheritRelation, isInterface(child), isInterface(parent)};
	CC_CI_II_NonFR_Relations += {<<child, parent>, NONFRAMEWORK_CC> | <child, parent> <- inheritRelation, isClass(child), isClass(parent), parent in allClassesAndInterfacesInProject};
	CC_CI_II_NonFR_Relations += {<<child, parent>, NONFRAMEWORK_CI> | <child, parent> <- inheritRelation, isClass(child), isInterface(parent), parent in allClassesAndInterfacesInProject};
	CC_CI_II_NonFR_Relations += {<<child, parent>, NONFRAMEWORK_II> | <child, parent> <- inheritRelation, isInterface(child), isInterface(parent), parent in allClassesAndInterfacesInProject};
	return CC_CI_II_NonFR_Relations;
}


private map [inheritanceType, num] countResults(rel [inheritanceKey, inheritanceType] inheritanceResults) {
	map [inheritanceType, num] resultMap = ();
	for ( anInheritanceType <- [INTERNAL_REUSE..(NONFRAMEWORK_II+1)]) {
		int totalOccurrences = size({<child, parent> | <<child, parent>, iType> <- inheritanceResults, iType == anInheritanceType });
		resultMap += (anInheritanceType :  totalOccurrences);
	}
	return resultMap;
}


private void printFrameworkCases(rel [inheritanceKey, inheritanceType] inheritanceResults) {
	int totalCC_CI_II_edges = size({<iKey, iType> | <iKey, iType> <- inheritanceResults, iType in [CLASS_CLASS, CLASS_INTERFACE, INTERFACE_INTERFACE]});
	int totalNonFramework_CC_CI_II_edges = size({<iKey, iType> | <iKey, iType> <- inheritanceResults, iType in [NONFRAMEWORK_CC, NONFRAMEWORK_CI, NONFRAMEWORK_II]});
	println("NUMBER OF FRAMEWORK CASES: <totalCC_CI_II_edges - totalNonFramework_CC_CI_II_edges> ");
}



private void printResults(rel [inheritanceKey, inheritanceType] inheritanceResults, map[inheritanceType, num] totals ) {

	for ( anInheritanceType <- [INTERNAL_REUSE..(NONFRAMEWORK_II+1)]) {
		println("NUMBER OF <getNameOfInheritanceType(anInheritanceType)> CASES: <totals[anInheritanceType]>");
	}
	
	printFrameworkCases(inheritanceResults);

	println("LIST OF DIFFERENT INHERITANCE RELATIONS:");
	for ( anInheritanceType <- [INTERNAL_REUSE..(NONFRAMEWORK_II+1)]) {
		print("<getNameOfInheritanceType(anInheritanceType)> CASES:");
		iprintln(sort({inhItem | <inhItem, inhType> <- inheritanceResults, inhType == anInheritanceType}));
	}
}


private void printProportions(rel [inheritanceKey, inheritanceType] inheritanceResults, map[inheritanceType, num] totals ){
	iprintln(<totals>);
	println("DOWNCALL PROPORTION: <(totals[DOWNCALL])/(totals[NONFRAMEWORK_CC])>");
	println("SUBTYPE PROPORTION: <totals[SUBTYPE]/( totals[NONFRAMEWORK_CC] + totals[NONFRAMEWORK_CI] + totals[NONFRAMEWORK_II])>");
	set [inheritanceKey] subtypeCases = {iKey | <iKey, iType> <- inheritanceResults, iType == SUBTYPE};
	set [inheritanceKey] externalNotSubtype = {iKey | <iKey, iType> <- inheritanceResults, iType == EXTERNAL_REUSE, iKey notin subtypeCases };
	set [inheritanceKey] externalOrSubtype = subtypeCases + externalNotSubtype;
	set [inheritanceKey] internalOnly = {iKey | <iKey, iType> <- inheritanceResults, iType == INTERNAL_REUSE, iKey notin externalOrSubtype};
	println("PROPORTION OF EDGES THAT ARE EXTERNAL REUSE BUT NOT SUBTYPE: <size(externalNotSubtype)/totals[NONFRAMEWORK_CC]>");
	println("PROPORTION OF EDGES THAT ARE INTERNAL REUSE ONLY: <size(internalOnly)/totals[NONFRAMEWORK_CC]>");	
	// TODO: Do not forget to handle divide by zero.
}


public void runIt() {
	rel [inheritanceKey, int] allInheritanceCases;	
	println("Creating M3....");
	M3 projectM3 = createM3FromEclipseProject(|project://SmallSQL|);
	println("Created M3....");
	rel [loc, loc] allInheritanceRelations = getInheritanceRelations(projectM3);
	allInheritanceCases = getCC_CI_II_NonFR_Relations (allInheritanceRelations, projectM3);

	println("Starting with internal reuse cases at: <printTime(now())> ");
	allInheritanceCases += getInternalReuseCases(projectM3);
	println("Internal use cases are done...");
	
	println("Starting with external reuse cases at: <printTime(now())> ");
	allInheritanceCases += getExternalReuseCases(projectM3);	
	println("External use cases are done at <printTime(now())>...");	
	
	
	println("Starting with subtype cases at: <printTime(now())> ");
	allInheritanceCases += getSubtypeCases(projectM3);	
	println("Subtype cases are done at <printTime(now())>...");	
	
	
	println("Starting with downcall cases at: <printTime(now())> ");
	allInheritanceCases += getDowncallOccurrences(projectM3);	
	println("Downcall cases are done at <printTime(now())>...");	

	println("Starting with other cases at: <printTime(now())> ");
	allInheritanceCases += getOtherInheritanceCases(projectM3);	
	println("Other cases are done at <printTime(now())>...");	

	map [inheritanceType, num] totals = countResults(allInheritanceCases);
	printResults(allInheritanceCases, totals);
	
	printProportions(allInheritanceCases, totals);
	//printLog(superLogFile, "SUPER LOG");
}

