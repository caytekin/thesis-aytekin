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
import inheritance::ThisChangingType;




private map [inheritanceType, num] countResults(rel [inheritanceKey, inheritanceType] inheritanceResults) {
	map [inheritanceType, num] resultMap = ();
	for ( anInheritanceType <- [INTERNAL_REUSE..(CATEGORY+1)]) {
		int totalOccurrences = size({<child, parent> | <<child, parent>, iType> <- inheritanceResults, iType == anInheritanceType });
		println("<getNameOfInheritanceType(anInheritanceType)>"); iprintln(sort({<child, parent> | <<child, parent>, iType> <- inheritanceResults, iType == anInheritanceType }));
		println();
		resultMap += (anInheritanceType :  totalOccurrences);
	}
	return resultMap;
}



private set [loc] getAllExceptionClasses(rel [loc, loc] allInheritanceRelations) {
	// TODO: At the moment I look only the children of java.lang.Exception or java.lang.Throwable
	// There can be framework types which are exceptions, and the system types which are children of them.
	// May be I can use a name heuristic. 
	set [loc] retSet = {}; 
	set [loc] allExceptionClasses = {_child | <_child, _parent> <- allInheritanceRelations, _parent == THROWABLE_CLASS || _parent == EXCEPTION_CLASS };
	retSet  = allExceptionClasses;
	println("Number of exception classes is: <size(retSet)>");
	return retSet;
}

// return all non-framework (i. e. system) types which are not exceptions
rel [inheritanceKey, inheritanceType] getFilteredInheritanceCases(rel [ inheritanceKey, inheritanceType] allInheritanceCases, rel [loc, loc] allInheritanceRelations, M3 projectM3) {
	rel [inheritanceKey, inheritanceType]retRel = {};
	set [loc] allExceptionClasses = getAllExceptionClasses(allInheritanceRelations);
	set [loc] allTypesOfProject = getAllClassesAndInterfacesInProject(projectM3);
	set [loc] allNonExceptionTypesOfProject = allTypesOfProject - allExceptionClasses;
	retRel = {<<_child,_parent>, _iKey> | <<_child, _parent>, _iKey> <- allInheritanceCases, _child in allNonExceptionTypesOfProject , _parent in allNonExceptionTypesOfProject};
	return retRel;
}


// getExplicitResults filters the inheritanceResults according to  the criteria of the original article:
// they count explicit relations only and they include candidates of external usage and downcall.
// TODO: Review these assumptions when the authors answer the questions
private rel [inheritanceKey, inheritanceType] getExplicitResults (rel [inheritanceKey, inheritanceType] inheritanceResults, M3 projectM3) {
	rel [inheritanceKey, inheritanceType] retRel = {};
	rel [loc, loc] 	extendsOrImplRel = {<_child, _parent> | <_child, _parent> <- projectM3@extends} + {<_child, _parent> | <_child, _parent> <- projectM3@implements};
	rel [inheritanceKey, inheritanceType] explicitFoundInhRels = {<<_child, _parent>, _iType> | <<_child, _parent>, _iType> <- inheritanceResults, <_child, _parent> in extendsOrImplRel};

	rel [inheritanceKey, inheritanceType] allDowncalls = {<<_child, _parent>, DOWNCALL> | <<_child, _parent>, _iType> <- explicitFoundInhRels , _iType == DOWNCALL_ACTUAL || _iType == DOWNCALL_CANDIDATE };
	rel [inheritanceKey, inheritanceType] allExtReuse = {<<_child, _parent>, EXTERNAL_REUSE> | <<_child, _parent>, _iType> <- explicitFoundInhRels , _iType == EXTERNAL_REUSE};
	rel [inheritanceKey, inheritanceType] others =  {<<_child, _parent>, _iType> | <<_child, _parent>, _iType> <- explicitFoundInhRels , 	_iType != DOWNCALL_ACTUAL , _iType != DOWNCALL_CANDIDATE,  
																																			_iType != EXTERNAL_REUSE};
	retRel = others + allDowncalls + allExtReuse;
	return retRel;
}


