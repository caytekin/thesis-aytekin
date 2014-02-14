module inheritance::InheritanceDataTypes

public int INTERNAL_REUSE = 0;
public int EXTERNAL_REUSE = 1;
public int SUBTYPE = 2;
public int DOWNCALL = 3;
public int FRAMEWORK = 4;
public int CONSTANTS = 5;
public int MARKER = 6;
public int SUPER = 7;
public int GENERIC = 8;

public int CLASS_CLASS = 100;
public int CLASS_INTERFACE = 101;
public int INTERFACE_INTERFACE = 102;



public alias inheritanceKey = tuple [loc child, loc parent];
public alias inheritanceType = int;

public loc DEFAULT_LOC = |java+project:///|;

