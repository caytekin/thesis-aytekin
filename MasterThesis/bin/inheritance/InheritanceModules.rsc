module inheritance::InheritanceModules

import IO;
import Map;
import Set;
import Relation;
import List;
import ListRelation;
import ValueIO;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import inheritance::InheritanceDataTypes;


loc getDefiningClassOfMethod(loc aMethod, M3 projectM3) {
	set [loc] resultSet = {dClass | <dClass, dMethod> <- projectM3@containment, 
    																dMethod == aMethod};
	if (size(resultSet) != 1) {
		throw "Number of defining classes for method <aMethod> is not one. Classes: <resultSet>";
	}
	else {
		return getOneFrom(resultSet);
	}
}


public bool isMethodInProject(loc methodPar, M3 projectM3) {
	return ! isEmpty({<aMethod> | <aClass, aMethod> <- projectM3@containment, aMethod == methodPar});
}



public rel [loc, loc] getNonFrameworkInheritanceRels(rel [loc, loc] inheritanceRels, M3 projectM3) {
	set [loc] allTypesInM3 = {decl | <decl, prjct> <- projectM3@declarations, 
														isClass(decl) || isInterface(decl)};
	return {<child, parent> | <child, parent> <- inheritanceRels, parent in allTypesInM3 };
}




public rel [loc, loc]  getInheritanceRelations(M3 projectM3) {
	allInheritanceRel = projectM3@extends + projectM3@implements; 
	// TODO: make a list of candidates for sideways cast.
	map [inheritanceKey, inheritanceType] inheritanceMap; 
	// I use the transitive closure to see the transitive inheritance relationships between
	// classes and interfaces. 
	return allInheritanceRel+;
}

//returns all the classes defined in the project.
public set [loc] getAllClassesInProject(M3 projectM3) {
	return {decl | <decl, prjct> <- projectM3@declarations, isClass(decl) };
}

//returns all the classes and interfaces defined in the project.
public set [loc]  getAllClassesAndInterfacesInProject(M3 projectM3) {
	return {decl | <decl, prjct> <- projectM3@declarations, isClass(decl) || isInterface(decl) };
}



public bool inheritanceRelationExists(loc class1, loc class2, M3 projectM3) {
	rel [loc, loc] allInheritanceRelations = getInheritanceRelations(projectM3);
	set [loc] relationSet = {child	| <child, parent> <- allInheritanceRelations, 
													(class1 == child && class2 == parent) ||
													(class1 == parent && class2 == parent) }; 
	return !isEmpty(relationSet);
}


public loc getClassFromTypeSymbol(TypeSymbol typeSymbol) {
	loc classLoc = DEFAULT_LOC;
	visit (typeSymbol) {
    	case c:\class(cLoc,_) : {
    		classLoc = cLoc;  	
    	}
    };
    return classLoc;
}


public loc getInterfaceFromTypeSymbol(TypeSymbol typeSymbol) {
	loc interfaceLoc = DEFAULT_LOC;
	visit (typeSymbol) {
    	case i:\interface(iLoc,_) : {
    		interfaceLoc = iLoc;  	
    	}
    };
    return interfaceLoc;
}




public loc getClassOrInterfaceFromTypeSymbol(TypeSymbol typeSymbol) {
	loc classOrInterfaceLoc = DEFAULT_LOC;
	classOrInterfaceLoc = getClassFromTypeSymbol(typeSymbol);
	if ( classOrInterfaceLoc == DEFAULT_LOC) {
		classOrInterfaceLoc= getInterfaceFromTypeSymbol(typeSymbol);
    };
    return classOrInterfaceLoc;
}



public inheritanceKey getInheritanceKeyFromTwoTypes(list [loc] twoTypes, rel [loc, loc] inhRelations , M3 projectM3) {
	rel [loc, loc] returnSet = { <from, to> | <from, to> <- inhRelations , 
												(from == twoTypes[0] 	&&  to == twoTypes[1]) ||
												(from == twoTypes[1] 	&& 	to == twoTypes[0]) };
	if (size(returnSet) != 1) {
		throw ("Size of list different from 1 for list: <twoTypes> in get inheritance key. Size of list is: <size(returnSet) >");
	}								
	return getOneFrom(returnSet);								
}


public void printSubtypeLog() {
	//lrel [inheritanceKey, subtypeViaAssignmentASTLoc] subtypeASTLog 
	value val = readTextValueFile(subtypeASTLogFile);
	//rel [inheritanceKey iKey, loc subtypeDetailLoc, int inheritanceSubtype] logRelation = val;
	println("SUBTYPE LOG"); 
	iprintln(sort(val));
	//

	
}