// getActualresults filters the inheritance results according to our point of view:
// we not only get explicit inheritance relations (defined in the code with extends or impl.) , but also implicit ones (grand children, etc.)
// also, for downcall and expternal reuse, we look at the actual usage (i.e. there is an actual method call) and we exclude candidates, 
// which can have potential downcall and external usage.
private rel [inheritanceKey, inheritanceType] getActualResults (rel [inheritanceKey, inheritanceType] inheritanceResults) {
	rel [inheritanceKey, inheritanceType] retRel = {};
	rel [inheritanceKey, inheritanceType] actualDowncalls = {<<_child, _parent>, DOWNCALL> | <<_child, _parent>, _iType> <- inheritanceResults, _iType == DOWNCALL_ACTUAL};
	rel [inheritanceKey, inheritanceType] actualExtReuse = {<<_child, _parent>, EXTERNAL_REUSE> | <<_child, _parent>, _iType> <- inheritanceResults, _iType == EXTERNAL_REUSE};
	rel [inheritanceKey, inheritanceType] others =  {<<_child, _parent>, _iType> | <<_child, _parent>, _iType> <- inheritanceResults, 	_iType != DOWNCALL_ACTUAL , _iType != DOWNCALL_CANDIDATE,  
																																		_iType != EXTERNAL_REUSE };
	retRel = others + actualDowncalls + actualExtReuse;
	return retRel;
}


num calcPercentage (num nominator, num denominator) {
	num retValue = 0;
	if (denominator != 0) { retValue = nominator / denominator; }
	return retValue;
}



