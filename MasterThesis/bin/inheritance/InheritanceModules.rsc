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
		case INTERNAL_REUSE  			: {return "INTERNAL REUSE";}
		case EXTERNAL_REUSE_ACTUAL  	: {return "EXTERNAL REUSE ACTUAL";}
		case EXTERNAL_REUSE_CANDIDATE 	: {return "EXTERNAL REUSE CANDIDATE";}
 		case SUBTYPE  					: {return "SUBTYPE";}
 		case DOWNCALL_ACTUAL  			: {return "DOWNCALL ACTUAL";}
 		case DOWNCALL_CANDIDATE			: {return "DOWNCALL CANDIDATE";}		
 		case CONSTANT					: {return "CONSTANT";}
 		case MARKER						: {return "MARKER";}
 		case SUPER						: {return "SUPER";}
 		case GENERIC		    		: {return "GENERIC";}
 		case CATEGORY		    		: {return "CATEGORY";}
 
 //
 //		case CLASS_CLASS		: {return "CLASS CLASS";}
 //		case CLASS_INTERFACE	: {return "CLASS INTERFACE";}
	//	case INTERFACE_INTERFACE	: {return "INTERFACE INTERFACE";}
//
	//	case NONFRAMEWORK_CC	: {return "NON FRAMEWORK CLASS CLASS";}
	//	case NONFRAMEWORK_CI	: {return "NON FRAMEWORK CLASS INTERFACE";}
	//	case NONFRAMEWORK_II	: {return "NON FRAMEWORK INTERFACE INTERFACE";}
 	}
}


public str getNameOfInheritanceMetric(metricsType iMetric) {
		switch(iMetric) {
		
		case nExplicitCC			: {return "nExplicitCC			";}
		case nCCUsed				: {return "nCCUsed				";}
		case nCCDC					: {return "nCCDC				";}
		case nCCSubtype 		 	: {return "nCCSubtype			";}
		case nCCExreuseNoSubtype 	: {return "nCCExreuseNoSubtype	";}
		case nCCUsedOnlyInRe	 	: {return "nCCUsedOnlyInRe		";}
		case nCCUnexplSuper		 	: {return "nCCUnexplSuper		";}
		case nCCUnExplCategory		: {return "nCCUnExplCategory	";}
		case nCCUnexplSuper			: {return "nCCUnexplSuper		";}
		case nCCUnknown				: {return "nCCUnknown			";}
 	}
}


map [loc, set [loc]] getExtendsAndImplementsMap(projectM3) {
	rel [loc, loc] extendsAndImplementsRel = {<_child, _parent> | <_child, _parent> <- projectM3@extends} + {<_child, _parent> | <_child, _parent> <- projectM3@implements} ;
	return toMap(extendsAndImplementsRel );
}	


public map [loc, set[loc]] getInvertedDescMap(rel [loc, loc] m3Annotation) {
	map [loc, set [loc]] retMap = ();
	rel [loc, loc] extendsRel = {<_child, _parent> | <_child, _parent> <- m3Annotation};
	if (!isEmpty(extendsRel)) {
		retMap = toMap(invert(extendsRel));
	}
	return retMap;
}


public map [loc, set[loc]] getInvertedExtendsAndImplementsMap(M3 projectM3) {
	map [loc, set [loc]] retMap = ();
	rel [loc, loc] extendsAndImplementsRel = {<_child, _parent> | <_child, _parent> <- projectM3@extends} + {<_child, _parent> | <_child, _parent> <- projectM3@implements} ;
	if (!isEmpty(extendsAndImplementsRel)) {
		retMap = toMap(invert(extendsAndImplementsRel));
	}
	return retMap;
}



public map [loc, set[loc]] getInvertedExtendsMap(M3 projectM3) {
	return getInvertedDescMap(projectM3@extends);
}


public map [loc, set[loc]] getInvertedImplementsMap(M3 projectM3) {
	return getInvertedDescMap(projectM3@implements);
}


