module inheritance::OtherInheritanceCases

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


public bool areAllFieldsConstants(set [loc] fieldsInLoc, map[loc, set[Modifier]] allFieldModifiers) {
	bool retBool = false;
	for ( aField <- fieldsInLoc) {
		set [Modifier] modifiers = aField in allFieldModifiers ? allFieldModifiers[aField] : {} ;
		bool isFinal = false, isStatic = false;		
		for (aModifier <- modifiers) {
			switch (aModifier) {
				case static() 	: isStatic = true;
				case final()	: isFinal = true; 
			}
		}
		if (! (isFinal && isStatic) ) {
			retBool = false;
			break;
		} 
		else {
			retBool = true;
		}
	}
	return retBool;
}


public bool containsOnlyConstantFields(loc aLoc, map[loc, set [loc]] classAndInterfaceContainment, map[loc, set[Modifier]] allFieldModifiers) {
	// we just want fields in the location
	bool retBool = false;
	set [loc] everythingInLoc = aLoc in classAndInterfaceContainment ? classAndInterfaceContainment[aLoc] : {} ;
	set [loc] fieldsInLoc = {_aField | _aField  <- everythingInLoc, isField(_aField)};
	if (!isEmpty(fieldsInLoc) && isEmpty(everythingInLoc - fieldsInLoc) && areAllFieldsConstants(fieldsInLoc, allFieldModifiers)) {
		retBool = true;
	}
	return retBool;													
}  


public set [loc] getConstantCandidates(map[loc, set [loc]] classAndInterfaceContainment, map[loc, set[Modifier]] allFieldModifiers, M3 projectM3) {
	set [loc] retSet = {};
	list [loc] allClassesAndInterfaces = sort(getAllClassesAndInterfacesInProject(projectM3));
	for (aLoc <- allClassesAndInterfaces ) {
		if (containsOnlyConstantFields(aLoc, classAndInterfaceContainment, allFieldModifiers)) {
			retSet += aLoc;
		}
	}
	return retSet;
}


public bool areAllParentsInCandidateList(set [loc] allParentsOfLoc, set [loc] candidateLocs) {
	bool retBool = false;
	if (!isEmpty(allParentsOfLoc) && !isEmpty(candidateLocs) &&  (allParentsOfLoc <= candidateLocs) ) {
		retBool = true;
	}
	return retBool;
}


public rel [inheritanceKey,inheritanceType] findConstantLocs(set [loc] candidateLocs, M3 projectM3) {
	rel [loc, loc] allInheritanceRels = getNonFrameworkInheritanceRels(getInheritanceRelations(projectM3), projectM3);
	rel [inheritanceKey,inheritanceType] retRel = {};
	for (aLoc <- candidateLocs) {
		set [loc] allParentsOfLoc = {parent | <child, parent> <- allInheritanceRels, aLoc == child};
		if (isEmpty(allParentsOfLoc) || (areAllParentsInCandidateList(allParentsOfLoc, candidateLocs))) {
			retRel += {<<child, parent>, CONSTANT> | <child, parent> <- allInheritanceRels, aLoc == parent};
		}
	}
	return retRel;
}


public set [loc] getMarkerCandidates(map[loc, set[loc]] interfaceContainment, M3 projectM3) {
	set [loc] retSet = {};
	set [loc] allInterfaces = getAllInterfacesInProject(projectM3);
	set [loc] nonMarkerInterfaces = domain(interfaceContainment);
	retSet = allInterfaces - nonMarkerInterfaces;	
	return retSet;
}
	

public rel [inheritanceKey, inheritanceType] findMarkerInterfaces(set [loc] markerCandidates, M3 projectM3) {
	rel [loc, loc] allInheritanceRels = getNonFrameworkInheritanceRels(getInheritanceRelations(projectM3), projectM3);
	rel [inheritanceKey,inheritanceType] retRel = {};
	for (anInterface <- markerCandidates) {
		set [loc] allParentsOfInterface = {parent | <child, parent> <- allInheritanceRels, anInterface == child};
		if (isEmpty(allParentsOfInterface) || (areAllParentsInCandidateList(allParentsOfInterface, markerCandidates))) {
			retRel += {<<child, parent>, MARKER> | <child, parent> <- allInheritanceRels, anInterface == parent};
		}
	}
	return retRel;	
}


public loc getImmediateParentOfAClass(loc childClass, map [loc, set[loc]] extendsMap) {
	loc retClass = DEFAULT_LOC;
	set [loc] parentSet = childClass in extendsMap ? extendsMap[childClass] : {};
	if (size(parentSet) == 1) {
		retClass = getOneFrom(parentSet);
	}
	else {
		throw("The number of parents of the class <childclass> is different from one in getImmediateClassOfAClass()");
	} 
	return retClass;
}


