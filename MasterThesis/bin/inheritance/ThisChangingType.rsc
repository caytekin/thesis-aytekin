module inheritance::ThisChangingType

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
import lang::java::jdt::m3::AST;
import lang::java::m3::TypeSymbol;

import inheritance::InheritanceDataTypes;
import inheritance::InheritanceModules;



private tuple [bool, loc] methodRefersToThisChangingType(loc ascClass, loc descClass, loc aMethodOfAscClass, M3 projectM3) {
	bool retBool = false;
	methodAST = getMethodASTEclipse(aMethodOfAscClass, model = projectM3);
	visit (methodAST) {
		case methExpr1:\methodCall(_,_,_) : {
			println("A method call.....1111111 at <methExpr1@src>");
		;}
		case methExpr2:\methodCall(_,_,_,_) : {
			println("A method call.....2222222 at <methExpr2@src>");
		;}
		case aStmt:\assignment(lhs, operator, rhs) : {
			println("Assignment statement!!!!!!!!!!!!!!!!!!!!!!!!");
			println(rhs);
			if (rhs := this()) {
				println("Right hand side is this...!!!!!!!!!!!!!!!!!!!");
				TypeSymbol lhsTypeSymbol = lhs@typ;
				loc lhsClass = getClassFromTypeSymbol(lhsTypeSymbol);	
				if (lhsClass == ascClass) {
					println("A match is found!!!! lhsClass is ascClass: <lhsClass>");
				;}
			}
		;}
		case variables : \variables(typeOfVar, fragments) : {
		// TODO !!!!!!!!!!!!!!!!!!!!!!!
		;} 
	}
	return <retBool, |java+project://InheritanceSamples|>;
}


private rel [loc, loc, loc, loc] getThisChangingTypeCandidates(M3 projectM3) {
	// I only look for class - class relationships
	rel [loc _desc, loc _asc] 	allInheritanceRels = getNonFrameworkInheritanceRels(getInheritanceRelations(projectM3), projectM3);
	map [loc, set[loc]] 		ascDescPair = toMap(invert({<_desc, _asc> | <_desc, _asc> <- allInheritanceRels, isClass(_desc), isClass(_asc)}));
	map [loc, set [loc]]		methodsInClasses = toMap({<_aClass, _aMethod> | <_aClass, _aMethod> <- projectM3@containment, isClass(_aClass), isMethod(_aMethod)});
	map [loc, set[loc]] 		invertedContainment = getInvertedClassAndInterfaceContainment(projectM3);
	map [loc, set[loc]]			methodClassContainment = toMap({<_aClass, _aMethod> | <_aClass, _aMethod> <- projectM3@containment, isClass(_aClass), isMethod(_aMethod)});
	for (ascClass <- ascDescPair) {
		set [loc] allMethodsOfAscClass =  ascClass in methodClassContainment ? methodClassContainment[ascClass] : {}; 
		for (aMethodOfAscClass <- allMethodsOfAscClass) {
			set [loc] allDescClassesOfAscClass = ascDescPair[ascClass];
			for (descClass <- ascDescPair[ascClass]) {
				if (!isMethodOverriddenByDescClass(aMethodOfAscClass, descClass, invertedContainment, projectM3)) {
					//println("Method <aMethodOfAscClass> in asc class: <ascClass> is not overridden by descClass : <descClass>");
					methodRefersToThisChangingType(ascClass, descClass, aMethodOfAscClass, projectM3); 
				} // if
			}	// for descClass
		} // for  aMethodOfAscClass
	} // for ascClass
	return {}; 
}


public rel [inheritanceKey, inheritanceType] getThisChangingTypeOccurrences() {
	println("Creating M3...");
	M3 projectM3 = createM3FromEclipseProject(|project://InheritanceSamples|);
	println("Created M3.");
	getThisChangingTypeCandidates(projectM3);
	return {};
}