public map [loc, set[loc]] getInvertedUnitContainment(M3 projectM3) {
	map [loc, set [loc]] retMap = ();
	rel [loc, loc] containmentRel = {<_compUnit, _classOrInt> | <_compUnit, _classOrInt> <- projectM3@containment, isCompilationUnit(_compUnit)};
	if (!isEmpty(containmentRel)) {
		retMap = toMap(invert(containmentRel));
	}
	return retMap;
}


private loc getCompilationUnitOfClassOrInterface(loc aClassOrInt, map [loc, set[loc]] invertedUnitContainment) {
	set [loc] retLocSet = aClassOrInt in invertedUnitContainment ? invertedUnitContainment[aClassOrInt] : {};
	if (size(retLocSet) != 1) {
		throw ("In getCompilationUnitOfClassOrInterface(), the number of elements containing class <aClassOrInt> is <size(retLocSet)>. Set is <retLocSet>");
	}
	return getOneFrom(retLocSet);
}


private loc getFileOfCompilationUnit(loc aUnit, map[loc, set[loc]] declarationsMap) {
	set [loc] fileSet = aUnit in declarationsMap ? declarationsMap[aUnit] : {};
	if (size(fileSet) != 1) {
		throw ("In getFileOfCompilationUnit(), the number of elements containing unit <aUnit> is <size(fileSet)>. Set is <fileSet>");
	}
	return getOneFrom(fileSet);
}


public bool isInnerClass(loc aClass, map [loc, set[loc]] invertedClassAndInterfaceContainment) {
	bool retBool = aClass in invertedClassAndInterfaceContainment ? true : false;
	return retBool;
}



public list [Declaration] getASTsOfAClass(loc aClass, 	map [loc, set[loc]] invertedClassAndInterfaceContainment,
														map [loc, set[loc]] invertedUnitContainment , 
													   	map [loc, set[loc]] declarationsMap) {
	list [Declaration]  astsOfAClass = [];
	// Inner classes are NOT included here, they are already included in the outer classes AST
	if ( !isInnerClass(aClass, invertedClassAndInterfaceContainment) ) {
		loc compUnit = getCompilationUnitOfClassOrInterface(aClass, invertedUnitContainment );
		loc fileOfUnit = getFileOfCompilationUnit(compUnit, declarationsMap);
		Declaration compUnitAST = createAstsFromEclipseFile(fileOfUnit, true);
		visit (compUnitAST) {
			case classDefn:\class(_,_,_,bodies) : {
				if (classDefn@decl == aClass) {
					astsOfAClass += bodies;
				}
			}
			case classDefn:\class(bodies) : {
				if (classDefn@decl == aClass) {
					astsOfAClass += bodies;
				}
			}		
		}
	}
	return astsOfAClass;
}


