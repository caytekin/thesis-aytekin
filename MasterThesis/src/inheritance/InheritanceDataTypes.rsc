module inheritance::InheritanceDataTypes

import lang::java::m3::TypeSymbol;


public inheritanceType INTERNAL_REUSE = 0;
public inheritanceType EXTERNAL_REUSE = 1;
public inheritanceType SUBTYPE = 2;
public inheritanceType DOWNCALL_ACTUAL = 3;
public inheritanceType DOWNCALL_CANDIDATE = 4;
public inheritanceType CONSTANT = 5;
public inheritanceType MARKER = 6;
public inheritanceType SUPER = 7;
public inheritanceType GENERIC = 8;
public inheritanceType CATEGORY = 9;
public inheritanceType FRAMEWORK = 10;
public inheritanceType DOWNCALL = 11;





public metricsType numExplicitCC			= 1001;
public metricsType numCCUsed				= 1002;
public metricsType perCCUsed				= 1003;		// numCCUsed / numExplicitCC
public metricsType numCCDC					= 1004;
public metricsType perCCDC					= 1005;		// numCCDC / numExplicitCC
public metricsType numCCSubtype 			= 1006;
public metricsType perCCSubtype 			= 1007;		// numCCSubtype / numCCUsed
public metricsType numCCExreuseNoSubtype 	= 1008;
public metricsType perCCExreuseNoSubtype 	= 1009;		// numCCExreuseNoSubtype / numCCUsed
public metricsType numCCUsedOnlyInRe		= 1010;
public metricsType perCCUsedOnlyInRe		= 1011;		// numCCUsedOnlyInRe / numCCUsed
public metricsType numCCUnexplSuper			= 1012;
public metricsType perCCUnexplSuper			= 1013;		// numCCUnexplSuper / numExplicitCC
public metricsType numCCUnexplCategory		= 1014;
public metricsType perCCUnexplCategory		= 1015;		// numCCUnexplCategory / numExplicitCC
public metricsType numCCUnknown				= 1016;
public metricsType perCCUnknown				= 1017;		// numCCUnknown / numExplicitCC


public metricsType numExplicitCI			= 1018;
public metricsType numOnlyCISubtype			= 1019;
public metricsType perOnlyCISubtype			= 1020;		// numOnlyCISubtype / numExplicitCI
public metricsType numExplainedCI			= 1021;
public metricsType perExplainedCI			= 1022;		// numExplainedCI / numExplicitCI
public metricsType numCategoryExplCI		= 1023;
public metricsType perCategoryExplCI		= 1024;		// numCategoryExplCI / numExplicitCI
public metricsType numUnexplainedCI			= 1025;
public metricsType perUnexplainedCI			= 1026;		// numUnexplainedCI / numExplicitCI


public metricsType numExplicitII			= 1027;
public metricsType numIISubtype				= 1028;
public metricsType perIISubtype				= 1029;		// numIISubtype / numExplicitII
public metricsType numOnlyIIReuse			= 1030;
public metricsType perOnlyIIReuse			= 1031;		// numOnlyIIReuse / numExplicitII
public metricsType numExplainedII			= 1032;
public metricsType perExplainedII			= 1033;		// numExplainedII / numExplicitII
public metricsType numCategoryExplII		= 1034;
public metricsType perCategoryExplII		= 1035;		// numCategoryExplII / numExplicitII
public metricsType numUnexplainedII			= 1036;
public metricsType perUnexplainedII			= 1037;		// numUnexplainedII / numExplicitII


public metricsType perAddedCCSubtype		= 1101;
public metricsType perAddedCCExtReuse		= 1102;
public metricsType perAddedCISubtype        = 1103;
public metricsType perAddedCIExtReuse		= 1104;
public metricsType perAddedIISubtype		= 1105;
public metricsType perAddedIIExtReuse		= 1106;







public inheritanceSubtype SUBTYPE_ASSIGNMENT_STMT 		= 201;
public inheritanceSubtype SUBTYPE_ASSIGNMENT_VAR_DECL 	= 202;
public inheritanceSubtype SUBTYPE_VIA_CAST 				= 203;
public inheritanceSubtype SUBTYPE_VIA_UPCASTING			= 204;
public inheritanceSubtype SUBTYPE_VIA_SIDEWAYS_CASTING 	= 205;
public inheritanceSubtype SUBTYPE_VIA_RETURN 			= 206;
public inheritanceSubtype SUBTYPE_VIA_PARAMETER 		= 207;
public inheritanceSubtype SUBTYPE_VIA_FOR_LOOP 			= 208;


public inheritanceSubtype EXTERNAL_REUSE_DIRECT 	= 210;
public inheritanceSubtype EXTERNAL_REUSE_INDIRECT 	= 211;


public inheritanceSubtype INTERNAL_REUSE_METHOD_LEVEL = 220;
public inheritanceSubtype INTERNAL_REUSE_CLASS_LEVEL = 221;



public inheritanceType INITIAL_TYPE = 999;

public alias inheritanceSubtype = int;


public alias inheritanceKey = tuple [loc child, loc parent];
public alias inheritanceType = int;
public alias metricsType = int;

public loc DEFAULT_LOC = |java+project:///|;
public TypeSymbol DEFAULT_TYPE_SYMBOL = class(|java+class:///|,[]);
public loc THROWABLE_CLASS = |java+class:///java/lang/Throwable|;
public loc EXCEPTION_CLASS = |java+class:///java/lang/Exception|;
public loc OBJECT_CLASS = |java+class:///java/lang/Object|;
public TypeSymbol OBJECT_TYPE_SYMBOL = class(OBJECT_CLASS, []); 


public alias internalReuseDetail = tuple [loc accessedLoc, loc invokingMethodOrClass];
public alias externalReuseDetail = tuple [loc accessedLoc, loc invokingMethod];
public alias subtypeDetail = tuple [inheritanceKey _iKey, inheritanceSubtype inhSub, loc subtypeDetailLoc, loc referredParent];
public alias downcallDetail = tuple [loc dOccurrenceLoc, loc dInvokedMethod, loc dDowncalledMethod];
public alias superCallLoc = loc;
public alias thisChangingTypeCandDetail = tuple [loc methodOfAscClass, loc sourceOfCandCall];
public alias thisChangingTypeOccurrence = tuple [loc sourceRef, loc invokedmethod];
public alias categorySibling = loc;

 //public loc beginPath = |file:///home/aytekin/Documents/InheritanceLogs|; 

// public loc beginPath = |file://C:/Users/cigde_000/Documents/InheritanceLogs|;

 public loc beginPath = |file://C:/Users/caytekin/InheritanceLogs|; 

public str internalReuseLogFile 		=  "InternalReuse.log";
public str categoryLogFile 				=  "Category.log" ;
public str downcallLogFile 				=  "Downcall.log";
public str subtypeLogFile 				=  "Subtype.log";
public str externalReuseLogFile 		=  "ExternalReuse.log";
public str superLogFile 				=  "Super.log";
public str thisChangingTypeCandFile 	=  "ThisChangingTypeCand.log";
public str thisChangingTypeOccurFile 	=  "ThisChangingTypeOccur.log";
public str genericLogFile 				=  "Generic.log";
public str addedRelsLogFile 			=  "AddedRels.log";
public str resultsFile					=  "Results.txt"; 
public str errorLog						=  "Error.log" ;
public str resultSummaryFile			=  "ResultsSummary.log"; 
public str addedPercentagesFile 		=  "AddedPercentages.txt";




