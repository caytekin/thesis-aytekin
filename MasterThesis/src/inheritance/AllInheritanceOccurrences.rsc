module inheritance::AllInheritanceOccurrences


import IO;
import Map;
import Set;
import Relation;
import List;
import ListRelation;
import DateTime;
import util::Math;

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
	for ( anInheritanceType <- [INTERNAL_REUSE..(FRAMEWORK+1)]) {
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


// return all types which are not exceptions // changed 26June2014, look here later TODO TODO TODO 
rel [inheritanceKey, inheritanceType] getFilteredInheritanceCases(rel [ inheritanceKey, inheritanceType] allInheritanceCases, rel [loc, loc] allInheritanceRelations, M3 projectM3) {
	rel [inheritanceKey, inheritanceType]retRel = {};
	set [loc] allExceptionClasses = getAllExceptionClasses(allInheritanceRelations);
	retRel = {<<_child,_parent>, _iKey> | <<_child, _parent>, _iKey> <- allInheritanceCases, _child notin allExceptionClasses , _parent notin allExceptionClasses};
	return retRel;
}





private map [metricsType, num] calculateSubtypeIndirectPercentages(rel [inheritanceKey, inheritanceType] explicitFoundInhrels, rel [inheritanceKey, inheritanceType]  addedImplicitRels) {
	map [metricsType, num] addedResultsMap = ();
	addedResultsMap += (perAddedCCSubtype : getPercentageAdded(explicitFoundInhrels, addedImplicitRels, SUBTYPE, "java+class", "java+class"));
	addedResultsMap += (perAddedCISubtype : getPercentageAdded(explicitFoundInhrels, addedImplicitRels, SUBTYPE, "java+class", "java+interface"));
	addedResultsMap += (perAddedIISubtype : getPercentageAdded(explicitFoundInhrels, addedImplicitRels, SUBTYPE, "java+interface", "java+interface"));
	for (aMetric <- [perAddedCCSubtype, perAddedCISubtype, perAddedIISubtype]) {
		println("<getNameOfInheritanceMetric(aMetric)> : <addedResultsMap[aMetric]>");
	}
	return addedResultsMap;
}


private rel [inheritanceKey, inheritanceType] getResultsOfImplicitUsage(rel [inheritanceKey, inheritanceType] implicitFoundInhrels, M3 projectM3) {
	// the authors wrote an answer about the following: for three types G, C, P (G extends C, C extends P), if there is a reuse (internal or external), 
	// subtype or a downcall between G and P, the edge G and P does not get listed, because the edge G-> P is not explicit, however, the edge between 
	//  G and C will get the same attribute (reuse, subtype or downcall), because it is explicit.
	rel [inheritanceKey, inheritanceType] retRel = {};
	rel [inheritanceKey, inheritanceType] selectedOccurrences = {<<_child, _parent>, _iType> | <<_child, _parent>, _iType> <- implicitFoundInhrels, _iType == EXTERNAL_REUSE || _iType == SUBTYPE };
	rel [inheritanceKey, inheritanceType, loc] addedInhOccLog = {};
	map[loc, set[loc]] 	extendsMap 		= toMap({<_child, _parent> | <_child, _parent> <- projectM3@extends});
	map[loc, set[loc]] 	implementsMap 	= toMap({<_child, _parent> | <_child, _parent> <- projectM3@implements});
	rel [loc, loc] 		allInheritanceRelations 	= getInheritanceRelations(projectM3);
	//println("--------------------------getResultsOfImplicitUsage----------------------");
	//iprintln(sort(selectedOccurrences));
	//println("--------------------------getResultsOfImplicitUsage----------------------");	
	loc immediateParent = DEFAULT_LOC;
	for ( <<_child, _parent>, _iType> <- sort(selectedOccurrences)) {
		immediateParent = getImmediateParentGivenAnAsc(_child, _parent, extendsMap, implementsMap, allInheritanceRelations); 
		if (immediateParent != DEFAULT_LOC) {
			addedInhOccLog += <<_child, immediateParent>, _iType, _parent>; 
		}
	}  // for														
	retRel = {<<_child, _immediateParent>, _iType> | <<_child, _immediateParent>, _iType, _parent><- addedInhOccLog};	
	iprintToFile(getFilename(projectM3.id,addedRelsLogFile),addedInhOccLog );						
	return retRel;
}




// getExplicitResults filters the inheritanceResults according to  the criteria of the original article:
// they count explicit relations only and they include candidates of downcall.
private rel [inheritanceKey, inheritanceType] getExplicitResults (rel [inheritanceKey, inheritanceType] inheritanceResults, M3 projectM3) {
	rel [inheritanceKey, inheritanceType] retRel = {};
	rel [inheritanceKey, inheritanceType] allOccurrences = {};	
	set [loc] systemTypes = getAllClassesAndInterfacesInProject(projectM3);
	rel [loc, loc] 	extendsOrImplRel = {<_child, _parent> | <_child, _parent> <- projectM3@extends} + {<_child, _parent> | <_child, _parent> <- projectM3@implements};
	rel [inheritanceKey, inheritanceType] allDowncalls = {<<_child, _parent>, DOWNCALL> | <<_child, _parent>, _iType> <- inheritanceResults, _iType == DOWNCALL_ACTUAL || _iType == DOWNCALL_CANDIDATE };
	rel [inheritanceKey, inheritanceType] allOthers =  {<<_child, _parent>, _iType> | <<_child, _parent>, _iType> <- inheritanceResults , _iType != DOWNCALL_ACTUAL , _iType != DOWNCALL_CANDIDATE};

	allOccurrences = allOthers + allDowncalls;
	rel [inheritanceKey, inheritanceType] explicitFoundInhRels = {<<_child, _parent>, _iType> | <<_child, _parent>, _iType> <- allOccurrences, <_child, _parent> in extendsOrImplRel};	
	rel [inheritanceKey, inheritanceType] implicitFoundInhRels = allOccurrences - explicitFoundInhRels;
	//println("---------------------------------------------");
	//println("ALL OCCURRENCES");
	//iprintln(sort(allOccurrences));
	//println("EXPLICIT RESULTS");
	//iprintln(sort(explicitFoundInhRels ));
	//println("IMPLICIT  RESULTS");
	//iprintln(sort(implicitFoundInhRels ));
	rel [inheritanceKey, inheritanceType] addedImplicitRels = getResultsOfImplicitUsage(implicitFoundInhRels, projectM3);
	rel [inheritanceKey, inheritanceType] allResults = explicitFoundInhRels + addedImplicitRels;
	calculateSubtypeIndirectPercentages(explicitFoundInhRels, addedImplicitRels);
	println("ALL RESULTS -------------------------------------------------------------------");
	iprintln(sort(allResults));
	println("-------------------------------------------------------------------"); println();
	retRel = {<<_child, _parent>, _iType> | <<_child, _parent>, _iType> <- allResults, _child in systemTypes, _parent in systemTypes};
	println("Non-system results are taken out: ");
	iprintln(sort(retRel));
	println("-------------------------------------------------------------------"); println();
	return retRel;
}



num calcPercentage (num nominator, num denominator) {
	num retValue = 0;
	if (denominator != 0) { retValue = nominator / denominator; }
	return retValue;
}



private map [metricsType, num] calculateIIResults(rel [inheritanceKey, inheritanceType] inheritanceResults, rel [loc, loc] inheritanceRelations, M3 projectM3) {
	map [metricsType, num] IIResultsMap = ();

	rel [inheritanceKey, inheritanceType] iiResults = {<<_child, _parent>, iKey> | <<_child, _parent>, iKey> <- inheritanceResults, isInterface(_child), isInterface(_parent)};
	rel [loc, loc] iiRelations = { <_child, _parent> | <_child, _parent> <- inheritanceRelations, isInterface(_child), isInterface(_parent)};

	IIResultsMap += (numExplicitII: size({<_child, _parent>| <_child, _parent>  <- iiRelations}));			

	set [inheritanceKey] subtypeRels 			= {<_child, _parent> | <<_child, _parent> , _iType> <- iiResults, _iType == SUBTYPE};
	IIResultsMap += (numIISubtype : size(subtypeRels));	
	IIResultsMap += (perIISubtype : calcPercentage(IIResultsMap[numIISubtype ], IIResultsMap[numExplicitII]));	

	set [inheritanceKey] onlyReuse	= {<_child, _parent> | <<_child, _parent> , _iType> <- iiResults, _iType == EXTERNAL_REUSE } - subtypeRels;
	IIResultsMap += (numOnlyIIReuse : size(onlyReuse));	
	IIResultsMap += (perOnlyIIReuse : calcPercentage(IIResultsMap[numOnlyIIReuse ], IIResultsMap[numExplicitII]));	


	set [inheritanceKey] explainedIIRels = {<_child, _parent> | <<_child, _parent> , _iType> <- iiResults, _iType in {FRAMEWORK, GENERIC, MARKER, CONSTANT }};
	IIResultsMap += (numExplainedII : size(explainedIIRels - (subtypeRels + onlyReuse)));
	IIResultsMap += (perExplainedII : calcPercentage(IIResultsMap[numExplainedII], IIResultsMap[numExplicitII]));

	set [inheritanceKey] categoryIIRels = {<_child, _parent> | <<_child, _parent> , _iType> <- iiResults, _iType == CATEGORY};
	IIResultsMap += (numCategoryExplII: size(categoryIIRels - (explainedIIRels + subtypeRels + onlyReuse)));
	IIResultsMap += (perCategoryExplII: calcPercentage(IIResultsMap[numCategoryExplII], IIResultsMap[numExplicitII]));
	
	set [inheritanceKey] allFoundUsages = {<_child, _parent> | <<_child, _parent> , _iType> <- iiResults};
	IIResultsMap += (numUnexplainedII : size(iiRelations - allFoundUsages));
	IIResultsMap += (perUnexplainedII : calcPercentage(IIResultsMap[numUnexplainedII], IIResultsMap[numExplicitII]));	

	printResultSummaryToFile(iiResults, projectM3);


	return IIResultsMap;	
}

private void printIIResults(map [metricsType, num]  IIMetricResults, M3 projectM3) {
	println("RESULTS FOR II EDGES:");
	println("------------------------------------------------");	
	for ( anIIMetric <- [numExplicitII..perUnexplainedII + 1]) {
		println("<getNameOfInheritanceMetric(anIIMetric)> 	: <IIMetricResults[anIIMetric]>");
		appendToFile(getFilename(projectM3.id,resultsFile), "<IIMetricResults[anIIMetric]>\t" );
	}
	println();
}



private map [metricsType, num] calculateCIResults(rel [inheritanceKey, inheritanceType] inheritanceResults, rel [loc, loc] inheritanceRelations, M3 projectM3) {
	map [metricsType, num] CIResultsMap = ();

	rel [inheritanceKey, inheritanceType] ciResults = {<<_child, _parent>, iKey> | <<_child, _parent>, iKey> <- inheritanceResults, isClass(_child), isInterface(_parent)};
	rel [loc, loc] ciRelations = { <_child, _parent> | <_child, _parent> <- inheritanceRelations, isClass(_child), isInterface(_parent)};

	CIResultsMap += (numExplicitCI: size({<_child, _parent>| <_child, _parent>  <- ciRelations}));			

	set [inheritanceKey] subtypeRels 			= {<_child, _parent> | <<_child, _parent> , _iType> <- ciResults, _iType == SUBTYPE};
	CIResultsMap += (numOnlyCISubtype : size(subtypeRels));	
	CIResultsMap += (perOnlyCISubtype: calcPercentage(CIResultsMap[numOnlyCISubtype], CIResultsMap[numExplicitCI]));	

	set [inheritanceKey] explainedCIRels = {<_child, _parent> | <<_child, _parent> , _iType> <- ciResults, _iType in {FRAMEWORK, GENERIC, MARKER, CONSTANT, EXTERNAL_REUSE }};
	CIResultsMap += (numExplainedCI : size(explainedCIRels - subtypeRels));
	CIResultsMap += (perExplainedCI : calcPercentage(CIResultsMap[numExplainedCI], CIResultsMap[numExplicitCI]));

	set [inheritanceKey] categoryCIRels = {<_child, _parent> | <<_child, _parent> , _iType> <- ciResults, _iType == CATEGORY};
	CIResultsMap += (numCategoryExplCI: size(categoryCIRels - (explainedCIRels + subtypeRels)));
	CIResultsMap += (perCategoryExplCI: calcPercentage(CIResultsMap[numCategoryExplCI], CIResultsMap[numExplicitCI]));
	
	set [inheritanceKey] allFoundUsages = {<_child, _parent> | <<_child, _parent> , _iType> <- ciResults};
	CIResultsMap += (numUnexplainedCI : size(ciRelations - allFoundUsages));
	CIResultsMap += (perUnexplainedCI : calcPercentage(CIResultsMap[numUnexplainedCI], CIResultsMap[numExplicitCI]));	

	printResultSummaryToFile(ciResults, projectM3);

	return CIResultsMap;	
}


private void printCIResults(map [metricsType, num]  CIMetricResults, M3 projectM3) {
	println("RESULTS FOR CI EDGES:");
	println("------------------------------------------------");	
	for ( aCIMetric <- [numExplicitCI..perUnexplainedCI + 1]) {
		println("<getNameOfInheritanceMetric(aCIMetric)> 	: <CIMetricResults[aCIMetric]>");
		appendToFile(getFilename(projectM3.id,resultsFile), "<CIMetricResults[aCIMetric]>\t" );
	}
	println();
}


private void printResultSummaryToFile(rel [inheritanceKey, inheritanceType] resultSummary, M3 projectM3) {
	loc ccFile = getFilename(projectM3.id, resultSummaryFile);
	lrel [loc, loc] resultRel = [];
	for (anInhType <- [INTERNAL_REUSE..DOWNCALL+1]) {
		resultRel = sort({<_child, _parent> | <<_child, _parent>, _iType> <- resultSummary, _iType == anInhType });
		appendToFile(ccFile, "<getNameOfInheritanceType(anInhType)> TOTAL: <size(resultRel)> \n");
		for (aResult <- resultRel) {
			appendToFile(ccFile, "<aResult> \n");
		}
		appendToFile(ccFile, "\n");
	}
	appendToFile(ccFile, "\n\n\n");	
}



private map [metricsType, num] calculateCCResults(rel [inheritanceKey, inheritanceType] inheritanceResults, rel [loc, loc] inheritanceRelations, M3 projectM3) {
	
	map [metricsType, num] 		CCResultsMap 		= ();
	// filter out CC only
	rel [inheritanceKey, inheritanceType] ccResults = {<<_child, _parent>, iKey> | <<_child, _parent>, iKey> <- inheritanceResults, isClass(_child), isClass(_parent)};
	rel [loc, loc] ccRelations = { <_child, _parent> | <_child, _parent> <- inheritanceRelations, isClass(_child), isClass(_parent)};
	
	// numExplicitCC : Number of explicit user defined cc edges (for the authors)

	CCResultsMap += (numExplicitCC: size({<_child, _parent>| <_child, _parent>  <- ccRelations}));			
	println("Explicit cc ------------------"); iprintln(sort({<_child, _parent>| <_child, _parent>  <- ccRelations}));
	
	CCResultsMap += (numCCUsed: size({<_child, _parent> | <<_child, _parent>, _iType> <- ccResults, _iType in {INTERNAL_REUSE, EXTERNAL_REUSE, SUBTYPE} }));
	CCResultsMap += (perCCUsed : calcPercentage(CCResultsMap[numCCUsed], CCResultsMap[numExplicitCC]));
	
	CCResultsMap += (numCCDC : size({<_child, _parent> | <<_child, _parent>, _iType> <- ccResults, _iType == DOWNCALL}));
	CCResultsMap += (perCCDC : calcPercentage(CCResultsMap[numCCDC], CCResultsMap[numExplicitCC]));


	set [inheritanceKey] subtypeRels 			= {<_child, _parent> | <<_child, _parent> , _iType> <- ccResults, _iType == SUBTYPE};
	set [inheritanceKey] exreuseNoSubtypeRels 	= {<_child, _parent> | <<_child, _parent>, _iType> <- ccResults, _iType == EXTERNAL_REUSE} - subtypeRels;
	set [inheritanceKey] usedOnlyInReRels 		= {<_child, _parent> | <<_child, _parent>, _iType> <- ccResults, _iType == INTERNAL_REUSE} - (exreuseNoSubtypeRels + subtypeRels); 
			
	println("SUBTYPE:  ----------------- "); iprintln(sort(subtypeRels));		
	println("EXTERNAL REUSE ONLY:  ----------------- "); iprintln(sort(exreuseNoSubtypeRels));
	println("INTERNAL REUSE ONLY :  ----------------- "); iprintln(sort(usedOnlyInReRels));		
			
	CCResultsMap += (numCCSubtype : size(subtypeRels));	
	CCResultsMap += (perCCSubtype : calcPercentage(CCResultsMap[numCCSubtype], CCResultsMap[numCCUsed]));	
	
	CCResultsMap += (numCCExreuseNoSubtype : size(exreuseNoSubtypeRels) );	
	CCResultsMap += (perCCExreuseNoSubtype : calcPercentage(CCResultsMap[numCCExreuseNoSubtype ], CCResultsMap[numCCUsed]));
	
	CCResultsMap += (numCCUsedOnlyInRe : size(usedOnlyInReRels));
	CCResultsMap += (perCCUsedOnlyInRe : calcPercentage(CCResultsMap[numCCUsedOnlyInRe], CCResultsMap[numCCUsed]));
		
			
	set [inheritanceKey] allButSuper = {<_child, _parent> | <<_child, _parent>, _iType> <- ccResults, _iType in {INTERNAL_REUSE, EXTERNAL_REUSE, SUBTYPE, DOWNCALL, CONSTANT, MARKER, GENERIC, CATEGORY, FRAMEWORK} };
	CCResultsMap += (numCCUnexplSuper: size({<_child, _parent> | <<_child, _parent>, _iType> <- ccResults, _iType == SUPER} - allButSuper));
	CCResultsMap += (perCCUnexplSuper: calcPercentage(CCResultsMap[numCCUnexplSuper], CCResultsMap[numExplicitCC]));
	
	set [inheritanceKey] allButCategory = {<_child, _parent> | <<_child, _parent>, _iType> <- ccResults, _iType in {INTERNAL_REUSE, EXTERNAL_REUSE, SUBTYPE, DOWNCALL, CONSTANT, MARKER, GENERIC, SUPER, FRAMEWORK}};
	CCResultsMap += (numCCUnexplCategory : size( {<_child, _parent> | <<_child, _parent>, _iType> <- ccResults, _iType == CATEGORY}  - allButCategory));
	CCResultsMap += (perCCUnexplCategory: calcPercentage(CCResultsMap[numCCUnexplCategory ], CCResultsMap[numExplicitCC]));

	set [inheritanceKey] allFoundUsages = {<_child, _parent> | <<_child, _parent> , _iType> <- ccResults};
	CCResultsMap += (numCCUnknown: size(ccRelations- allFoundUsages));
	CCResultsMap += (perCCUnknown: calcPercentage(CCResultsMap[numCCUnknown], CCResultsMap[numExplicitCC]));

	printResultSummaryToFile(ccResults, projectM3);

	return CCResultsMap;
}


private void printCCResults(map [metricsType, num]  CCMetricResults, M3 projectM3) {
	println("RESULTS FOR CC EDGES:");
	iprintln(CCMetricResults);
	println("------------------------------------------------");	
	for ( aCCMetric <- [numExplicitCC..perCCUnknown+1]) {
		println("<getNameOfInheritanceMetric(aCCMetric)> 	: <CCMetricResults[aCCMetric]>");
		appendToFile(getFilename(projectM3.id,resultsFile), "<CCMetricResults[aCCMetric]>\t" );
	}
	println();
}


private void printResults(map[inheritanceType, num] totals ) {
	for ( anInheritanceType <- [INTERNAL_REUSE..(FRAMEWORK+1)]) {
		println("NUMBER OF <getNameOfInheritanceType(anInheritanceType)> CASES: <totals[anInheritanceType]>");
	}
	println();
}





public void runIt() {
	setPrecision(4);
	rel [inheritanceKey, int] allInheritanceCases = {};	
	println("Date: <printDate(now())>");
	println("Creating M3....");
	//loc projectLoc = |project://cobertura-1.9.4.1|;
	loc projectLoc = |project://VerySmallProject|;
	makeDirectory(projectLoc);
	M3 projectM3 = createM3FromEclipseProject(projectLoc);
	println("Created M3....for <projectLoc>");
	writeFile(getFilename(projectM3.id, errorLog), "Error log for <projectM3.id.authority>\n" );
	writeFile(getFilename(projectM3.id, resultSummaryFile), "RESULTS LOG: \n" );
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
	
	
	
	rel [loc, loc] systemInhRelations = allInheritanceRelations;
	
	// 	= getNonFrameworkInheritanceRels(allInheritanceRelations, projectM3); Changed at 26June2014, this is a test TODO TODO TODO 
	
	rel [loc, loc] explicitInhRelations = getExplicitInhRelations(systemInhRelations, projectM3);


	set [loc] allSystemTypes = getAllClassesAndInterfacesInProject(projectM3);
	rel [loc, loc] systemExplicitInhRelations = {<_child, _parent> | <_child, _parent> <- explicitInhRelations, _child in allSystemTypes, _parent in allSystemTypes};

	map [metricsType, num] explicitCCMetricResults = calculateCCResults(explicitResults, systemExplicitInhRelations, projectM3);
	map [metricsType, num] explicitCIMetricResults = calculateCIResults(explicitResults, systemExplicitInhRelations, projectM3);
	map [metricsType, num] explicitIIMetricResults = calculateIIResults(explicitResults, systemExplicitInhRelations, projectM3);
	
	writeFile(getFilename(projectM3.id,resultsFile), "<projectM3.id.authority>\t" );
	println("EXPLICIT RESULTS - EXPLICIT AND CANDIDATES");
	printCCResults(explicitCCMetricResults, projectM3);
	printCIResults(explicitCIMetricResults, projectM3);
	printIIResults(explicitIIMetricResults, projectM3);
	appendToFile(getFilename(projectM3.id,resultsFile), "\n" );
	
	
	println("Total number of types analyzed: <size(getAllClassesAndInterfacesInProject(projectM3))>");
	printLog(getFilename(projectM3.id,downcallLogFile), "DOWNCALL LOG:");
	printLog(getFilename(projectM3.id,externalReuseLogFile), "EXTERNAL REUSE LOG:");
	printLog(getFilename(projectM3.id,subtypeLogFile), "SUBTYPE LOG:");
	
	
}

