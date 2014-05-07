module inheritance::ThisChangingType

import IO;
import Map;
import Set;
import Relation;
import List;
import ListRelation;
import Node;
import ValueIO;
import DateTime;

import lang::java::m3::Core;
import lang::java::m3::AST;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::m3::TypeSymbol;

import inheritance::InheritanceDataTypes;
import inheritance::InheritanceModules;



private set [loc] surfaceMatch(Expression aStatement, list [Expression] args) {
	set [loc] retSet = {};
	for (anArg <- args) {
		if (this() := anArg) {retSet += aStatement@src; }
	}
	return retSet;
}


private set [loc] getThisReferencesInAST(Declaration anAST) {
	set [loc] retSet = {};
	visit (anAST) {
		case methExpr2:\methodCall(_,_,_,_args) : {
			retSet += surfaceMatch(methExpr2, _args); 
		}
		case aStmt:\assignment(_lhs, _operator, _rhs) : {
			if (_rhs := this()) {
				retSet += aStmt@src;
			}
		}
		case variables:\variables(_, _fragments) : {
			visit (_fragments[0]) {
				case vrb:\variable(_,_,_rhs) : {
					if (_rhs := this()) {
						retSet += _fragments[0]@src;
					}
				}
			}
		} 
		case newObject1:\newObject(Type \type, list[Expression] expArgs) : {
			retSet += surfaceMatch(newObject1, expArgs); 
		}
		case newObject2:\newObject(Type \type, list[Expression] expArgs, Declaration class) : {
			retSet += surfaceMatch(newObject2, expArgs); 
		}
		case newObject3:\newObject(Expression expr, Type \type, list[Expression] expArgs) : {
			retSet += surfaceMatch(newObject3, expArgs); 
		}
		case newObject4:\newObject(Expression expr, Type \type, list[Expression] expArgs, Declaration class) : {
			retSet += surfaceMatch(newObject4, expArgs); 
		}
		case methExpr1:\methodCall(_,_,_args) : {
			retSet += surfaceMatch(methExpr1, _args); 
		}
	}
	return retSet;
}


private set [loc]  getThisReferencesInMethod(loc aMethodOfAscClass, M3 projectM3) {
	Declaration methodAST = getMethodASTEclipse(aMethodOfAscClass, model = projectM3);
	set [loc] retSet = getThisReferencesInAST(methodAST);
	return retSet;
} 


private set [loc] getThisReferencesInClass(loc ascClass, map [loc, set [loc]] invertedClassAndInterfaceContainment, map [loc, set [loc]] invertedUnitContainment, 
																													map [loc, set [loc]] declarationsMap) {
	list [Declaration] ASTsOfOneClass = getASTsOfAClass(ascClass, invertedClassAndInterfaceContainment, invertedUnitContainment, declarationsMap);
	set [loc] retSet = {};
	for (anAST <- ASTsOfOneClass ) {
		retSet += getThisReferencesInAST(anAST);
	}
	//println("This references in class: <ascClass> are: "); iprintln(sort(retSet));
	return retSet;
}



private rel [loc, loc, loc] getThisChangingTypeCandidates(M3 projectM3) {
	// I only look for class - class relationships
	// ascClass, descClass, candMethod
	rel [loc, loc, loc] retRel = {};
	rel [inheritanceKey, thisChangingTypeCandDetail] candidateLog = {};	
	rel [loc _desc, loc _asc] 	allInheritanceRels = getNonFrameworkInheritanceRels(getInheritanceRelations(projectM3), projectM3);
	map [loc, set[loc]] 		ascDescPair = toMap(invert({<_desc, _asc> | <_desc, _asc> <- allInheritanceRels, isClass(_desc), isClass(_asc)}));
	map [loc, set [loc]]		methodsInClasses = toMap({<_aClass, _aMethod> | <_aClass, _aMethod> <- projectM3@containment, isClass(_aClass), isMethod(_aMethod)});
	map [loc, set[loc]] 		invertedContainment = getInvertedClassAndInterfaceContainment(projectM3);
	map [loc, set[loc]]			methodClassContainment = toMap({<_aClass, _aMethod> | <_aClass, _aMethod> <- projectM3@containment, isClass(_aClass), isMethod(_aMethod)});
	map [loc, set [loc]] 		invertedClassAndInterfaceContainment = getInvertedClassAndInterfaceContainment(projectM3);
	map [loc, set[loc]] 		invertedUnitContainment = getInvertedUnitContainment(projectM3);
	map [loc, set[loc]] 		declarationsMap =  toMap({<aLoc, aProject> | <aLoc, aProject> <- projectM3@declarations});
	map[loc, set[loc]] 			extendsMap = toMap({<_child, _parent> | <_child, _parent> <- projectM3@extends});
	for (ascClass <- ascDescPair) {
		set [loc] allDescClassesOfAscClass = ascDescPair[ascClass];
		for (descClass <- allDescClassesOfAscClass ) {
			set [loc] allMethodsOfAscClass =  ascClass in methodClassContainment ? methodClassContainment[ascClass] : {}; 
			set [loc] allCandidateRefsInMethods = {};
			for (aMethodOfAscClass <- allMethodsOfAscClass) {
				set[loc] candidateMethodReferences = getThisReferencesInMethod(aMethodOfAscClass, projectM3); 
				allCandidateRefsInMethods += candidateMethodReferences;			
				if (!isMethodOverriddenByAnyDescClass(aMethodOfAscClass, ascClass, descClass, invertedContainment, extendsMap, projectM3)) {
					//println("Method: <aMethodOfAscClass> is not overridden by any desc class...");
					for (aCandRef <- candidateMethodReferences ) {
						candidateLog += <<descClass, ascClass>, <aMethodOfAscClass, aCandRef>>;
						retRel += <descClass, ascClass, aMethodOfAscClass>;
					}
				} // if
			}	// for aMethodOfAscClass
			// look at the initializers of ascending class.
			set [loc] candidateClassReferences = getThisReferencesInClass(ascClass, invertedClassAndInterfaceContainment, invertedUnitContainment, declarationsMap);
			set [loc] candidateInitializerReferences = candidateClassReferences - allCandidateRefsInMethods;
			for (anInitRef <- candidateInitializerReferences) {
				candidateLog += <<descClass, ascClass>, <ascClass, anInitRef>>;
				retRel += <descClass, ascClass, ascClass>;
			}
		} // for  descClass
	} // for ascClass
	iprintToFile(thisChangingTypeCandFile, candidateLog);
	return retRel; 
}


