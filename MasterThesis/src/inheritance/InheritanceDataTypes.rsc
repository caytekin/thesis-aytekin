module inheritance::InheritanceDataTypes

import lang::java::m3::TypeSymbol;


public inheritanceType INTERNAL_REUSE = 0;
public inheritanceType EXTERNAL_REUSE = 1;
public inheritanceType SUBTYPE = 2;
public inheritanceType DOWNCALL = 3;
public inheritanceType CONSTANT = 4;
public inheritanceType MARKER = 5;
public inheritanceType SUPER = 6;
public inheritanceType GENERIC = 7;

public inheritanceType CLASS_CLASS = 8;
public inheritanceType CLASS_INTERFACE = 9;
public inheritanceType INTERFACE_INTERFACE = 10;

public inheritanceType NONFRAMEWORK_CC = 11;
public inheritanceType NONFRAMEWORK_CI = 12;
public inheritanceType NONFRAMEWORK_II = 13;



public inheritanceSubtype SUBTYPE_ASSIGNMENT_STMT = 201;
public inheritanceSubtype SUBTYPE_ASSIGNMENT_VAR_DECL = 202;
public inheritanceSubtype SUBTYPE_VIA_CAST = 203;
public inheritanceSubtype SUBTYPE_VIA_RETURN = 204;
public inheritanceSubtype SUBTYPE_VIA_PARAMETER = 205;


public inheritanceSubtype EXTERNAL_REUSE_VIA_METHOD_CALL = 210;
public inheritanceSubtype EXTERNAL_REUSE_VIA_FIELD_ACCESS = 211;




public inheritanceType INITIAL_TYPE = 999;

public alias inheritanceSubtype = int;


public alias inheritanceKey = tuple [loc child, loc parent];
public alias inheritanceType = int;

public loc DEFAULT_LOC = |java+project:///|;
public TypeSymbol DEFAULT_TYPE_SYMBOL = class(|java+class:///|,[]);


public alias internalReuseDetail = tuple [loc accessedLoc, loc invokingMethod];
public alias externalReuseDetail = tuple [loc accessedLoc, loc invokingMethod];
public alias subtypeDetail = tuple [ inheritanceSubtype inhSub, loc subtypeDetailLoc];
public alias downcallDetail = tuple [loc dOccurrenceLoc, loc dInvokedMethod, loc dDowncalledMethod];
public alias superCallLoc = loc;


public loc downcallLogFile = |file://c:/Users/caytekin/InheritanceLogs/Downcall.log|;
public loc subtypeLogFile = |file://c:/Users/caytekin/InheritanceLogs/Subtype.log|;
public loc externalReuseLogFile = |file://c:/Users/caytekin/InheritanceLogs/ExternalReuse.log|;
public loc internalReuseLogFile = |file://c:/Users/caytekin/InheritanceLogs/InternalReuse.log|;
public loc superLogFile = |file://c:/Users/caytekin/InheritanceLogs/Super.log|;




