module inheritance::InheritanceModules

import IO;
import Map;
import Set;
import Relation;
import List;
import ListRelation;
import ValueIO;
import Node;
import util::ValueUI;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import lang::java::jdt::m3::AST;
import lang::java::m3::TypeSymbol;

import inheritance::InheritanceDataTypes;


public list [loc] getAscendantsInOrder(loc childClass, M3 projectM3){
	set [loc] immediateParentSet = {parent | <child, parent> <- projectM3@extends, child == childClass, 
																				isClass(child), isClass(childClass)};
	if (isEmpty(immediateParentSet)) {
		return [];
	}
	if (size(immediateParentSet) > 1) {
		throw ("getAscendantsInOrder, <childClass> has more than one parent in @extends annotation.");
	}
	return [getOneFrom(immediateParentSet)] + getAscendantsInOrder(getOneFrom(immediateParentSet), projectM3);
}


public loc getDefiningClassOfALoc(loc aLoc, M3 projectM3) {
	set [loc] resultSet = {dClass | <dClass, dLocation> <- projectM3@containment, 
    																dLocation == aLoc};
	if (size(resultSet) != 1) {
		throw "Number of defining classes for location <aLoc> is not one. Classes: <resultSet>";
	}
	else {
		return getOneFrom(resultSet);
	}
}


public bool isLocDefinedInProject(loc locPar, M3 projectM3) {
	return ! isEmpty({<aLoc> | <aLoc, aProject> <- projectM3@declarations, aLoc == locPar});
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

public tuple [bool, inheritanceKey] getSubtypeRelation(TypeSymbol childSymbol, TypeSymbol parentSymbol) {
	bool isSubtypeRel = false;
	inheritanceKey iKey = <DEFAULT_LOC, DEFAULT_LOC>;
	iKey.parent = getClassOrInterfaceFromTypeSymbol(parentSymbol);
	iKey.child = getClassOrInterfaceFromTypeSymbol(childSymbol);
	if ((iKey.child != DEFAULT_LOC) && (iKey.parent != DEFAULT_LOC) && (iKey.child != iKey.parent)) {
		isSubtypeRel = true;
	}
	return <isSubtypeRel, iKey>;
}

// This method returns the type symbol of a method or field definition
TypeSymbol getTypeSymbolOfLocDeclaration(loc definedLoc, M3 projectM3) {
	set [TypeSymbol] locSymbolSet = {to | <from, to> <- projectM3@types, from == definedLoc};
	if (size(locSymbolSet) != 1) {
		throw("The location <definedLoc> has not exactly one entry in @types annotation.");
	};
	TypeSymbol locTypeSymbol = getOneFrom(locSymbolSet); 
	return locTypeSymbol;
}


public list [TypeSymbol] getDeclaredParameterTypes (loc methodLoc, M3 projectM3) {
	list [TypeSymbol] retTypeList = [];
	TypeSymbol methodTypeSymbol = getTypeSymbolOfLocDeclaration(methodLoc, projectM3);
	visit (methodTypeSymbol) {
		case \method(_, _, _, typeParameters:_) : {
			retTypeList = typeParameters;
		}
	}
	return retTypeList;
}

public TypeSymbol getDeclaredReturnTypeOfMethod(loc methodLoc, M3 projectM3) {
	TypeSymbol retSymbol = DEFAULT_TYPE_SYMBOL;
	TypeSymbol methodTypeSymbol = getTypeSymbolOfLocDeclaration(methodLoc, projectM3);
	visit (methodTypeSymbol) {
	// \method(loc decl, list[TypeSymbol] typeParameters, TypeSymbol returnType, list[TypeSymbol] parameters)
		case \method(_, _, returnType,  _) : {
			retSymbol = returnType;
		}
	} // visit
	return retSymbol;
}

public void printLog(loc logFile, str header) {
	value val = readTextValueFile(logFile);
	println(header); 
	iprintln(sort(val));	
}