private map [metricsType, num] calculateCCResults(rel [inheritanceKey, inheritanceType] inheritanceResults, rel [loc, loc] inheritanceRelations, M3 projectM3) {
	
	map [metricsType, num] 		CCResultsMap 		= ();
	// filter out CC only
	rel [inheritanceKey, inheritanceType] ccResults = {<<_child, _parent>, iKey> | <<_child, _parent>, iKey> <- inheritanceResults, isClass(_child), isClass(_parent)};
	rel [loc, loc] ccRelations = { <_child, _parent> | <_child, _parent> <- inheritanceRelations, isClass(_child), isClass(_parent)};
	
	// numExplicitCC : Number of explicit user defined cc edges (for the authors), and for me number of user defined (system) edges.

	CCResultsMap += (numExplicitCC: size({<_child, _parent>| <_child, _parent>  <- ccRelations}));			
	
	CCResultsMap += (numCCUsed: size({<_child, _parent> | <<_child, _parent>, _iType> <- ccResults, _iType in {INTERNAL_REUSE, EXTERNAL_REUSE, SUBTYPE} }));
	CCResultsMap += (perCCUsed : calcPercentage(CCResultsMap[numCCUsed], CCResultsMap[numExplicitCC]));
	
	CCResultsMap += (numCCDC : size({<_child, _parent> | <<_child, _parent>, _iType> <- ccResults, _iType == DOWNCALL}));
	CCResultsMap += (perCCDC : calcPercentage(CCResultsMap[numCCDC], CCResultsMap[numExplicitCC]));


	set [inheritanceKey] subtypeRels 			= {<_child, _parent> | <<_child, _parent> , _iType> <- ccResults, _iType == SUBTYPE};
	set [inheritanceKey] exreuseNoSubtypeRels 	= {<_child, _parent> | <<_child, _parent>, _iType> <- ccResults, _iType == EXTERNAL_REUSE} - subtypeRels;
	set [inheritanceKey] usedOnlyInReRels 		= {<_child, _parent> | <<_child, _parent>, _iType> <- ccResults, _iType == INTERNAL_REUSE} - (exreuseNoSubtypeRels + subtypeRels); 
			
	CCResultsMap += (numCCSubtype : size(subtypeRels));	
	CCResultsMap += (perCCSubtype : calcPercentage(CCResultsMap[numCCSubtype], CCResultsMap[numCCUsed]));	
	
	CCResultsMap += (numCCExreuseNoSubtype : size(exreuseNoSubtypeRels) );	
	CCResultsMap += (perCCExreuseNoSubtype : calcPercentage(CCResultsMap[numCCExreuseNoSubtype ], CCResultsMap[numCCUsed]));
	
	CCResultsMap += (numCCUsedOnlyInRe : size(usedOnlyInReRels));
	CCResultsMap += (perCCUsedOnlyInRe : calcPercentage(CCResultsMap[numCCUsedOnlyInRe], CCResultsMap[numCCUsed]));
		
			
	set [inheritanceKey] allButSuper = {<_child, _parent> | <<_child, _parent>, _iType> <- ccResults, _iType in {INTERNAL_REUSE, EXTERNAL_REUSE, SUBTYPE, DOWNCALL, CONSTANT, MARKER, GENERIC, CATEGORY} };
	CCResultsMap += (numCCUnexplSuper: size({<_child, _parent> | <<_child, _parent>, _iType> <- ccResults, _iType == SUPER} - allButSuper));
	CCResultsMap += (perCCUnexplSuper: calcPercentage(CCResultsMap[numCCUnexplSuper], CCResultsMap[numExplicitCC]));
	
	set [inheritanceKey] allButCategory = {<_child, _parent> | <<_child, _parent>, _iType> <- ccResults, _iType in {INTERNAL_REUSE, EXTERNAL_REUSE, SUBTYPE, DOWNCALL, CONSTANT, MARKER, GENERIC, SUPER}};
	CCResultsMap += (numCCUnexplCategory : size( {<_child, _parent> | <<_child, _parent>, _iType> <- ccResults, _iType == CATEGORY}  - allButCategory));
	CCResultsMap += (perCCUnexplCategory: calcPercentage(CCResultsMap[numCCUnexplCategory ], CCResultsMap[numExplicitCC]));

	set [inheritanceKey] allFoundUsages = {<_child, _parent> | <<_child, _parent> , _iType> <- ccResults};
	//println("UNKNOWN RELATIONS LIST: "); iprintln(sort(ccRelations- allFoundUsages));
	CCResultsMap += (numCCUnknown: size(ccRelations- allFoundUsages));
	CCResultsMap += (perCCUnknown: calcPercentage(CCResultsMap[numCCUnknown], CCResultsMap[numExplicitCC]));

	//set [inheritanceKey] allButConstant = {<_child, _parent> | <<_child, _parent>, _iType> <- ccResults, _iType in {INTERNAL_REUSE, EXTERNAL_REUSE, SUBTYPE, DOWNCALL, SUPER, MARKER, GENERIC, CATEGORY} };
	//println("NUMBER OF CONSTANT ONLY CASES IS: <size( {<_child, _parent> | <<_child, _parent>, _iType> <- ccResults, _iType == CONSTANT} - allButConstant )>");
	//iprintln({<_child, _parent> | <<_child, _parent>, _iType> <- ccResults, _iType == CONSTANT} - allButConstant);

	//set [inheritanceKey] allButMarker = {<_child, _parent> | <<_child, _parent>, _iType> <- ccResults, _iType in {INTERNAL_REUSE, EXTERNAL_REUSE, SUBTYPE, DOWNCALL, SUPER, CONSTANT, GENERIC, CATEGORY} };
	//println("NUMBER OF MARKER CASES IS: <size( {<_child, _parent> | <<_child, _parent>, _iType> <- ccResults, _iType == MARKER} - allButMarker )>");

	//set [inheritanceKey] allButGeneric = {<_child, _parent> | <<_child, _parent>, _iType> <- ccResults, _iType in {INTERNAL_REUSE, EXTERNAL_REUSE, SUBTYPE, DOWNCALL, SUPER, MARKER, CONSTANT, CATEGORY} };
	//println("NUMBER OF GENERIC CASES IS: <size( {<_child, _parent> | <<_child, _parent>, _iType> <- ccResults, _iType == GENERIC} - allButGeneric )>");

	println("CC UNKNOWN: ");
	iprintln({<<_child, _parent>, _iType> | <<_child, _parent>, _iType> <- ccResults, _iType notin {INTERNAL_REUSE, EXTERNAL_REUSE, SUBTYPE, DOWNCALL, CONSTANT, MARKER, GENERIC, SUPER, CATEGORY}});

	return CCResultsMap;
}


