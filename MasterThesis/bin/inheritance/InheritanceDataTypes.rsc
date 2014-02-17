module inheritance::InheritanceDataTypes

public inheritanceType INTERNAL_REUSE = 0;
public inheritanceType EXTERNAL_REUSE = 1;
public inheritanceType SUBTYPE = 2;
public inheritanceType DOWNCALL = 3;
public inheritanceType FRAMEWORK = 4;
public inheritanceType CONSTANTS = 5;
public inheritanceType MARKER = 6;
public inheritanceType SUPER = 7;
public inheritanceType GENERIC = 8;

public inheritanceType CLASS_CLASS = 100;
public inheritanceType CLASS_INTERFACE = 101;
public inheritanceType INTERFACE_INTERFACE = 102;


public inheritanceSubtype SUBTYPE_ASSIGNMENT_AST = 201;
public inheritanceSubtype SUBTYPE_ASSIGNMENT_TYPE_DEPENDENCY = 202;



public inheritanceType INITIAL_TYPE = 999;

public alias inheritanceSubtype = int;


public alias inheritanceKey = tuple [loc child, loc parent];
public alias inheritanceType = int;

public loc DEFAULT_LOC = |java+project:///|;


public alias internalReuseDetail = tuple [loc accessedLoc, loc invokingMethod];
public alias externalReuseDetail = tuple [loc accessedLoc, loc invokingMethod];
public alias subtypeViaAssignmentASTLoc = tuple [loc ASTDetailLoc, inheritanceSubtype inhSub];
public alias subtypeViaAssignmentTypeDef = tuple [loc VariableLoc, inheritanceSubtype inhSub];


public loc subtypeASTLogFile = |file://c:/Users/caytekin/InheritanceLogs/SubtypeAST.log|;
public loc subtypeTypeDepLogFile = |file://c:/Users/caytekin/InheritanceLogs/SubtypeTypeDef.log|;
public loc externalReuseLogFile = |file://c:/Users/caytekin/InheritanceLogs/ExternalReuse.log|;
public loc internalReuseLogFile = |file://c:/Users/caytekin/InheritanceLogs/InternalReuse.log|;




