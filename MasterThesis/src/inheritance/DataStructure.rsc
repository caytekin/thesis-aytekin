module inheritance::DataStructure

import IO;
import Map;
import Set;
import Relation;
import List;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

int INTERNAL_REUSE = 0;
int EXTERNAL_REUSE = 1;
int SUBTYPE = 2;
int DOWNCALL = 3;
int FRAMEWORK = 4;
int CONSTANTS = 5;
int MARKER = 6;
int SUPER = 7;
int GENERIC = 8;

int CLASS_CLASS = 100;
int CLASS_INTERFACE = 101;
int INTERFACE_INTERFACE = 102;



alias inheritanceKey = tuple [loc child, loc parent];

// TODO this is a relation, not a list, change name...
rel [inheritanceKey, int] inheritanceList;


private void getInternalReuseCount(M3 projectM3) {
	// Get all the child classes in CC relation, they are the only ones which can initiate internal reuse.
	//
	// The super() calls in the constructors are not counted as internal reuse, also see assumptions document.
	//
	// In classes, not only the methods, but also the initializers are taken into account
	//
	// I do NOT traverse  framework inheritance relationships.
	//
	// TODO: find and save between which two classes the internal reuse relation exists.
	rel [loc, loc] allInheritanceRels = getNonFrameworkInheritanceRels(projectM3, getInheritanceRelations(projectM3));
	set [loc] intReuseClasses = { child | <child, parent> <- allInheritanceRels, isClass(child), isClass(parent)};
	for (oneClass <- intReuseClasses) {
		set [loc] ancestors = { parent | <child, parent> <- allInheritanceRels, child == oneClass};
		set [loc] ancestorFieldsMethods = {declared | <owner,declared> <- projectM3@containment, owner in ancestors, isField(declared) || isMethod(declared)};
		set [loc] declaredFieldsMethods = {declared | <owner,declared> <- projectM3@containment, 
																		owner == oneClass, 
																		isField(declared) 	|| 
																		isMethod(declared) 	|| 
																		declared.scheme == "java+initializer" };
		set [loc] declaredMethods = { declMeth | declMeth <- declaredFieldsMethods, 
																		isMethod(declMeth) || 
																		declMeth.scheme == "java+initializer" };
		for (oneMethod <- declaredMethods) {
			set [loc] internalReuseMethodInvocation = { invoked | <caller, invoked> <- projectM3@methodInvocation, 
																			caller == oneMethod,  
																			invoked notin declaredFieldsMethods, 
																			invoked in ancestorFieldsMethods, 
																			invoked.scheme != "java+constructor" };	
			set [loc] internalReuseFieldAccess = { accessed | <accessor, accessed> <- projectM3@fieldAccess, 
																			accessor == oneMethod,  
																			accessed notin declaredFieldsMethods, 
																			accessed in ancestorFieldsMethods };	
			set [loc] internalReuseLoc = internalReuseMethodInvocation + internalReuseFieldAccess;																		
			for (reusedLoc <- internalReuseLoc) {
				set [loc]  classOfLoc = {aClass | <aClass, cLoc> <- projectM3@containment, 
																				isClass(aClass), 
																				cLoc == reusedLoc};
				if (size(classOfLoc) != 1) { throw "A method or a field  can be defined in one class only! <reusedLoc>"; }; 
				loc parentClass = getOneFrom(classOfLoc);
				inheritanceList += < <oneClass, parentClass>, INTERNAL_REUSE>;
			};																			
		};	
	};
}


 


private void insertCC_CI_II_FRAMEWORK (rel [loc child, loc parent] inheritRelation) {
	rel [loc, loc] allClassClass = {<child, parent> | <child, parent> <- inheritRelation, isClass(child), isClass(parent)};	
	for (<child, parent> <- allClassClass ) { inheritanceList += <<child, parent>, CLASS_CLASS>;	};
	rel [loc, loc] allClassInterface = {<child, parent> | <child, parent> <- inheritRelation, isClass(child), isInterface(parent)};
	for (<child, parent> <- allClassInterface ) { inheritanceList += <<child,parent>, CLASS_INTERFACE>; };
	rel [loc, loc] allInterfaceInterface = {<child, parent> | <child, parent> <- inheritRelation, isInterface(child), isInterface(parent)};
	for (<child, parent> <- allInterfaceInterface ) { inheritanceList += <<child,parent>, INTERFACE_INTERFACE>; };
	// TODO : Also insert framework inheritance relations
}




private rel [loc, loc] getNonFrameworkInheritanceRels(M3 projectM3, rel [loc, loc] inheritanceRels) {
	set [loc] allTypesInM3 = {decl | <decl, prjct> <- projectM3@declarations, 
														isClass(decl) || isInterface(decl)};
	return {<child, parent> | <child, parent> <- inheritanceRels, parent in allTypesInM3 };
}




private rel [loc, loc]  getInheritanceRelations(M3 projectM3) {
	allInheritanceRel = projectM3@extends + projectM3@implements; 
	// TODO: make a list of candidates for sideways cast.
	map [inheritanceKey, int] inheritanceMap; 
	// I use the transitive closure to see the transitive inheritance relationships between
	// classes and interfaces. 
	return allInheritanceRel+;
}

private void printResults() {
	println("Number of CC edges:  <size({inhItem | <inhItem, inhType> <- inheritanceList, inhType == CLASS_CLASS})>"); 
	println("Number of CI edges:  <size({inhItem | <inhItem, inhType> <- inheritanceList, inhType == CLASS_INTERFACE})>"); 
	println("Number of II edges:  <size({inhItem | <inhItem, inhType> <- inheritanceList, inhType == INTERFACE_INTERFACE})>"); 
	println("Number of internal reuse edges:  <size({inhItem | <inhItem, inhType> <- inheritanceList, inhType == INTERNAL_REUSE})>"); 
	print("Reuse edges: ");	
	iprintln(sort({inhItem | <inhItem, inhType> <- inheritanceList, inhType == INTERNAL_REUSE}));
}



public void runDataStructure() {
	println("Creating M3....");
	M3 projectM3 = createM3FromEclipseProject(|project://InheritanceSamples|);
	println("Created M3....");
	inheritanceKey firstTuple = <|java+class:///edu/uva/analysis/samples/C|,|java+class:///edu/uva/analysis/samples/C|>;	
	inheritanceList = {<firstTuple, 999 >};
	rel [loc, loc] allInheritanceRelations = getInheritanceRelations(projectM3);
	insertCC_CI_II_FRAMEWORK(allInheritanceRelations);
	getInternalReuseCount(projectM3);
	getNonFrameworkInheritanceRels(projectM3, allInheritanceRelations);
	printResults();
}

