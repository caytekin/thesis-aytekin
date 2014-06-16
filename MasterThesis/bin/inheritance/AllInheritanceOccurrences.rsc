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


// return all non-framework (i. e. system) types which are not exceptions
rel [inheritanceKey, inheritanceType] getFilteredInheritanceCases(rel [ inheritanceKey, inheritanceType] allInheritanceCases, rel [loc, loc] allInheritanceRelations, M3 projectM3) {
	rel [inheritanceKey, inheritanceType]retRel = {};
	set [loc] allExceptionClasses = getAllExceptionClasses(allInheritanceRelations);
	set [loc] allTypesOfProject = getAllClassesAndInterfacesInProject(projectM3);
	set [loc] allNonExceptionTypesOfProject = allTypesOfProject - allExceptionClasses;
	retRel = {<<_child,_parent>, _iKey> | <<_child, _parent>, _iKey> <- allInheritanceCases, _child in allNonExceptionTypesOfProject , _parent in allNonExceptionTypesOfProject};
	return retRel;
}


private loc getImmediateParent(loc classOrInt, loc ascLoc,  map[loc, set[loc]] exOrImplMap, rel [loc, loc] allInheritanceRelations) {
	loc retLoc = DEFAULT_LOC;
	loc foundLoc = DEFAULT_LOC;
	set[loc] immParentSet = classOrInt in exOrImplMap ? exOrImplMap[classOrInt] : {};
	if (size(immParentSet) > 1) { // this is only possible if parents are interfaces 
		for (anImmediateParent <-immParentSet) {
			foundLoc = DEFAULT_LOC;
			if (inheritanceRelationExists(anImmediateParent, ascLoc, allInheritanceRelations)) {
				foundLoc = anImmediateParent;
				break;
			}
		}
		if (foundLoc == DEFAULT_LOC) {
			throw "<classOrInt> has more than one immediateParent! Immediate parent set : <immParentSet> ";
		}	
		retLoc = foundLoc;
	}
	else {
		if (size(immParentSet) == 1) {
			retLoc = getOneFrom(immParentSet);
		}
	}  
	return retLoc;
}



private rel [inheritanceKey, inheritanceType] getResultsOfImplicitUsage(rel [inheritanceKey, inheritanceType] implicitFoundInhrels, M3 projectM3) {
	// the authors wrote an answer about the following: for three types G, C, P (G extends C, C extends P), if there is a reuse (internal or external), 
	// subtype or a downcall between G and P, the edge G and P does not get listed, because the edge G-> P is not explicit, however, the edge between 
	//  G and C will get the same attribute (reuse, subtype or downcall), because it is explicit.
	rel [inheritanceKey, inheritanceType] retRel = {};
	rel [inheritanceKey, inheritanceType] selectedOccurrences = {<<_child, _parent>, _iType> | <<_child, _parent>, _iType> <- implicitFoundInhrels, _iType == EXTERNAL_REUSE || _iType == INTERNAL_REUSE 
																												|| 	_iType == SUBTYPE || _iType == DOWNCALL};
	rel [inheritanceKey, inheritanceType, loc] addedInhOccLog = {};
	map[loc, set[loc]] 	extendsMap 		= toMap({<_child, _parent> | <_child, _parent> <- projectM3@extends});
	map[loc, set[loc]] 	implementsMap 	= toMap({<_child, _parent> | <_child, _parent> <- projectM3@implements});
	rel [loc, loc] 		allInheritanceRelations 	= getInheritanceRelations(projectM3);
	//println("--------------------------getResultsOfImplicitUsage----------------------");
	//iprintln(sort(selectedOccurrences));
	//println("--------------------------getResultsOfImplicitUsage----------------------");	
	loc immediateParent = DEFAULT_LOC;
	for ( <<_child, _parent>, _iType> <- sort(selectedOccurrences)) {
		immediateParent = DEFAULT_LOC;
		println("--------Child: <_child>, parent: < _parent>, Inhtype: <_iType>");
		if (isInterface(_child)) {
			immediateParent =  getImmediateParent(_child, _parent, extendsMap, allInheritanceRelations); 
		}
		else {
			if (isClass(_parent)) {
				immediateParent = getImmediateParent(_child, _parent, extendsMap, allInheritanceRelations); 
			}
			else { // child is a class, parent is an interface
				immediateParent = getImmediateParent(_child, _parent, extendsMap, allInheritanceRelations); 
				if ((immediateParent != DEFAULT_LOC) && inheritanceRelationExists(immediateParent ,_parent, allInheritanceRelations)) {
					// immediate parent is found
				;}
				else {
					immediateParent = getImmediateParent(_child, _parent, extendsMap, allInheritanceRelations); 
				}
			}
		}
		println("Immediate parent: <immediateParent>"); 
		addedInhOccLog += <<_child, immediateParent>, _iType, _parent>; 
	}  // for														
	retRel = {<<_child, _immediateParent>, _iType> | <<_child, _immediateParent>, _iType, _parent><- addedInhOccLog, _immediateParent != DEFAULT_LOC };	
	iprintToFile(getFilename(projectM3.id,addedRelsLogFile),addedInhOccLog );						
	return retRel;
}




