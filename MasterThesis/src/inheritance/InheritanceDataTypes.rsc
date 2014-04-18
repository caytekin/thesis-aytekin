module inheritance::InheritanceDataTypes

import lang::java::m3::TypeSymbol;


public inheritanceType INTERNAL_REUSE = 0;
public inheritanceType EXTERNAL_REUSE_ACTUAL = 1;
public inheritanceType EXTERNAL_REUSE_CANDIDATE = 2;
public inheritanceType SUBTYPE = 3;
public inheritanceType DOWNCALL_ACTUAL = 4;
public inheritanceType DOWNCALL_CANDIDATE = 5;
public inheritanceType CONSTANT = 6;
public inheritanceType MARKER = 7;
public inheritanceType SUPER = 8;
public inheritanceType GENERIC = 9;
public inheritanceType CATEGORY = 10;


public metricsType nExplicitCC			= 1001;
public metricsType nCCUsed				= 1002;
public metricsType nCCDC				= 1003;
public metricsType nCCSubtype 			= 1004;
public metricsType nCCExreuseNoSubtype 	= 1005;
public metricsType nCCUsedOnlyInRe		= 1006;
public metricsType nCCUnexplSuper		= 1007;
public metricsType nCCUnExplCategory	= 1008;
public metricsType nCCUnknown			= 1009;



public inheritanceSubtype SUBTYPE_ASSIGNMENT_STMT = 201;
public inheritanceSubtype SUBTYPE_ASSIGNMENT_VAR_DECL = 202;
public inheritanceSubtype SUBTYPE_VIA_CAST = 203;
public inheritanceSubtype SUBTYPE_VIA_RETURN = 204;
public inheritanceSubtype SUBTYPE_VIA_PARAMETER = 205;
public inheritanceSubtype SUBTYPE_VIA_FOR_LOOP = 206;


public inheritanceSubtype EXTERNAL_REUSE_ACTUAL_VIA_METHOD_CALL = 210;
public inheritanceSubtype EXTERNAL_REUSE_ACTUAL_VIA_FIELD_ACCESS = 211;
public inheritanceSubtype EXTERNAL_REUSE_CANDIDATE_METHOD = 212;
public inheritanceSubtype EXTERNAL_REUSE_CANDIDATE_FIELD = 213;


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
public loc OBJECT_CLASS = |java+class:///java/lang/Object|;


public alias internalReuseDetail = tuple [loc accessedLoc, loc invokingMethodOrClass];
public alias externalReuseDetail = tuple [loc accessedLoc, loc invokingMethod];
public alias subtypeDetail = tuple [ inheritanceSubtype inhSub, loc subtypeDetailLoc];
public alias downcallDetail = tuple [loc dOccurrenceLoc, loc dInvokedMethod, loc dDowncalledMethod];
public alias superCallLoc = loc;
public alias thisChangingTypeCandDetail = tuple [loc methodOfAscClass, loc sourceOfCandCall];
public alias thisChangingTypeOccurrence = tuple [loc sourceRef, loc invokedmethod];
public alias categorySibling = loc;


public loc categoryLogFile = |file://c:/Users/caytekin/InheritanceLogs/Category.log|;
public loc downcallLogFile = |file://c:/Users/caytekin/InheritanceLogs/Downcall.log|;
public loc subtypeLogFile = |file://c:/Users/caytekin/InheritanceLogs/Subtype.log|;
public loc actualExternalReuseLogFile = |file://c:/Users/caytekin/InheritanceLogs/ActualExternalReuse.log|;
public loc candidateExternalReuseLogFile = |file://c:/Users/caytekin/InheritanceLogs/CandidateExternalReuse.log|;
public loc internalReuseLogFile = |file://c:/Users/caytekin/InheritanceLogs/InternalReuse.log|;
public loc superLogFile = |file://c:/Users/caytekin/InheritanceLogs/Super.log|;
public loc thisChangingTypeCandFile = |file://c:/Users/caytekin/InheritanceLogs/ThisChangingTypeCand.log|;
public loc thisChangingTypeOccurFile = |file://c:/Users/caytekin/InheritanceLogs/ThisChangingTypeOccur.log|;
public loc genericLogFile = |file://c:/Users/caytekin/InheritanceLogs/Generic.log|;