public map [loc, set [loc]] getInvertedOverrides(M3 projectM3) {
	return toMap(invert({<_childMethod, _parentMethod> | <_childMethod, _parentMethod> <- projectM3@methodOverrides}));
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


public TypeSymbol getTypeSymbolFromSimpleType(Type aType) {
	TypeSymbol returnSymbol = DEFAULT_TYPE_SYMBOL; 
	visit (aType) {
		case sType: \simpleType(typeExpr) : {
			returnSymbol =  typeExpr@typ;
		}
 	}
 	return returnSymbol;
}



public TypeSymbol getTypeSymbolFromRascalType(Type rascalType) {
	TypeSymbol retTypeSymbol = DEFAULT_TYPE_SYMBOL;
 	visit (rascalType) {
 		 // I'm only interested in the simpleType and arrayType at the moment
 		// TODO: I look only in simpleType and ArrayType. How about more complex types like parametrizdeType() 
 		case pType :\parameterizedType(simpleTypeOfParamType) : {
 			retTypeSymbol = getTypeSymbolFromSimpleType(simpleTypeOfParamType);
 		}
 		case sType: \simpleType(typeExpr) : {
 			retTypeSymbol = getTypeSymbolFromSimpleType(sType);
 		}
 		case aType :\arrayType(simpleTypeOfArray) : {
 			retTypeSymbol = getTypeSymbolFromSimpleType(simpleTypeOfArray);
 		}
 
 	}
 	return retTypeSymbol;	
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
	//iprintln("getSubtypeRelation:  child : <childSymbol>, parent: <parentSymbol>."); println();
	if ((iKey.child != DEFAULT_LOC) && (iKey.parent != DEFAULT_LOC) && (iKey.child != iKey.parent)) {
		isSubtypeRel = true;
	}
	return <isSubtypeRel, iKey>;
}


// This method returns the type symbol of a method, constructor or field definition
TypeSymbol getTypeSymbolOfLocDeclaration(loc definedLoc, map [loc, set[TypeSymbol]] typesMap ) {
	set [TypeSymbol] locSymbolSet = definedLoc in typesMap ? typesMap[definedLoc] : {}; 
	if (size(locSymbolSet) != 1) {
		throw("The location <definedLoc> has not exactly one entry in @types annotation.");
	};
	TypeSymbol locTypeSymbol = getOneFrom(locSymbolSet); 
	return locTypeSymbol;
}


//public bool isVarargInDeclaration(loc aMethodLoc, map [loc, set[TypeSymbol]] typesMap) {
//	bool retBool = false;
//	TypeSymbol methodTypeSymbol = getTypeSymbolOfLocDeclaration(aMethodLoc, typesMap);
//	visit (methodTypeSymbol) {
//		case \vararg(_,_) : {
//			retBool = true;
//		}
//	}
//	return retBool;
//}
//

loc getTypeVariableFromTypeSymbol(TypeSymbol aTypeSymbol) {
	loc typeVar = DEFAULT_LOC;
	visit (aTypeSymbol) {
		case _typeParameter:\typeParameter(loc decl, _) : {
			typeVar = decl;
		}
	}
	if (typeVar == DEFAULT_LOC)  { throw "No type variable is found for <aTypeSymbol>"; }
	return typeVar;		
}


list [loc] getTypeVariablesOfRecClass(loc recClassOrInt, map [loc, set [TypeSymbol]] typesMap) {
	TypeSymbol typeSymbolOfLoc = getTypeSymbolOfLocDeclaration(recClassOrInt, typesMap);
	list [TypeSymbol] typeSymbolParList = [];
	list [loc] typeVariablesList = [];
	visit (typeSymbolOfLoc) {
		case aClass:\class(loc decl, list[TypeSymbol] typeParameters) : {
			typeSymbolParList = typeParameters;
		}
		case anInterface:\interface(loc decl, list[TypeSymbol] typeParameters) : {
			typeSymbolParList = typeParameters;
		}		
	}
	for (aTypePar <- typeSymbolParList) {
		typeVariablesList += getTypeVariableFromTypeSymbol(aTypePar);
	}
	//println("Type variables for class : <recClassOrInt>");
	//iprintln(typeVariablesList );
	return typeVariablesList ;
}


map [loc, TypeSymbol] getTypeVariableMap(list [loc] typeVariables, list [TypeSymbol] typeParameters) {
	map [loc, TypeSymbol] retMap = ();
	if (size(typeVariables) != size(typeParameters)) throw "Size of two list differ! Type variables: <typeVariables>, type parameters: <typeParameters> ";
	for (int i <- [0..size(typeVariables)] ) {
		retMap += (typeVariables[i] : typeParameters[i]);
	}
	return retMap;
}


tuple [ loc, list [TypeSymbol]]  getReceivingTypeParameters(TypeSymbol recTypeSymbol) {
	list [TypeSymbol] recTypeParameters = [];
	loc recClassOrInt;
	visit (recTypeSymbol) {
		case classDef:\class(loc decl, list[TypeSymbol] typeParameters) : {
			recTypeParameters = typeParameters;
			recClassOrInt = decl;
		}
		case intDef:\interface(loc decl, list[TypeSymbol] typeParameters) : {
			recTypeParameters = typeParameters;
			recClassOrInt = decl;
		}				
	}
	if (isEmpty(recTypeParameters)) {
		throw "Receiver type parameters is empty for receiver : <receiver>";
	}
	return <recClassOrInt, recTypeParameters>;
}



TypeSymbol resolveGenericTypeSymbol(TypeSymbol genericTypeSymbol, Expression methodOrConstExpr, map [loc, set [TypeSymbol]] typesMap, map[loc, set[loc]] invertedClassAndInterfaceContainment ) {
	loc methodParameterTypeVariable = getTypeVariableFromTypeSymbol(genericTypeSymbol);
	TypeSymbol resolvedTypeSymbol = genericTypeSymbol;
	TypeSymbol recTypeSymbol = DEFAULT_TYPE_SYMBOL;
	switch (methodOrConstExpr) {
		case mCall:\methodCall(_,receiver:_,_,_) : {
			TypeSymbol recTypeSymbol = receiver@typ;
		}
		case mCall:methodCall(_,_,_) : {
			// There can be no subtyping between type parameters, so I do not have to do anything here.
		;}
	//	case newObject1:\newObject(Type \type, list[Expression] expArgs) : {
	//		println("newObject 11111111111 type: <\type>, expArgs : <expArgs>");
	//	}
	//	case newObject2:\newObject(Type \type, list[Expression] expArgs, Declaration class) : {
	//		println("newObject 22222222222 type: <\type>, expArgs : <expArgs>");
	//	}
	//	case newObject3:\newObject(Expression expr, Type \type, list[Expression] expArgs) : {
	//		println("newObject 33333333333 type: <\type>, expArgs : <expArgs>");
	//	}
	//	case newObject4:\newObject(Expression expr, Type \type, list[Expression] expArgs, Declaration class) : {
	//		println("newObject 44444444444 type: <\type>, expArgs : <expArgs>");
	//	}
	}
	//println("Resolved type symbol is: <resolvedTypeSymbol>" );
	//println();
	if (recTypeSymbol != DEFAULT_TYPE_SYMBOL) {
		tuple 	[loc recClassOrInt, list [TypeSymbol] recTypeParameters] result  = getReceivingTypeParameters(recTypeSymbol);  
		list 	[loc] typeVariablesOfRecClass 			= getTypeVariablesOfRecClass(result.recClassOrInt, typesMap);
		map 	[loc, TypeSymbol] typeVariableMap 		= getTypeVariableMap(typeVariablesOfRecClass, result.recTypeParameters);
		resolvedTypeSymbol = typeVariableMap[methodParameterTypeVariable];
	}
	return resolvedTypeSymbol;
}




public list [TypeSymbol] updateTypesWithGenerics(Expression methodOrConstExpr, list [TypeSymbol] typeList, map [loc, set[TypeSymbol]] typesMap, map[loc, set[loc]] invertedClassAndInterfaceContainment  ) {
	list [TypeSymbol] retList = [];
	TypeSymbol currentTypeSymbol = DEFAULT_TYPE_SYMBOL;
	for (_aTypeSymbol <- typeList) {
		currentTypeSymbol = _aTypeSymbol;
		visit (_aTypeSymbol) {
			case aTypePar:\typeParameter(loc decl, Bound upperbound) : {
				currentTypeSymbol = resolveGenericTypeSymbol(_aTypeSymbol, methodOrConstExpr, typesMap, invertedClassAndInterfaceContainment );	
			} 
		}
		retList += currentTypeSymbol;
	}
	return retList;
}


public list [TypeSymbol] getDeclaredParameterTypes (Expression methodOrConstExpr, map [loc, set[TypeSymbol]] typesMap, map[loc, set[loc]] invertedClassAndInterfaceContainment ) {
	list [TypeSymbol] retTypeList 	= [];
	list [TypeSymbol] methodParameterTypes = [];
	loc methodLoc 					= methodOrConstExpr@decl;
	TypeSymbol methodTypeSymbol = getTypeSymbolOfLocDeclaration(methodLoc, typesMap);
	visit (methodTypeSymbol) {
		case \method(_, _, _, typeParameters:_) : {
			methodParameterTypes = typeParameters;
		}
		case cons:\constructor(_, typeParameters:_) : {
			//println("Type parameters for constructor: <cons>");
			methodParameterTypes = typeParameters;
		}
	}
	retTypeList = updateTypesWithGenerics(methodOrConstExpr, methodParameterTypes, typesMap, invertedClassAndInterfaceContainment);
	//println();
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



