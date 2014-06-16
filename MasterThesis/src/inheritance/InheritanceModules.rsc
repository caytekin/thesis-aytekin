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
		case EXTERNAL_REUSE				: {return "EXTERNAL REUSE";}
 		case SUBTYPE  					: {return "SUBTYPE";}
 		case DOWNCALL_ACTUAL  			: {return "DOWNCALL ACTUAL";}
 		case DOWNCALL_CANDIDATE			: {return "DOWNCALL CANDIDATE";}		
 		case CONSTANT					: {return "CONSTANT";}
 		case MARKER						: {return "MARKER";}
 		case SUPER						: {return "SUPER";}
 		case GENERIC		    		: {return "GENERIC";}
 		case CATEGORY		    		: {return "CATEGORY";}
 		case FRAMEWORK 					: {return "FRAMEWORK";}
 		case DOWNCALL 		    		: {return "DOWNCALL";}
  		
 		default 						: {return "NOT KNOWN INHERITANCE TYPE: <iType>"; }
 	}
}


public str getNameOfInheritanceMetric(metricsType iMetric) {
		switch(iMetric) {
		
		case numExplicitCC				: {return "numExplicitCC";}
		case numCCUsed					: {return "numCCUsed";}
		case perCCUsed					: {return "perCCUsed";}
		case numCCDC					: {return "numCCDC";}
		case perCCDC					: {return "perCCDC";}
		case numCCSubtype 		 		: {return "numCCSubtype";}
		case perCCSubtype 		 		: {return "perCCSubtype";}
		case numCCExreuseNoSubtype 		: {return "numCCExreuseNoSubtype";}
		case perCCExreuseNoSubtype 		: {return "perCCExreuseNoSubtype";} 		
		case numCCUsedOnlyInRe	 		: {return "numCCUsedOnlyInRe";}
		case perCCUsedOnlyInRe	 		: {return "perCCUsedOnlyInRe";}
		case numCCUnexplSuper		 	: {return "numCCUnexplSuper";}
		case perCCUnexplSuper		 	: {return "perCCUnexplSuper";}
		case numCCUnexplCategory		: {return "numCCUnExplCategory";}
		case perCCUnexplCategory		: {return "perCCUnExplCategory";}
		case numCCUnexplSuper			: {return "numCCUnexplSuper";}
		case perCCUnexplSuper			: {return "perCCUnexplSuper";}
		case numCCUnknown				: {return "numCCUnknown";}
		case perCCUnknown				: {return "perCCUnknown";}		
		
		case numExplicitCI				: {return "numExplicitCI";}			
  		case numOnlyCISubtype			: {return "numOnlyCISubtype";}
  		case perOnlyCISubtype			: {return "perOnlyCISubtype";}
  		case numExplainedCI				: {return "numExplainedCI";}
  		case perExplainedCI				: {return "perExplainedCI";}
  		case numCategoryExplCI			: {return "numCategoryExplCI";}
 		case perCategoryExplCI			: {return "perCategoryExplCI";}
  		case numUnexplainedCI			: {return "numUnexplainedCI";}
  		case perUnexplainedCI			: {return "perUnexplainedCI";}
  		
  		
  		case  numExplicitII				: {return "numExplicitII";}
		case  numIISubtype				: {return "numIISubtype";}
		case  perIISubtype				: {return "perIISubtype";}
		case  numOnlyIIReuse			: {return "numOnlyIIReuse";}
		case  perOnlyIIReuse			: {return "perOnlyIIReuse";}
		case  numExplainedII			: {return "numExplainedII";}
		case  perExplainedII			: {return "perExplainedII";}
		case  numCategoryExplII			: {return "numCategoryExplII";}
		case  perCategoryExplII			: {return "perCategoryExplII";}
		case  numUnexplainedII			: {return "numUnexplainedII";}
		case  perUnexplainedII			: {return "perUnexplainedII";}
  		
		
		default 						: {return "NOT KNOWN METRIC: <iMetric>"; }
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
	else // TODO !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	return getOneFrom(retLocSet);
}


private loc getFileOfCompilationUnit(loc aUnit, map[loc, set[loc]] declarationsMap) {
	set [loc] fileSet = aUnit in declarationsMap ? declarationsMap[aUnit] : {};
	if (size(fileSet) != 1) {
		throw ("In getFileOfCompilationUnit(), the number of elements containing unit <aUnit> is <size(fileSet)>. Set is <fileSet>");
	}
	return getOneFrom(fileSet);
}


public bool isInnerClass(loc aClass, map [loc, set[loc]] invertedClassInterfaceMethodContainment) {
	bool retBool = aClass in invertedClassInterfaceMethodContainment ? true : false;
	return retBool;
}



public list [Declaration] getASTsOfAClass(loc aClass, 	map [loc, set[loc]] invertedClassInterfaceMethodContainment,
														map [loc, set[loc]] invertedUnitContainment , 
													   	map [loc, set[loc]] declarationsMap) {
	list [Declaration]  astsOfAClass = [];
	// Inner classes are NOT included here, they are already included in the outer classes AST
	if ( !isInnerClass(aClass, invertedClassInterfaceMethodContainment) ) {
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


public map [loc, set[loc]] getInvertedClassInterfaceMethodContainment(M3 projectM3) {
	map [loc, set [loc]] retMap = ();
	rel [loc, loc] containmentRel = {<_container, _dLoc> | <_container, _dLoc> <- projectM3@containment, isClass(_container) || isInterface(_container) || _container.scheme == "java+anonymousClass" || isMethod(_container) };
	if (!isEmpty(containmentRel)) {
		retMap = toMap(invert(containmentRel));
	}
	return retMap;
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


private set [loc] getInBetweenClasses(loc ascClass, loc descClass, map[loc, set[loc]] extendsMap) {
	//println("Extends map: <extendsMap>");
	set  [loc] 	allInBetweenClasses = {}; 
	list [loc] 	ascendantsInOrder = getAscendantsInOrder(descClass, extendsMap);
	//println("Ascendants in order: <ascendantsInOrder>");
	bool ascClassFound = false;
	int i = 0;
	while ((!ascClassFound) && (i < size(ascendantsInOrder))) {
		loc anAscendant = ascendantsInOrder[i];
		//println("An ascendant: <anAscendant>");
		if (anAscendant == ascClass) {
			//println("Equality is true...");
			ascClassFound = true;
		}
		else {
			allInBetweenClasses += anAscendant;
		}
		i += 1;
	}
	//println("ascClassFound is: <ascClassFound>");
	if (!ascClassFound) { throw "Ascending class <ascClass> is not found in the Ascendants list of class: <descClass>"; }
	return allInBetweenClasses;
}


public bool isMethodOverriddenByAnyDescClass(loc aMethod, loc ascClass, loc descClass, map[loc, set[loc]] invertedContainment, map[loc, set[loc]] extendsMap, M3 projectM3) {
	bool retBool = false;
	set  [loc] 	classesThatOverrideTheMethod = getClassesWhichOverrideAMethod(aMethod, invertedContainment, projectM3);
	set  [loc]	allDescClassesUpToDescClass =  descClass + getInBetweenClasses(ascClass, descClass, extendsMap); 
	if ( !isEmpty(classesThatOverrideTheMethod & allDescClassesUpToDescClass) ) {
		retBool = true;
		//println("isMethodOverriddenByAnyDescClass is true for acsClass <ascClass>, descClass: <descClass>");
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


public bool isLocDefinedInClassOrInterface(loc locPar, map [loc, set[loc]] invClassAndInterfaceContainment) {
	bool retBool = (locPar in invClassAndInterfaceContainment) ? true : false;
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




rel [loc, loc] getExplicitInhRelations(rel [loc, loc] systemInhRelations, M3 projectM3) {
	rel [loc, loc] retRel = {};
	rel [loc, loc] 	extendsOrImplRel = {<_child, _parent> | <_child, _parent> <- projectM3@extends} + {<_child, _parent> | <_child, _parent> <- projectM3@implements};
	retRel = {<_child, _parent> | <_child, _parent> <- systemInhRelations, <_child, _parent> in extendsOrImplRel };
	return retRel;	
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


public bool inheritanceRelationExists(loc classOrInterface1, loc classOrInterface2, rel [loc, loc] allInheritanceRelations) {
	set [loc] relationSet = {child	| <child, parent> <- allInheritanceRelations, 
													(classOrInterface1 == child && classOrInterface2 == parent) ||
													(classOrInterface1 == parent && classOrInterface2 == parent) }; 
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
	if ((iKey.child != DEFAULT_LOC) && (iKey.parent != DEFAULT_LOC) && (iKey.child != iKey.parent)) {
		isSubtypeRel = true;
	}
	return <isSubtypeRel, iKey>;
}


// This method returns the type symbol of a method, constructor or field definition
TypeSymbol getTypeSymbolOfLocDeclaration(loc definedLoc, map [loc, set[TypeSymbol]] typesMap ) {
	set [TypeSymbol] locSymbolSet = definedLoc in typesMap ? typesMap[definedLoc] : {}; 
	if (size(locSymbolSet) != 1) {
		iprintln(locSymbolSet);
		throw("The location <definedLoc> has not exactly one entry in @types annotation. locSymbolSet : <locSymbolSet>");
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


map [loc, TypeSymbol] getTypeVariableMap(list [loc] typeVariables, list [TypeSymbol] typeParameters, loc stmtLoc) {
	map [loc, TypeSymbol] retMap = ();
	list [TypeSymbol] completeTypeParameters = typeParameters;
	if (size(typeVariables) != size(typeParameters)) {
		if (size(typeVariables) > size(typeParameters)) {
			// this is OK, Java allows instantiation with absent type parameters, we will fill the rest of the typeParameters with Object type symbol
			int numOfElementsToAdd = size(typeVariables) - size(typeParameters);
			for (int i <- [0..numOfElementsToAdd]) {
				completeTypeParameters += OBJECT_TYPE_SYMBOL;
			}
			println("Less type parameters than type variables! Type variables: <typeVariables>, type parameters: <typeParameters> at: <stmtLoc>");
			;
		}
		else {
			throw "More type parameters than type variables! Type variables: <typeVariables>, type parameters: <typeParameters> at: <stmtLoc>";
		}
	}
	for (int i <- [0..size(completeTypeParameters)] ) {
		retMap += (typeVariables[i] : completeTypeParameters[i]);
	}
	return retMap;
}


list [TypeSymbol]  getReceivingTypeParameters(TypeSymbol recTypeSymbol) {
	list [TypeSymbol] recTypeParameters = [];
	visit (recTypeSymbol) {
		case classDef:\class(loc decl, list[TypeSymbol] typeParameters) : {
			recTypeParameters = typeParameters;
		}
		case intDef:\interface(loc decl, list[TypeSymbol] typeParameters) : {
			recTypeParameters = typeParameters;
		}				
	}
	if (isEmpty(recTypeParameters)) {
		// in case of a class which is declared with type parameter(s), but still is instantiated without 
		// type parameters, the recTypParameters can be empty. I handle this further in the calling method.  
		// throw "Receiver type parameters is empty for receiver : <recTypeSymbol>";
	;}
	return recTypeParameters;
}



TypeSymbol resolveGenericTypeSymbol(TypeSymbol genericTypeSymbol, Expression methodOrConstExpr, map [loc, set [TypeSymbol]] typesMap, map[loc, set[loc]] invertedClassAndInterfaceContainment ) {
	loc methodParameterTypeVariable = getTypeVariableFromTypeSymbol(genericTypeSymbol);
	TypeSymbol resolvedTypeSymbol = genericTypeSymbol;
	TypeSymbol recTypeSymbol = DEFAULT_TYPE_SYMBOL;
	loc methodOwningClassOrInt = DEFAULT_LOC;
	switch (methodOrConstExpr) {
		case mCall:\methodCall(_,receiver:_,_,_) : {
			//println("Method call at <methodOrConstExpr@decl> ");
			methodOwningClassOrInt =  getDefiningClassOrInterfaceOfALoc(methodOrConstExpr@decl, invertedClassAndInterfaceContainment);
			recTypeSymbol = receiver@typ;
		}
		case mCall:methodCall(_,_,_) : {
			// There can be no subtyping between type parameters, so I do not have to do anything here.
		;}
		case newObject1:\newObject(Type \type, list[Expression] expArgs) : {
			//println("Called constructor: <newObject1@decl>");
			//println("newObject 11111111111 type: <\type>, expArgs : <expArgs>, at : <methodOrConstExpr@src>");
			recTypeSymbol =  getTypeSymbolFromRascalType(\type);
			methodOwningClassOrInt =  getClassOrInterfaceFromTypeSymbol(recTypeSymbol);
			//println("Received type symbol: <recTypeSymbol>");
		}
		case newObject2:\newObject(Type \type, list[Expression] expArgs, Declaration class) : {
			//println("newObject 22222222222 type: <\type>, expArgs : <expArgs>, at : <methodOrConstExpr@src>");
			recTypeSymbol =  getTypeSymbolFromRascalType(\type);
			methodOwningClassOrInt =  getClassOrInterfaceFromTypeSymbol(recTypeSymbol);
		}
		case newObject3:\newObject(Expression expr, Type \type, list[Expression] expArgs) : {
			//println("newObject 33333333333 type: <\type>, expArgs : <expArgs>, at : <methodOrConstExpr@src>");
			recTypeSymbol =  getTypeSymbolFromRascalType(\type);
			methodOwningClassOrInt =  getClassOrInterfaceFromTypeSymbol(recTypeSymbol);
		}
		case newObject4:\newObject(Expression expr, Type \type, list[Expression] expArgs, Declaration class) : {
			//println("newObject 44444444444 type: <\type>, expArgs : <expArgs>, at : <methodOrConstExpr@src>");
			recTypeSymbol =  getTypeSymbolFromRascalType(\type);
			methodOwningClassOrInt =  getClassOrInterfaceFromTypeSymbol(recTypeSymbol);
		}
	}
	if (recTypeSymbol != DEFAULT_TYPE_SYMBOL) {
		//println("Receiver type symbol is: <recTypeSymbol>");
		// recTypeParameters holds the actual types with which the object was instantiated, like Shape, Ractangle, String, etc.
		list [TypeSymbol] recTypeParameters = getReceivingTypeParameters(recTypeSymbol); 
		if ( !isEmpty(recTypeParameters) ) { 
			//println("Receiving type parameters:"); iprintln(recTypeParameters);
			// typeVariablesOfRecClass holds the type variables in the class definition, like X, T in <X,T>
			list 	[loc] typeVariablesOfRecClass 			= getTypeVariablesOfRecClass(methodOwningClassOrInt, typesMap); // type variables like T, X
			//println("Type parameters of receiving class:"); iprintln(typeVariablesOfRecClass);
			// typeVariableMap holds the pair (typeVariable : typeParameter) with respect to the object, like (X : Shape)
			map 	[loc, TypeSymbol] typeVariableMap 		= getTypeVariableMap(typeVariablesOfRecClass, recTypeParameters, methodOrConstExpr@src);
			//println("Type variable map: "); iprintln(typeVariableMap);
			resolvedTypeSymbol = typeVariableMap[methodParameterTypeVariable];
			//println("Resolved type symbol is: <resolvedTypeSymbol>" );
			//println();
		}
		else {
			// recTypeParameters can be empty if a child that's decalered to take a type parameter is instantiated without a type parameter
			// Then I will assume that it is as if the child is instantiated with Object type parameter.
			resolvedTypeSymbol  = OBJECT_TYPE_SYMBOL;
		}
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


public Expression createMethodCallFromConsCall(Statement consCall) {
	Expression retExp;
	list [Expression] arguments = [];
	visit (consCall) {
	     case consCall1:\constructorCall(_, args:_): {
        //       (bool isSuper, list[Expression] arguments)
			arguments = args; 
        }
        case consCall2:\constructorCall(_, expr:_, args:_): {
        //       (bool isSuper, Expression expr, list[Expression] arguments)
			arguments = args; 
        }
	}
	retExp = methodCall(true, " ", arguments);
	retExp@decl = consCall@decl;	
	retExp@src 	= consCall@src; 
	return retExp;
}

public void makeDirectory(loc projectLoc) {
	loc aDirectory = beginPath + projectLoc.authority;
	mkDirectory(aDirectory);
}


public loc  getFilename(loc projectLoc, str logFile) {
	return beginPath + projectLoc.authority + logFile;
}


public void printLog(loc logFile, str header) {
	value val = readTextValueFile(logFile);
	println(header); 
	iprintln(sort(val));	
}



