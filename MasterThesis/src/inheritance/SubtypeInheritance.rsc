module inheritance::SubtypeInheritance

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




private rel [inheritanceKey, inheritanceType] getSubtypeViaAssignmentFromTypeDef(M3 projectM3) {
	rel [inheritanceKey, inheritanceType] resultRel = {<<DEFAULT_LOC, DEFAULT_LOC>, INITIAL_TYPE>};	
	lrel [inheritanceKey, subtypeViaAssignmentTypeDef] subtypeLog = [<<DEFAULT_LOC,DEFAULT_LOC>,<DEFAULT_LOC,INITIAL_TYPE>>]; 
	set [loc] allClassesAndInterfacesInProject = getAllClassesAndInterfacesInProject(projectM3);
	rel [loc, loc] subtypeAssignmentTypeDef = { <from, to> | <from, to> <- projectM3@typeDependency,
																isVariable(from), 
																to in allClassesAndInterfacesInProject, 
																isClass(to) || isInterface(to) };
	rel [loc, loc] all_CC_CI_II_NonFR_rels = getNonFrameworkInheritanceRels(getInheritanceRelations(projectM3), projectM3);	
	map [loc, set [loc] ] mapTypeDef = toMap(subtypeAssignmentTypeDef); 															
	map [loc, set [loc] ] varsAndClasses = (typeDef : mapTypeDef[typeDef] | typeDef <- mapTypeDef , size(mapTypeDef[typeDef]) == 2);
	for (loc aVariable <- varsAndClasses) {
		inheritanceKey iKey = getInheritanceKeyFromTwoTypes(toList(varsAndClasses[aVariable]), all_CC_CI_II_NonFR_rels, projectM3); 
		resultRel  += <iKey, SUBTYPE>;
		subtypeLog += <iKey, <aVariable, SUBTYPE_ASSIGNMENT_TYPE_DEPENDENCY>>;
	} // for
	iprintToFile(subtypeTypeDepLogFile, subtypeLog);
	return resultRel;
}






private rel [inheritanceKey, inheritanceType] getSubtypeViaAssignmentFromAST(M3 projectM3) {
	rel [inheritanceKey, inheritanceType] resultRel = {<<DEFAULT_LOC, DEFAULT_LOC>, INITIAL_TYPE>};
	lrel [inheritanceKey, subtypeViaAssignmentASTLoc] subtypeLog = [<<DEFAULT_LOC,DEFAULT_LOC>,<DEFAULT_LOC,INITIAL_TYPE>>]; 
	set [loc] allClassesAndInterfacesInProject = getAllClassesAndInterfacesInProject(projectM3);
	set [loc] allClassesInProject = getAllClassesAndInterfacesInProject(projectM3);
	for (oneClass <- allClassesInProject) {
		set [loc] methodsInClass = {declared | <owner,declared> <- projectM3@containment, 
																owner == oneClass, 
																isMethod(declared) }; 
		// TODO:take also initializers in to account  
		// || getMethodASTEclipse does not work for initializers. declared.scheme == "java+initializer" 
		for (oneMethod <- methodsInClass) {
			methodAST = getMethodASTEclipse(oneMethod, model = projectM3);	
			visit(methodAST) {
				case aStmt:\assignment(lhs, operator, rhs) : {  
		        	// 	\assignment(Expression lhs, str operator, Expression rhs)
		        	loc lhsClass = getClassOrInterfaceFromTypeSymbol(lhs@typ);
		        	loc rhsClass = getClassOrInterfaceFromTypeSymbol(rhs@typ);
					if (lhsClass != rhsClass) {
						if ( (lhsClass in allClassesAndInterfacesInProject) && (rhsClass in allClassesAndInterfacesInProject)) {
							inheritanceKey iKey = <rhsClass, lhsClass>;
							resultRel  += < iKey, SUBTYPE>;
							subtypeLog += <iKey, <aStmt@src, SUBTYPE_ASSIGNMENT_AST>>;
						}
					}		
				} // case
        	} // visit()
		};	// for each method in the class															
	};	// for each class in the project
	iprintToFile(subtypeASTLogFile, subtypeLog);
	return resultRel;
}



private rel [inheritanceKey, inheritanceType] getSubtypeViaAssignment(M3 projectM3) {
	rel [inheritanceKey, inheritanceType] resultRel = {<<DEFAULT_LOC, DEFAULT_LOC>, INITIAL_TYPE>};
	resultRel += getSubtypeViaAssignmentFromAST(projectM3);
	resultRel += getSubtypeViaAssignmentFromTypeDef(projectM3);
	return resultRel;
}



public rel [inheritanceKey, inheritanceType] getSubtypeCases(M3 projectM3) {
	rel [inheritanceKey, inheritanceType] resultRel = {<<DEFAULT_LOC, DEFAULT_LOC>, INITIAL_TYPE>};
	resultRel += getSubtypeViaAssignment(projectM3);
	return resultRel;
}

