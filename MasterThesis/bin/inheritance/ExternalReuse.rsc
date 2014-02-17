module inheritance::ExternalReuse

import IO;
import Map;
import Set;
import Relation;
import List;
import ListRelation;
import Node;
import ValueIO;

import lang::java::m3::Core;
import lang::java::m3::AST;
import lang::java::jdt::m3::Core;
import lang::java::m3::TypeSymbol;

import inheritance::InheritanceDataTypes;
import inheritance::InheritanceModules;



public rel [inheritanceKey, inheritanceType] getExternalReuseCases(M3 projectM3) {
	// TODO: I should also detect the external reuse via field access, but I have a problem 
	// there, AST fieldAccess(_,_,) only detects field accesses via this(). !!!!!
	//
	// Decision: The external reuse cases are only about classes, see assumptions and decisions document.
	rel 	[inheritanceKey, inheritanceType] resultRel = {<<|java+class:///|,|java+class:///|>, 999>};
	lrel 	[inheritanceKey, externalReuseDetail] externalReuseLog = [<<|java+class:///|,|java+class:///|>,<|java+method:///|,|java+method:///|>>]; 
	set		[loc] allClassesInProject = {decl | <decl, prjct> <- projectM3@declarations, isClass(decl) };
	for (oneClass <- allClassesInProject) {
		set [loc] methodsInClass = {declared | <owner,declared> <- projectM3@containment, 
																owner == oneClass, 
																isMethod(declared) }; 
		// TODO:take also initializers in to account  
		// || getMethodASTEclipse does not work for initializers. declared.scheme == "java+initializer" 
		for (oneMethod <- methodsInClass) {
			methodAST = getMethodASTEclipse(oneMethod, model = projectM3);	
			visit(methodAST) {
				case m2:\methodCall(_, receiver:_, _, _): {
        			loc invokedMethod = m2@decl;        			
        			loc typeOfVariable = getClassFromTypeSymbol(receiver@typ);
        			// I am only interested in the classes and not interfaces, enums, etc.
        			// I am not interested in this() and also variables of oneClass
        			if (isClass(typeOfVariable) && (typeOfVariable != oneClass) && 
        				isMethodInProject(invokedMethod, projectM3) && ! inheritanceRelationExists(oneClass, typeOfVariable, projectM3)) {
    					// for external reuse, the invokedMethod should not be declared in the 
    					// class typeOfVariable
    					loc methodDefiningClass = getDefiningClassOfMethod(invokedMethod, projectM3);
    					if ( methodDefiningClass != typeOfVariable ) {
    						// external reuse!
    						inheritanceKey iKey = <typeOfVariable, methodDefiningClass >;
							resultRel  += < iKey, EXTERNAL_REUSE>;
							externalReuseLog += <iKey, <invokedMethod, oneMethod>>;
    					};
        			}; // if inheritanceRelationExists
        		} // case methodCall()
        	} // visit()
		};	// for each method in the class															
	};	// for each class in the project
	iprintToFile(externalReuseLogFile, externalReuseLog);
	return resultRel;
}

