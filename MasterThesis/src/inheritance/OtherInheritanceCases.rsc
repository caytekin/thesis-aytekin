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
import lang::java::m3::TypeSymbol;

import inheritance::InheritanceDataTypes;
import inheritance::InheritanceModules;


public bool areAllFieldsConstants(set [loc] fieldsInLoc, M3 projectM3) {
	bool retBool = false;
	lrel [loc, Modifier] myModifiers = sort({<from, to> | <from, to> <- projectM3@modifiers,
																		from in fieldsInLoc});
	map[loc , set[Modifier] ] modifiersPerField = index(myModifiers);
	for ( modifierEntry <- modifiersPerField) {
		set [Modifier] modifiers = modifiersPerField[modifierEntry];
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


public bool containsOnlyConstantFields(loc aLoc, M3 projectM3) {
	// we just want fields in the location
	bool retBool = false;
	set [loc] fieldsInLoc = {aField | <classOrInterface, aField>  <- projectM3@containment, 
													isField(aField),
													(classOrInterface == aLoc)};
	set [loc] everythingInLoc = {anItem | <classOrInterface, anItem> <- projectM3@containment,
													(classOrInterface == aLoc)};
	if (!isEmpty(fieldsInLoc) && isEmpty(everythingInLoc - fieldsInLoc) && areAllFieldsConstants(fieldsInLoc, projectM3)) {
		
		retBool = true;
	}
	return retBool;													
}  


public set [loc] getConstantCandidates(M3 projectM3) {
	set [loc] retSet = {};
	list [loc] allClassesAndInterfaces = sort(getAllClassesAndInterfacesInProject(projectM3));
	for (aLoc <- allClassesAndInterfaces ) {
		if (containsOnlyConstantFields(aLoc, projectM3)) {
			retSet += aLoc;
		}
	}
	return retSet;
}


public bool areAllParentsInCandidateList(allParentsOfLoc, candidateLocs) {
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



public set [loc] getMarkerCandidates(M3 projectM3) {
	set [loc] retSet = {};
	list [loc] allInterfaces = sort(getAllInterfacesInProject(projectM3));
	for (anInterface <- allInterfaces ) {
		if (isEmpty({_anItem | <_anInterface, _anItem> <- projectM3@containment, (_anInterface == anInterface)})) {
			retSet += anInterface;
		}
	}
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


public loc getImmediateParentOfAClass(loc childClass, projectM3) {
	loc retClass = DEFAULT_LOC;
	set [loc] parentSet = {_parent | <_child, _parent> <- projectM3@extends, _child == childClass, isClass(_child), isClass(_parent)};
	if (size(parentSet) == 1) {
		retClass = getOneFrom(parentSet);
	}
	else {
		throw("The number of parents of the class <childclass> is different from one in getImmediateClassOfAClass()");
	} 
	return retClass;
}


public rel [inheritanceKey, inheritanceType] findSuperRelations(M3 projectM3) {
	set [loc] allClassesInProject = getAllClassesInProject(projectM3);
	rel [inheritanceKey,inheritanceType] retRel = {};
	lrel [inheritanceKey, superCallLoc] superLog = [];
	for (aClass <- allClassesInProject) {
		set [loc] constructors = {_constructor | <_owner, _constructor> <- projectM3@containment,
																	_owner == aClass,
																	_constructor.scheme == "java+constructor" };										
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
				loc parentClass = getImmediateParentOfAClass(aClass, projectM3);
				retRel += <<aClass, parentClass>, SUPER>;
				superLog += <<aClass, parentClass>, locOfSuperCall>;
			}
		}
	}
	iprintToFile(superLogFile,superLog);
	return retRel;	
}


public rel [inheritanceKey,inheritanceType] getOtherInheritanceCases(M3 projectM3) {
	rel [inheritanceKey,inheritanceType] retRel = {};
	retRel += findConstantLocs(getConstantCandidates(projectM3), projectM3);
	retRel += findMarkerInterfaces(getMarkerCandidates(projectM3), projectM3);	
	retRel += findSuperRelations(projectM3);
	return retRel;
}