public rel [inheritanceKey, inheritanceType] findSuperRelations(M3 projectM3) {
	set [loc] 				allClassesInProject 		= getAllClassesInProject(projectM3);
	map [loc, set [loc]] 	constructorContainmentMap 	= toMap({<_owner, _constructor> | <_owner, _constructor> <- projectM3@containment, _constructor.scheme == "java+constructor" });
	map [loc, set [loc]]	extendsMap 					= toMap({<_child, _parent> | <_child, _parent> <- projectM3@extends });
	rel [inheritanceKey,inheritanceType] retRel = {};
	lrel [inheritanceKey, superCallLoc] superLog = [];
	for (aClass <- allClassesInProject) {
		set [loc] constructors = aClass in constructorContainmentMap ? constructorContainmentMap[aClass] : {} ; 
		for (aConstructor <- constructors) {
			Declaration constructorAST = getMethodASTEclipse(aConstructor, model = projectM3);
			bool superCall = false; loc locOfSuperCall = DEFAULT_LOC;
			visit(constructorAST) {
				case s1:\constructorCall(isSuper:_,_,_) : {
					if (isSuper) {superCall = true; locOfSuperCall = s1@src;}
				}
				case s2:\constructorCall(isSuper:_,_) : {
					if (isSuper) {superCall = true; locOfSuperCall = s2@src;} 
				}
			}
			if (superCall) {
				loc parentClass = getImmediateParentOfAClass(aClass, extendsMap);
				retRel += <<aClass, parentClass>, SUPER>;
				superLog += <<aClass, parentClass>, locOfSuperCall>;
			}
		}
	}
	iprintToFile(superLogFile,superLog);
	return retRel;	
}


private rel [inheritanceKey iKey, set [loc] otherParents] getOneGenericUsage(Expression castStmt, 	map [loc, set [loc]] invertedExtendsAndImplementsMap,
																										map [loc, set [loc]] extendsAndImplementsMap ) {
	rel [inheritanceKey iKey,set [loc] otherParents] oneUsage = {};
	visit (castStmt) {
		case \cast(castType, castExpr) : {  
			TypeSymbol exprTypeSymbol = castExpr@typ;
			// TODO Think about arrays, generics, etc. and test with examples!
			TypeSymbol castTypeSymbol = getTypeSymbolFromRascalType(castType);
			if (exprTypeSymbol := object()) {
				loc genericParentCandidate = getClassOrInterfaceFromTypeSymbol(castTypeSymbol);
				if (genericParentCandidate != DEFAULT_LOC) {
					set [loc] directDescendants = getAllDirectDescendants(genericParentCandidate , invertedExtendsAndImplementsMap );
					for (aDesc <- directDescendants) {
						set [loc] allParentsOfADesc = getAllDirectAscendants(aDesc, extendsAndImplementsMap);
						set [loc] otherParents = allParentsOfADesc - {genericParentCandidate};
						if (!isEmpty(otherParents)) {
							oneUsage += <<aDesc, genericParentCandidate>, otherParents>;
						}
					}
				}
			}
		}
	}
	return oneUsage;
}


private rel [inheritanceKey, inheritanceType] findGenericUsages(M3 projectM3) {
	rel [inheritanceKey, inheritanceType] retRel = {};
	lrel [inheritanceKey _iKey, set [loc] _otherParents, loc _castLoc] genericLog = [];
	map [loc, set [loc]] invertedExtendsAndImplementsMap 	= getInvertedExtendsAndImplementsMap(projectM3);	
	map [loc, set [loc]] extendsAndImplementsMap 			= getExtendsAndImplementsMap(projectM3);		
	set [Declaration] projectASTs = createAstsFromEclipseProject(projectM3.id, true);
	for ( anAST <- projectASTs) {
		visit (anAST) {
			case castStmt:\cast(castType, castExpr) : {  
				rel [inheritanceKey, set[loc]] oneGenericUsage = getOneGenericUsage(castStmt, invertedExtendsAndImplementsMap, extendsAndImplementsMap );
				if ( !isEmpty(oneGenericUsage) ) { 
					tuple [inheritanceKey iKey, set [loc] otherParents] genericTuple = getOneFrom(oneGenericUsage);
					retRel += <genericTuple.iKey, GENERIC>;
					genericLog += <genericTuple.iKey, genericTuple.otherParents, castStmt@src>;	
				}
			}
		}	
	}
	iprintToFile(genericLogFile, genericLog);
	return retRel;
}


private set [loc] getAllDirectAscendants(loc child, map [loc, set [loc]] extendsAndImplementsMap) {
	set [loc] allDirectAscendants = child in extendsAndImplementsMap ? extendsAndImplementsMap[child] : {};
	return allDirectAscendants;
} 