// getExplicitResults filters the inheritanceResults according to  the criteria of the original article:
// they count explicit relations only and they include candidates of downcall.
private rel [inheritanceKey, inheritanceType] getExplicitResults (rel [inheritanceKey, inheritanceType] inheritanceResults, M3 projectM3) {
	rel [inheritanceKey, inheritanceType] retRel = {};
	rel [inheritanceKey, inheritanceType] allOccurrences = {};	
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
	retRel = explicitFoundInhRels + getResultsOfImplicitUsage(implicitFoundInhRels, projectM3);
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
	loc projectLoc = |project://fitjava-1.1|;
	makeDirectory(projectLoc);
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
	//rel [inheritanceKey, inheritanceType] actualResults = getActualResults(filteredInheritanceCases);	
	
	rel [loc, loc] systemInhRelations 	= getNonFrameworkInheritanceRels(allInheritanceRelations, projectM3);
	
	rel [loc, loc] explicitInhRelations = getExplicitInhRelations(systemInhRelations, projectM3);


	
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
	
	println("INTERNAL REUSE ALL:");
	iprintln(sort({<_child, _parent> | <<_child, _parent>, _iType> <- allInheritanceCases, _iType == INTERNAL_REUSE }));


	println("EXTERNAL REUSE:");
	iprintln(sort({<_child, _parent> | <<_child, _parent>, _iType> <- allInheritanceCases, _iType == EXTERNAL_REUSE}));

	
	println("SUBTYPE:");
	iprintln(sort({<_child, _parent> | <<_child, _parent>, _iType> <- allInheritanceCases, _iType == SUBTYPE}));
	

	printLog(getFilename(projectM3.id, downcallLogFile), "DOWNCALL LOG:");

	printLog(getFilename(projectM3.id, internalReuseLogFile), "INTERNAL REUSE LOG:");
	printLog(getFilename(projectM3.id, externalReuseLogFile), "EXTERNAL REUSE LOG:");
	printLog(getFilename(projectM3.id, subtypeLogFile), "SUBTYPE LOG:");
	printLog(getFilename(projectM3.id, thisChangingTypeCandFile), "THIS CHANGING TYPE CANDIDATES:");
	printLog(getFilename(projectM3.id, thisChangingTypeOccurFile), "THIS CHANGING TYPE OCCURRENCES:");	

	printLog(getFilename(projectM3.id, genericLogFile), "GENERIC LOG:");
	printLog(getFilename(projectM3.id, superLogFile), "SUPER LOG:");
	printLog(getFilename(projectM3.id, categoryLogFile), "CATEGORY LOG: ");	



	map [metricsType, num] explicitCCMetricResults = calculateCCResults(explicitResults, explicitInhRelations, projectM3);
	map [metricsType, num] explicitCIMetricResults = calculateCIResults(explicitResults, explicitInhRelations, projectM3);
	map [metricsType, num] explicitIIMetricResults = calculateIIResults(explicitResults, explicitInhRelations, projectM3);
	
	writeFile(getFilename(projectM3.id,resultsFile), "<projectM3.id.authority>\t" );
	println("EXPLICIT RESULTS - EXPLICIT AND CANDIDATES");
	printCCResults(explicitCCMetricResults, projectM3);
	printCIResults(explicitCIMetricResults, projectM3);
	printIIResults(explicitIIMetricResults, projectM3);
	appendToFile(getFilename(projectM3.id,resultsFile), "\n" );
	
	
	println("Total number of types analyzed: <size(getAllClassesAndInterfacesInProject(projectM3))>");

}

