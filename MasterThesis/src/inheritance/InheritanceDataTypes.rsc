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


public inheritanceType INITIAL_TYPE = 999;


public alias inheritanceKey = tuple [loc child, loc parent];
public alias inheritanceType = int;

public loc DEFAULT_LOC = |java+project:///|;