private set [loc] getAllDirectDescendants(loc parent, map [loc, set [loc]] invertedDescMap) {
	set [loc] allDirectDescendants = parent in invertedDescMap ? invertedDescMap[parent] : {};
	return allDirectDescendants;
}


private bool isCategory(inheritanceKey anExtendsCandidate,  set [inheritanceKey] subtypeSet, map [loc, set[loc]] invertedDescMap) {
	bool isExtendsCategory = false;
	list [loc] allSiblings = toList(getAllDirectDescendants( anExtendsCandidate.parent, invertedDescMap)); 
	int i = 0;
	while ( (!isExtendsCategory)  && (i < (size(allSiblings)) ) ) {
		aSibling = allSiblings[i];
		inheritanceKey siblingKey = <aSibling, anExtendsCandidate.parent>;
		if (siblingKey in subtypeSet ) { isExtendsCategory = true; }
		i += 1;
	}
	return isExtendsCategory;
}



public rel [inheritanceKey, inheritanceType] getCategoryCases(rel [inheritanceKey, inheritanceType] allInheritanceCases, M3 projectM3) {
	rel [inheritanceKey, inheritanceType] retRel = {};
	map [loc, set[loc]] invertedExtendsMap =  getInvertedExtendsMap(projectM3);
	map [loc, set[loc]] invertedImplementsMap =  getInvertedImplementsMap(projectM3);
	
	set [loc] allSystemClasses = getAllClassesInProject(projectM3);
	set [loc] allSystemInterfaces = getAllInterfacesInProject(projectM3);
	set [inheritanceKey] allExplicitSystemCC = {<_child, _parent> | <_child, _parent> <- projectM3@extends, _child in allSystemClasses, _parent in allSystemClasses};
	set [inheritanceKey] allExplicitSystemCI = {<_child, _parent> | <_child, _parent> <- projectM3@implements, _child in allSystemClasses, _parent in allSystemInterfaces};
	set [inheritanceKey] allExplicitSystemII = {<_child, _parent> | <_child, _parent> <- projectM3@extends, _child in allSystemClasses, _parent in allSystemInterfaces};

	// TODO : Think about DOWNCALL_CANDIDATE and EXTERNAL_REUSE_CANDIDATE cases !!!
	set [inheritanceKey] allUsedInheritanceRels = {<_child, _parent> | <<_child, _parent>, _iType> <- allInheritanceCases, _iType in {INTERNAL_REUSE, EXTERNAL_REUSE_ACTUAL, SUBTYPE, DOWNCALL_ACTUAL, CONSTANT, MARKER, SUPER, GENERIC} };	
	set [inheritanceKey] subtypeSet = {<_child, _parent> | <<_child, _parent>, _iType> <- allInheritanceCases, _iType == SUBTYPE };
	
	set [inheritanceKey] CCCategoryCandidates = allExplicitSystemCC - allUsedInheritanceRels;
	set [inheritanceKey] CICategoryCandidates = allExplicitSystemCI - allUsedInheritanceRels;
	set [inheritanceKey] IICategoryCandidates = allExplicitSystemII - allUsedInheritanceRels;
	
	for (anExtendsCandidate <- (CCCategoryCandidates + IICategoryCandidates) ) {
		if (isCategory(anExtendsCandidate,  subtypeSet, invertedExtendsMap ) ) {
			retRel += {<anExtendsCandidate, CATEGORY>};
		} 
	}
	for (anImplementsCandidate <- CICategoryCandidates) {
		if (isCategory(anImplementsCandidate,  subtypeSet, invertedImplementsMap) ) {
			retRel += {<anImplementsCandidate, CATEGORY>};
		} 
	}
	
	return retRel;
}


public rel [inheritanceKey,inheritanceType] getOtherInheritanceCases(M3 projectM3) {
	rel [inheritanceKey,inheritanceType] retRel = {};
	map [loc, set[loc]] interfaceContainment = toMap({<_anInterface, _anItem> |<_anInterface, _anItem> <- projectM3@containment, isInterface(_anInterface)});	
	map [loc, set[loc]] classAndInterfaceContainment = toMap ({<_classOrInterface, _anItem> | <_classOrInterface, _anItem> <- projectM3@containment, isClass(_classOrInterface) || isInterface(_classOrInterface) });
	map[loc, set[Modifier]] allFieldModifiers = toMap({<_aField, _aModifier> | <_aField, _aModifier>  <- projectM3@modifiers, isField(_aField)});
	retRel += findConstantLocs(getConstantCandidates(classAndInterfaceContainment, allFieldModifiers, projectM3), projectM3);
	retRel += findMarkerInterfaces(getMarkerCandidates(interfaceContainment, projectM3), projectM3);	
	retRel += findSuperRelations(projectM3);
	retRel += findGenericUsages(projectM3);
	return retRel;
}


