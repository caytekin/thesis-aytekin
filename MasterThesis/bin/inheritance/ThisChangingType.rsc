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


private set [loc] getThisReferencesInMethod(loc ascClass, loc descClass, loc aMethodOfAscClass, M3 projectM3) {
	set [loc] retSet = {};
	methodAST = getMethodASTEclipse(aMethodOfAscClass, model = projectM3);
	visit (methodAST) {
		case newObject3:\newObject(_, list [Expression] _args, _) : {
			retSet += surfaceMatch(newObject3, _args); 
		}
		case newObject2:\newObject(_, list[Expression] _args) : {
			retSet += surfaceMatch(newObject2, _args); 
		}		
		case methExpr1:\methodCall(_,_,_args) : {
			retSet += surfaceMatch(methExpr1, _args); 
		}
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
	}
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
	for (ascClass <- ascDescPair) {
		set [loc] allMethodsOfAscClass =  ascClass in methodClassContainment ? methodClassContainment[ascClass] : {}; 
		for (aMethodOfAscClass <- allMethodsOfAscClass) {
			set [loc] allDescClassesOfAscClass = ascDescPair[ascClass];
			for (descClass <- ascDescPair[ascClass]) {
				if (!isMethodOverriddenByDescClass(aMethodOfAscClass, descClass, invertedContainment, projectM3)) {
					set[loc] candidateReferences = getThisReferencesInMethod(ascClass, descClass, aMethodOfAscClass, projectM3); 
					for (aCandRef <- candidateReferences ) {
						candidateLog += <<descClass, ascClass>, <aMethodOfAscClass, aCandRef>>;
						retRel += <descClass, ascClass, aMethodOfAscClass>;
					}
				} // if
			}	// for descClass
		} // for  aMethodOfAscClass
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



private set [inheritanceKey] getThisChangingTypeOccurrences(rel [loc, loc, loc] candidates, loc aProject, M3 projectM3) {
	rel [inheritanceKey, thisChangingTypeOccurrence] occurrenceLog = {};
	set [inheritanceKey] retSet = {};
	map [loc, set[loc]] methodAndDescClasses = toMap({<calledMethod, descClass> | <descClass, ascClass, calledMethod> <- candidates});
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
   						retSet += <classOfReceiver, ascClass>;
   					}
   				}
			}
		}
	}	
	iprintToFile(thisChangingTypeOccurFile, occurrenceLog);	
	return retSet;
}


public rel [inheritanceKey, inheritanceType] getThisChangingTypeOccurrences() {
	loc aProject = |project://jrat_0.6|;
	println("Creating M3...");
	M3 projectM3 = createM3FromEclipseProject(aProject);
	println("Created M3.");
	println("Starting with this changing type...<printTime(now())>");
	rel [loc, loc, loc] thisChangingTypeCandidates = getThisChangingTypeCandidates(projectM3);
	set [inheritanceKey] thisChangingTypeOccurrences = getThisChangingTypeOccurrences(thisChangingTypeCandidates, aProject, projectM3);
	printLog(thisChangingTypeCandFile, "THIS CHANGING TYPE CANDIDATES THIS REFERENCES:");
	printLog(thisChangingTypeOccurFile, "THIS CHANGING TYPE OCCURRENCES:");
	println("Finished with this changing type...<printTime(now())>");
	return {<iKey, SUBTYPE> | iKey <- thisChangingTypeOccurrences };
}