private void printCCResults(map [metricsType, num]  CCMetricResults, M3 projectM3) {
	println("RESULTS FOR CC EDGES:");
	iprintln(CCMetricResults);
	println("------------------------------------------------");	
	for ( aCCMetric <- [numExplicitCC..perCCUnknown+1]) {
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



public void runIt() {
	rel [inheritanceKey, int] allInheritanceCases = {};	
	println("Date: <printDate(now())>");
	println("Creating M3....");
	loc projectLoc = |project://jrat_0.6|;
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
	allInheritanceCases += getSubtypeCases(projectM3);	
	println("Subtype cases are done at <printTime(now())>...");	
	
	println("Starting with this changing type cases at: <printTime(now())> ");
	allInheritanceCases += getThisChangingTypeOccurrences(projectM3);
	println("This changing type cases are done at: <printTime(now())> ");
	
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
	rel [inheritanceKey, inheritanceType] filteredInheritanceCases = getFilteredInheritanceCases(allInheritanceCases, allInheritanceRelations, projectM3);

	rel [inheritanceKey, inheritanceType] explicitResults = getExplicitResults(filteredInheritanceCases, projectM3);
	rel [inheritanceKey, inheritanceType] actualResults = getActualResults(filteredInheritanceCases);	
	
	rel [loc, loc] systemInhRelations = getNonFrameworkInheritanceRels(allInheritanceRelations, projectM3);
	
	rel [loc, loc] explicitInhRelations = getExplicitInhRelations(systemInhRelations, projectM3);

	map [metricsType, num] explicitCCMetricResults = calculateCCResults(explicitResults, explicitInhRelations, projectM3);
	println("EXPLICIT RESULTS - EXPLICIT AND CANDIDATES");
	printCCResults(explicitCCMetricResults, projectM3);
	
	map [metricsType, num] actualCCMetricResults = calculateCCResults(actualResults, systemInhRelations, projectM3);
	println("ACTUAL RESULTS - ALL RELATIONS AND ACTUALS");
	printCCResults(actualCCMetricResults, projectM3);
	
	
	//println("CONSTANTS:");
	//iprintln(sort({<_child, _parent> | <<_child, _parent>, _iType> <- allInheritanceCases, _iType == CONSTANT }));
	//
	//println("MARKER:");
	//iprintln(sort({<_child, _parent> | <<_child, _parent>, _iType> <- allInheritanceCases, _iType == MARKER }));
	//

	//println("GENERIC:");
	//iprintln(sort({<_child, _parent> | <<_child, _parent>, _iType> <- allInheritanceCases, _iType == GENERIC }));

	//println("SUPER:");
	//iprintln(sort({<_child, _parent> | <<_child, _parent>, _iType> <- allInheritanceCases, _iType == SUPER }));

	//println("CATEGORY:");
	//iprintln(sort({<_child, _parent> | <<_child, _parent>, _iType> <- allInheritanceCases, _iType == CATEGORY }));
	
	println("INTERNAL REUSE:");
	iprintln(sort({<_child, _parent> | <<_child, _parent>, _iType> <- allInheritanceCases, _iType == INTERNAL_REUSE }));

	println("EXTERNAL REUSE:");
	iprintln(sort({<_child, _parent> | <<_child, _parent>, _iType> <- allInheritanceCases, _iType == EXTERNAL_REUSE}));


	//printLog(categoryLogFile, "CATEGORY LOG: ");
	//printLog(genericLogFile, "GENERIC LOG:");
	printLog(subtypeLogFile, "SUBTYPE LOG");
	printLog(internalReuseLogFile, "INTERNAL REUSE LOG");
	printLog(externalReuseLogFile, "EXTERNAL REUSE LOG");
	printLog(thisChangingTypeCandFile, "THIS CHANGING TYPE CANDIDATES:");
	printLog(thisChangingTypeOccurFile, "THIS CHANGING TYPE OCCURRENCES:");	
	//printLog(internalReuseLogFile, "INTERNAL REUSE LOG");
	printLog(downcallLogFile, "DOWNCALL LOG");
	//printLog(superLogFile, "SUPER LOG:");
	
	
}

