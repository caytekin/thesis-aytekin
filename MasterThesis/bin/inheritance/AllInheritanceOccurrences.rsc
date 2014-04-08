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






private map [inheritanceType, num] countResults(rel [inheritanceKey, inheritanceType] inheritanceResults) {
	map [inheritanceType, num] resultMap = ();
	for ( anInheritanceType <- [INTERNAL_REUSE..(CATEGORY+1)]) {
		int totalOccurrences = size({<child, parent> | <<child, parent>, iType> <- inheritanceResults, iType == anInheritanceType });
		resultMap += (anInheritanceType :  totalOccurrences);
	}
	return resultMap;
}


private set [loc] filterExceptions(set [loc] allClasses, rel [loc, loc] allInheritanceRelations) {
	set [loc] retSet = {}; 
	set [loc] allExceptionClasses = {_child | <_child, _parent> <- allInheritanceRelations, _parent == THROWABLE_CLASS };
	retSet  = allClasses - allExceptionClasses;
	return retSet;
}


private map [metricsType, num] calculateCCResults(rel [inheritanceKey, inheritanceType] inheritanceResults, rel [loc, loc] allInheritanceRelations, M3 projectM3) {
	// TODO : For all statistics, think about DOWNCALL_CANDIDATE and EXTERNAL_REUSE_CANDIDATE cases !!!
	// if you are going to count them, then count them otherwise get rid of them !!!
	// VERY IMPORTANT TODO !!!!
	map [metricsType, num] 		CCResultsMap 		= ();
	set [loc] 					notFilteredSysClasses = getAllClassesInProject(projectM3);
	set [loc] 					allSystemClasses 	= filterExceptions(notFilteredSysClasses, allInheritanceRelations);
	rel [loc, loc] 				extendsRel 			= {<_child, _parent> | <_child, _parent> <- projectM3@extends, isClass(_child), isClass(_parent)};
	rel [inheritanceKey, inheritanceType] explicitFoundInhRels = {<<_child, _parent>, _iType> | <<_child, _parent>, _iType> <- inheritanceResults, <_child, _parent> in extendsRel, _child in allSystemClasses, _parent in allSystemClasses };

	set [inheritanceKey] explicitDefinedInhRels 	= {<_child, _parent> |<_child, _parent> <- extendsRel, _child in allSystemClasses, _parent in allSystemClasses};
	CCResultsMap += (nExplicitCC: size(explicitDefinedInhRels));			
	
	CCResultsMap += (nCCUsed: size({<_child, _parent> | <<_child, _parent>, _iType> <- explicitFoundInhRels, _iType in {INTERNAL_REUSE, EXTERNAL_REUSE_ACTUAL, SUBTYPE} }));
	CCResultsMap += (nCCDC : size({<_child, _parent> | <<_child, _parent>, _iType> <- explicitFoundInhRels, _iType == DOWNCALL_ACTUAL}));

	set [inheritanceKey] subtypeRels 			= {<_child, _parent> | <<_child, _parent> , _iType> <- explicitFoundInhRels, _iType == SUBTYPE};
	set [inheritanceKey] exreuseNoSubtypeRels 	= {<_child, _parent> | <<_child, _parent>, _iType> <- explicitFoundInhRels, _iType == EXTERNAL_REUSE_ACTUAL} - subtypeRels;
	set [inheritanceKey] usedOnlyInReRels 		= {<_child, _parent> | <<_child, _parent>, _iType> <- explicitFoundInhRels, _iType == INTERNAL_REUSE} - (exreuseNoSubtypeRels + subtypeRels); 
			
	CCResultsMap += (nCCSubtype : size(subtypeRels));	
	CCResultsMap += (nCCExreuseNoSubtype : size(exreuseNoSubtypeRels) );	
	CCResultsMap += (nCCUsedOnlyInRe : size(usedOnlyInReRels));
	
			
	set [inheritanceKey] allButSuper = {<_child, _parent> | <<_child, _parent>, _iType> <- explicitFoundInhRels, _iType in {INTERNAL_REUSE, EXTERNAL_REUSE_ACTUAL, SUBTYPE, DOWNCALL_ACTUAL, CONSTANT, MARKER, GENERIC, CATEGORY} };
	CCResultsMap += (nCCUnexplSuper: size({<_child, _parent> | <<_child, _parent>, _iType> <- explicitFoundInhRels, _iType == SUPER} - allButSuper));

	//println("SUPER RELATIONSHIP"); iprintln(sort({<_child, _parent> | <<_child, _parent>, _iType> <- explicitFoundInhRels, _iType == SUPER} - allButSuper));

	set [inheritanceKey] allButCategory = {<_child, _parent> | <<_child, _parent>, _iType> <- explicitFoundInhRels, _iType in {INTERNAL_REUSE, EXTERNAL_REUSE_ACTUAL, SUBTYPE, DOWNCALL_ACTUAL, CONSTANT, MARKER, GENERIC, SUPER}};
	
	CCResultsMap += (nCCUnExplCategory : size( {<_child, _parent> | <<_child, _parent>, _iType> <- explicitFoundInhRels, _iType == CATEGORY}  - allButCategory));

	set [inheritanceKey] allFoundUsages = {<_child, _parent> | <<_child, _parent> , _iType> <- explicitFoundInhRels};
	CCResultsMap += (nCCUnknown: size(explicitDefinedInhRels - allFoundUsages));


	set [inheritanceKey] allButConstant = {<_child, _parent> | <<_child, _parent>, _iType> <- explicitFoundInhRels, _iType in {INTERNAL_REUSE, EXTERNAL_REUSE_ACTUAL, SUBTYPE, DOWNCALL_ACTUAL, SUPER, MARKER, GENERIC, CATEGORY} };
	println("NUMBER OF CONSTANT ONLY CASES IS: <size( {<_child, _parent> | <<_child, _parent>, _iType> <- explicitFoundInhRels, _iType == CONSTANT} - allButConstant )>");
	iprintln({<_child, _parent> | <<_child, _parent>, _iType> <- explicitFoundInhRels, _iType == CONSTANT} - allButConstant);

	set [inheritanceKey] allButMarker = {<_child, _parent> | <<_child, _parent>, _iType> <- explicitFoundInhRels, _iType in {INTERNAL_REUSE, EXTERNAL_REUSE_ACTUAL, SUBTYPE, DOWNCALL_ACTUAL, SUPER, CONSTANT, GENERIC, CATEGORY} };
	println("NUMBER OF MARKER CASES IS: <size( {<_child, _parent> | <<_child, _parent>, _iType> <- explicitFoundInhRels, _iType == MARKER} - allButMarker )>");

	set [inheritanceKey] allButGeneric = {<_child, _parent> | <<_child, _parent>, _iType> <- explicitFoundInhRels, _iType in {INTERNAL_REUSE, EXTERNAL_REUSE_ACTUAL, SUBTYPE, DOWNCALL_ACTUAL, SUPER, MARKER, CONSTANT, CATEGORY} };
	println("NUMBER OF GENERIC CASES IS: <size( {<_child, _parent> | <<_child, _parent>, _iType> <- explicitFoundInhRels, _iType == GENERIC} - allButGeneric )>");



	//println("CC UNKNOWN: ");
	//iprintln({<_child, _parent> | <<_child, _parent>, _iType> <- explicitFoundInhRels, _iType notin {INTERNAL_REUSE, EXTERNAL_REUSE_ACTUAL, SUBTYPE, DOWNCALL_ACTUAL, CONSTANT, MARKER, GENERIC, SUPER, CATEGORY}});
	return CCResultsMap;
}


