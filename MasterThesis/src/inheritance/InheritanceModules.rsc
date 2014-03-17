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


public str getNameOfInheritanceType(inheritanceType iType) {
		switch(iType) {
		case INTERNAL_REUSE  	: {return "INTERNAL REUSE";}
		case EXTERNAL_REUSE  	: {return "EXTERNAL REUSE";}
 		case SUBTYPE  			: {return "SUBTYPE";}
 		case DOWNCALL  			: {return "DOWNCALL";}
 		case CONSTANT			: {return "CONSTANT";}
 		case MARKER				: {return "MARKER";}
 		case SUPER				: {return "SUPER";}
 		case GENERIC		    : {return "GENERIC";}
 
 		case CLASS_CLASS		: {return "CLASS CLASS";}
 		case CLASS_INTERFACE	: {return "CLASS INTERFACE";}
		case INTERFACE_INTERFACE	: {return "INTERFACE INTERFACE";}

		case NONFRAMEWORK_CC	: {return "NON FRAMEWORK CLASS CLASS";}
		case NONFRAMEWORK_CI	: {return "NON FRAMEWORK CLASS INTERFACE";}
		case NONFRAMEWORK_II	: {return "NON FRAMEWORK INTERFACE INTERFACE";}
 	}
}


public map [loc, set[loc]] getInvertedClassAndInterfaceContainment(M3 projectM3) {
	map [loc, set [loc]] retMap = ();
	rel [loc, loc] containmentRel = {<dClass, dLoc> | <dClass, dLoc> <- projectM3@containment, isClass(dClass) || isInterface(dClass) || dClass.scheme == "java+anonymousClass" };
	if (!isEmpty(containmentRel)) {
		retMap = toMap(invert(containmentRel));
	}
	return retMap;
}


public set [loc] getClassesWhichOverrideAMethod(loc aMethod, map [loc, set[loc]] invertedContainment, M3 projectM3) {
	set [loc] retSet = {};
	set [loc] overridingMethods = {descMeth | <descMeth, ascMeth> <- projectM3@methodOverrides, ascMeth == aMethod};
	for (overridingMethod <- overridingMethods) {
		retSet += getDefiningClassOfALoc(overridingMethod, invertedContainment);
	}
	return retSet;
}


public bool isMethodOverriddenByDescClass(loc issuerMethod, loc descClass, map[loc, set[loc]] invertedContainment,  M3 projectM3) {
	bool retBool = false;
	set [loc] classesThatOverrideTheMethod = getClassesWhichOverrideAMethod(issuerMethod, invertedContainment, projectM3);
	if (descClass in classesThatOverrideTheMethod ) {
		retBool = true;
	}
	return retBool;
}


public set [loc] getDescendantsOfAClass(loc aClass, rel [loc,loc] allInheritanceRels) {
	return {child | <child, parent> <- allInheritanceRels, parent == aClass};
}


public list [loc] getAscendantsInOrder(loc childClass, map [loc, set[loc]] extendsMap) {
	set [loc] immediateParentSet = childClass in extendsMap ? extendsMap[childClass] : {};
	if (isEmpty(immediateParentSet)) {
		return [];
	}
	if (size(immediateParentSet) > 1) {
		throw ("getAscendantsInOrder, <childClass> has more than one parent in @extends annotation.");
	}
	return [getOneFrom(immediateParentSet)] + getAscendantsInOrder(getOneFrom(immediateParentSet), extendsMap);
}


public loc getDefiningClassOrInterfaceOfALoc(loc aLoc, map [loc, set[loc]] invertedClassAndInterfaceContainment) {
	set [loc] resultSet = aLoc in invertedClassAndInterfaceContainment ? invertedClassAndInterfaceContainment[aLoc] : {};
	if (size(resultSet) != 1) {
		throw "Number of defining classes or interfaces for location <aLoc> is not one, but <size(resultSet)>. Classes: <resultSet>";
	}
	else {
		return getOneFrom(resultSet);
	}
}





public loc getDefiningClassOfALoc(loc aLoc, map [loc, set[loc]] invertedContainment) {
	set [loc] resultSet = aLoc in invertedContainment ? invertedContainment[aLoc] : {};
	if (size(resultSet) != 1) {
		throw "Number of defining classes for location <aLoc> is not one. Classes: <resultSet>";
	}
	else {
		return getOneFrom(resultSet);
	}
}


public bool isLocDefinedInProject(loc locPar, map [loc, set[loc]] declarationsMap ) {
	bool retBool = (locPar in declarationsMap) ?  true : false;
	return retBool;
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


public set [loc] getAllInterfacesInProject(M3 projectM3) {
	return {decl | <decl, prjct> <- projectM3@declarations, isInterface(decl) };
}


//returns all the classes and interfaces defined in the project.
public set [loc]  getAllClassesAndInterfacesInProject(M3 projectM3) {
	return {decl | <decl, prjct> <- projectM3@declarations, isClass(decl) || isInterface(decl) };
}


public bool inheritanceRelationExists(loc class1, loc class2, rel [loc, loc] allInheritanceRelations) {
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
	visit (typeSymbol) {
		case c:\class(cLoc,_) : {
    		classOrInterfaceLoc = cLoc;  			
		}
    	case i:\interface(iLoc,_) : {
    		classOrInterfaceLoc = iLoc;  	
    	}
    }
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
TypeSymbol getTypeSymbolOfLocDeclaration(loc definedLoc, map [loc, set[TypeSymbol]] typesMap ) {
	set [TypeSymbol] locSymbolSet = definedLoc in typesMap ? typesMap[definedLoc] : {}; 
	if (size(locSymbolSet) != 1) {
		throw("The location <definedLoc> has not exactly one entry in @types annotation.");
	};
	TypeSymbol locTypeSymbol = getOneFrom(locSymbolSet); 
	return locTypeSymbol;
}


public list [TypeSymbol] getDeclaredParameterTypes (loc methodLoc, map [loc, set[TypeSymbol]] typesMap ) {
	list [TypeSymbol] retTypeList = [];
	TypeSymbol methodTypeSymbol = getTypeSymbolOfLocDeclaration(methodLoc, typesMap);
	visit (methodTypeSymbol) {
		case \method(_, _, _, typeParameters:_) : {
			retTypeList = typeParameters;
		}
	}
	return retTypeList;
}


public TypeSymbol getDeclaredReturnTypeSymbolOfMethod(loc methodLoc, map [loc, set[TypeSymbol]] typesMap ) {
	TypeSymbol retSymbol = DEFAULT_TYPE_SYMBOL;
	TypeSymbol methodTypeSymbol = getTypeSymbolOfLocDeclaration(methodLoc, typesMap);
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