private loc getAscClassFromDescAndMethod(loc invokedMethod, loc descClass, rel [loc, loc, loc] candidates) {
	loc retLoc = DEFAULT_LOC;
	set [loc] ascClasses = {_ascClass| <_descClass, _ascClass, _calledMethod> <- candidates, _descClass == descClass, _calledMethod == invokedMethod };
	if (size(ascClasses) != 1) {
		throw ("In getAscClassFromDescAndMethod, the size of ascClasses is not 1, but <size(ascClasses)>. ascClasses: <ascClasses>");
	}
	retLoc = getOneFrom(ascClasses);
	return retLoc;
}


private rel [inheritanceKey, thisChangingTypeOccurrence] getOccurrenceItems(Expression newObjExpr, Type oType, rel [loc, loc] initializerThisRefClasses, 
																				set [loc] initializerChildren) {
	rel [inheritanceKey, thisChangingTypeOccurrence] occurrenceItems = {};
	TypeSymbol newTypeSymbol = getTypeSymbolFromRascalType(oType);
	loc newClass = getClassFromTypeSymbol(newTypeSymbol);
	if ((newClass != DEFAULT_LOC) && (newClass in initializerChildren)) {
		set [inheritanceKey] keySet = {<_child, _parent> | <_child, _parent> <- initializerThisRefClasses, _child == newClass};
		for (inheritanceKey iKey <- keySet ) {
			occurrenceItems += <iKey, <newObjExpr@src, newClass>>; 
		}	
	}
	return occurrenceItems;
}



private set [inheritanceKey] getThisChangingTypeOccurrences(rel [loc, loc, loc] candidates, M3 projectM3) {
	rel [inheritanceKey, thisChangingTypeOccurrence] occurrenceLog = {};
	set [inheritanceKey] retSet = {};
	map [loc, set[loc]] methodAndDescClasses = toMap({<calledMethod, descClass> | <descClass, ascClass, calledMethod> <- candidates, isMethod(calledMethod)});
	rel [loc, loc] initializerThisRefClasses = {<_descClass, _ascClass> | <_descClass, _ascClass, _classRef> <- candidates, isClass(_classRef)};
	set [loc] initializerThisRefChildren = domain(initializerThisRefClasses);
	loc aProject = projectM3.id;
	set [Declaration] projectASTs = createAstsFromEclipseProject(aProject, true);
	for (aProjectAST <- projectASTs) {
		visit (aProjectAST) {
			case methExpr1:\methodCall(_,receiver,_,_) : {
			// \methodCall(bool isSuper, Expression receiver, str name, list[Expression] arguments)
   				loc invokedMethod = methExpr1@decl;
   				loc classOfReceiver = getClassFromTypeSymbol(receiver@typ);
   				if (invokedMethod in methodAndDescClasses) {
   					set [loc] candDescClasses = methodAndDescClasses[invokedMethod];
   					if (classOfReceiver in candDescClasses) {
   						loc ascClass = getAscClassFromDescAndMethod(invokedMethod, classOfReceiver, candidates);
   						occurrenceLog += <<classOfReceiver, ascClass>, <methExpr1@src, invokedMethod>>;
   					}
   				}
			} // case \methodCall
			case newObject1:\newObject(Type oType:\type, list[Expression] expArgs) : {
				occurrenceLog += getOccurrenceItems(newObject1, oType, initializerThisRefClasses, initializerThisRefChildren);
			}
			case newObject2:\newObject(Type oType:\type, list[Expression] expArgs, Declaration class) : {
				occurrenceLog += getOccurrenceItems(newObject2, oType, initializerThisRefClasses, initializerThisRefChildren);
			}
			case newObject3:\newObject(Expression expr, Type oType:\type, list[Expression] expArgs) : {
				occurrenceLog += getOccurrenceItems(newObject3, oType, initializerThisRefClasses, initializerThisRefChildren);
			}
			case newObject4:\newObject(Expression expr, Type oType:\type, list[Expression] expArgs, Declaration class) : {
				occurrenceLog += getOccurrenceItems(newObject4, oType, initializerThisRefClasses, initializerThisRefChildren);
			}
		}
	}	
	retSet = { <_descClass, _ascClass> | <<_descClass, _ascClass>, <_srcRef, _methodOrClass>> <- occurrenceLog };
	iprintToFile(thisChangingTypeOccurFile, occurrenceLog);	
	return retSet;
}


public rel [inheritanceKey, inheritanceType] getThisChangingTypeOccurrences(M3 projectM3) {
	rel [loc, loc, loc] thisChangingTypeCandidates = getThisChangingTypeCandidates(projectM3);
	set [inheritanceKey] thisChangingTypeOccurrences = getThisChangingTypeOccurrences(thisChangingTypeCandidates, projectM3);
	return {<iKey, SUBTYPE> | iKey <- thisChangingTypeOccurrences };
}