private void printCCResults(map [metricsType, num]  CCMetricResults, M3 projectM3) {
	println("RESULTS FOR CC EDGES:");
	iprintln(CCMetricResults);
	println("------------------------------------------------");	
	for ( aCCMetric <- [nExplicitCC..nCCUnknown+1]) {
		println("<getNameOfInheritanceMetric(aCCMetric)> 	: <CCMetricResults[aCCMetric]>");
	}
	println();
}


private void printResults(map[inheritanceType, num] totals ) {
	for ( anInheritanceType <- [INTERNAL_REUSE..(CATEGORY+1)]) {
		println("NUMBER OF <getNameOfInheritanceType(anInheritanceType)> CASES: <totals[anInheritanceType]>");
	}
	println();
}


private void printProportions(rel [inheritanceKey, inheritanceType] inheritanceResults, map[inheritanceType, num] totals ){
	iprintln(<totals>);
	println("DOWNCALL PROPORTION: <(totals[DOWNCALL_ACTUAL])/(totals[NONFRAMEWORK_CC])>");
	println("SUBTYPE PROPORTION: <totals[SUBTYPE]/( totals[NONFRAMEWORK_CC] + totals[NONFRAMEWORK_CI] + totals[NONFRAMEWORK_II])>");
	set [inheritanceKey] subtypeCases = {iKey | <iKey, iType> <- inheritanceResults, iType == SUBTYPE};
	set [inheritanceKey] externalNotSubtype = {iKey | <iKey, iType> <- inheritanceResults, iType == EXTERNAL_REUSE_ACTUAL, iKey notin subtypeCases };
	set [inheritanceKey] externalOrSubtype = subtypeCases + externalNotSubtype;
	set [inheritanceKey] internalOnly = {iKey | <iKey, iType> <- inheritanceResults, iType == INTERNAL_REUSE, iKey notin externalOrSubtype};
	println("PROPORTION OF EDGES THAT ARE EXTERNAL REUSE BUT NOT SUBTYPE: <size(externalNotSubtype)/totals[NONFRAMEWORK_CC]>");
	println("PROPORTION OF EDGES THAT ARE INTERNAL REUSE ONLY: <size(internalOnly)/totals[NONFRAMEWORK_CC]>");	
	// TODO: Do not forget to handle divide by zero.
}


