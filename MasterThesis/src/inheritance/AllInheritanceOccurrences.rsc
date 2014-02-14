module inheritance::AllInheritanceOccurrences


import IO;
import Map;
import Set;
import Relation;
import List;
import ListRelation;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import inheritance::InheritanceDataTypes;
import inheritance::InheritanceModules;
import inheritance::InternalReuse;
import inheritance::ExternalReuse;



// TODO: introduce log mechanism

// TODO: I can put different functionality into different Rascal modules.




private rel [inheritanceKey, inheritanceType] getCC_CI_II_FR_Relations (rel [loc child, loc parent] inheritRelation) {
	rel [inheritanceKey, inheritanceType] CC_CI_II_FR_Relations = {<<|java+class:///|,|java+class:///|>, 999>};
	rel [loc, loc] allClassClass = {<child, parent> | <child, parent> <- inheritRelation, isClass(child), isClass(parent)};	
	for (<child, parent> <- allClassClass ) { CC_CI_II_FR_Relations += <<child, parent>, CLASS_CLASS>;	};
	rel [loc, loc] allClassInterface = {<child, parent> | <child, parent> <- inheritRelation, isClass(child), isInterface(parent)};
	for (<child, parent> <- allClassInterface ) { CC_CI_II_FR_Relations += <<child,parent>, CLASS_INTERFACE>; };
	rel [loc, loc] allInterfaceInterface = {<child, parent> | <child, parent> <- inheritRelation, isInterface(child), isInterface(parent)};
	for (<child, parent> <- allInterfaceInterface ) { CC_CI_II_FR_Relations += <<child,parent>, INTERFACE_INTERFACE>; };
	return CC_CI_II_FR_Relations;
	// TODO : Also insert framework inheritance relations
}






private void printResults(rel [inheritanceKey, inheritanceType] inheritanceResults	) {
	println("Number of CC edges:  <size({inhItem | <inhItem, inhType> <- inheritanceResults, inhType == CLASS_CLASS})>"); 
	println("Number of CI edges:  <size({inhItem | <inhItem, inhType> <- inheritanceResults, inhType == CLASS_INTERFACE})>"); 
	println("Number of II edges:  <size({inhItem | <inhItem, inhType> <- inheritanceResults, inhType == INTERFACE_INTERFACE})>"); 
	println("Number of internal reuse edges:  <size({inhItem | <inhItem, inhType> <- inheritanceResults, inhType == INTERNAL_REUSE})>"); 
	println("Number of external reuse edges:  <size({inhItem | <inhItem, inhType> <- inheritanceResults, inhType == EXTERNAL_REUSE})>"); 
	
	print("Internal reuse edges: ");	
	iprintln(sort({inhItem | <inhItem, inhType> <- inheritanceResults, inhType == INTERNAL_REUSE}));
	
	print("External reuse edges: ");	
	iprintln(sort({inhItem | <inhItem, inhType> <- inheritanceResults, inhType == EXTERNAL_REUSE}));
	
}



public void runIt() {
	rel [inheritanceKey, int] allInheritanceCases;	
	println("Creating M3....");
	M3 projectM3 = createM3FromEclipseProject(|project://InheritanceSamples|);
	println("Created M3....");
	rel [loc, loc] allInheritanceRelations = getInheritanceRelations(projectM3);
	allInheritanceCases = getCC_CI_II_FR_Relations (allInheritanceRelations);
	allInheritanceCases += getInternalReuseCases(projectM3);
	allInheritanceCases += getExternalReuseCases(projectM3);	
	getNonFrameworkInheritanceRels(projectM3, allInheritanceRelations);
	printResults(allInheritanceCases);
}