public void runIt() {
	rel [inheritanceKey, int] allInheritanceCases = {};	
	println("Creating M3....");
	loc projectLoc = |project://VerySmallProject|;
	M3 projectM3 = createM3FromEclipseProject(projectLoc);
	println("Created M3....for <projectLoc>");
	rel [loc, loc] allInheritanceRelations = getInheritanceRelations(projectM3);

	println("Starting with internal reuse cases at: <printTime(now())> ");
	allInheritanceCases += getInternalReuseCases(projectM3);
	println("Internal use cases are done...<printTime(now())>");
	
	println("Starting with external reuse cases at: <printTime(now())> ");
	allInheritanceCases += getExternalReuseCases(projectM3);	
	println("External use cases are done at <printTime(now())>...");	
	
	
	println("Starting with subtype cases at: <printTime(now())> ");
	// TODO: DO NOT FORGET TO PUT "this changing type" analysis in getSubtypeCases()
	allInheritanceCases += getSubtypeCases(projectM3);	
	println("Subtype cases are done at <printTime(now())>...");	
	
	
	println("Starting with downcall cases at: <printTime(now())> ");
	allInheritanceCases += getDowncallOccurrences(projectM3);	
	println("Downcall cases are done at <printTime(now())>...");	

	println("Starting with other cases at: <printTime(now())> ");
	allInheritanceCases += getOtherInheritanceCases(projectM3);	
	println("Other cases are done at <printTime(now())>...");	

	println("Starting with category cases at : <printTime(now())> ");
	allInheritanceCases += getCategoryCases(allInheritanceCases, projectM3);
	println("Category cases are done at : <printTime(now())> ");

	printResults(countResults(allInheritanceCases));

	map [metricsType, num] CCMetricResults = calculateCCResults(allInheritanceCases, allInheritanceRelations, projectM3);
	printCCResults(CCMetricResults, projectM3);
	
	
	//printProportions(allInheritanceCases, totals);
	printLog(subtypeLogFile, "SUBTYPE LOG");
	//printLog(externalReuseLogFile, "EXTERNAL REUSE LOG");
}

