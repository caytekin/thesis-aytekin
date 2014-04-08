module inheritance::ExternalReuse

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



private rel [loc, loc] getAllSystemInhRelsCC_CI(rel [loc, loc] allInheritanceRelations, M3 projectM3) {
	rel [loc, loc] retRel = {};
	set [loc] allSystemClasses = getAllClassesInProject(projectM3);
	set [loc] allSystemInterfaces = getAllInterfacesInProject(projectM3);
	retRel += {<_child, _parent> | <_child, _parent> <- allInheritanceRelations, _child in allSystemClasses, _parent in allSystemClasses};
	retRel += {<_child, _parent> | <_child, _parent> <- allInheritanceRelations, _child in allSystemInterfaces, _parent in allSystemInterfaces};	
	return retRel;
}


private bool isPrivate(loc aMethod, map[loc, set[Modifier]] allModifiers) {
	bool isPrivate = false;
	set [Modifier] methodModifiers = aMethod in allModifiers ? allModifiers[aMethod] : {} ;
 	if (!isEmpty ( {_aModifier | _aModifier <- methodModifiers , (_aModifier := \private()) } ) ) {
		isPrivate = true;
	}
	return isPrivate;
}


private bool areAllMethodsOverridden(	set [loc] parentMethods, set [loc] childMethods, 
										map[loc, set[loc]] invertedOverridesMap, map [loc, set[Modifier]] allModifiers) {
	list [loc] parentMethodList = toList(parentMethods);
	bool allOverridden = true; 
	int listIndex = 0;
	while ( (allOverridden ) && (listIndex < size(parentMethodList)) ) {
		loc aParentMethod = parentMethodList[listIndex];
		set [loc] overridingMethods = aParentMethod in invertedOverridesMap ? invertedOverridesMap[aParentMethod] : {};
		set [loc] overridingChildMethods = childMethods & overridingMethods; 
		if (isEmpty(overridingChildMethods)) {
			if (!isPrivate(aParentMethod, allModifiers)) {
				allOverridden = false;	
			}
		} 
		else {
			if (size (overridingChildMethods) > 1 ) {
				throw "in getAllNotOverriddenMethods, size is greater than 1. Set is: <overridingChildMethods> for parent method: <aParentMethod>";
			}
		}
		listIndex += 1;
	}
	return allOverridden;
}


public rel [inheritanceKey, inheritanceSubtype] getCandidatesExternalReuse(rel [loc, loc] allInheritanceRelations, M3 projectM3) {
	rel [inheritanceKey, inheritanceSubtype] retRel = {};
	rel [loc, loc] 				allSystemInhRelsCC_II 	= getAllSystemInhRelsCC_CI(allInheritanceRelations, projectM3);
	map [loc, set[loc]] 		containmentMapMethods 	= toMap ({<_aClassOrInterface, _aMethod> | <_aClassOrInterface, _aMethod> <- projectM3@containment, isMethod(_aMethod), (isClass(_aClassOrInterface) || isInterface(_aClassOrInterface) ) });
	map [loc, set [Modifier]] 	modifiersMap 			= toMap({<_aLoc, _aModifier> | <_aLoc, _aModifier>  <- projectM3@modifiers});
	map [loc, set[loc]] 		invertedOverridesMap	= getInvertedOverrides(projectM3);
	for ( <_child, _parent> <- allSystemInhRelsCC_II) {
		set [loc] childMethods = _child in containmentMapMethods ? containmentMapMethods[_child] : {};
		set [loc] parentMethods = _parent in  containmentMapMethods ? containmentMapMethods[_parent] : {};
		bool allMethodsOverridden = areAllMethodsOverridden(parentMethods, childMethods, invertedOverridesMap, modifiersMap);
		if (!allMethodsOverridden) {
			retRel += <<_child, _parent>, EXTERNAL_REUSE_CANDIDATE>;
		}
	 } 
	 // TODO: Until I get the answer from the authors, I do not do anything about field external reuse...
	 return retRel;
}


public lrel [inheritanceKey, inheritanceSubtype, loc, loc] getExternalReuseViaMethodCall(Expression mCall, loc  classOfMethodCall, 
																						map [loc, set[loc]] invertedClassContainment,  map[loc, set[loc]] declarationsMap,
																						rel [loc, loc] allInheritanceRelations) {
	lrel [inheritanceKey, inheritanceSubtype, loc, loc] retList = [];
	visit (mCall) {
		case m2:\methodCall(_, receiver:_, _, _): {
			loc invokedMethod = m2@decl;        			
			loc classOfReceiver = getClassFromTypeSymbol(receiver@typ);
			// I am only interested in the classes and not interfaces, enums, etc.
			// I am not interested in this() and also variables of classOfMethodCall
			if ((invokedMethod in invertedClassContainment) && (classOfReceiver != classOfMethodCall) 
									&& isLocDefinedInProject(invokedMethod, declarationsMap) 
								 	&& ! inheritanceRelationExists(classOfMethodCall, classOfReceiver, allInheritanceRelations)) {
				// for external reuse, the invokedMethod should not be declared in the 
				// class classOfReceiver
				loc methodDefiningClass = getDefiningClassOfALoc(invokedMethod, invertedClassContainment);
				if ( isClass(classOfReceiver) && (methodDefiningClass != classOfReceiver)) {
						retList += <<classOfReceiver, methodDefiningClass>, EXTERNAL_REUSE_ACTUAL_VIA_METHOD_CALL, m2@src, invokedMethod>; 
				}
			} // if inheritanceRelationExists
   		} // case methodCall()
   	}
	return retList;
}


public lrel [inheritanceKey, inheritanceSubtype, loc, loc] getExternalReuseViaFieldAccess(Expression qName, map [loc, set[loc]] invClassAndInterfaceContainment,
																											map[loc, set[loc]] declarationsMap) {
	lrel [inheritanceKey, inheritanceSubtype, loc, loc] retList = [];
	visit (qName) {
		case \qualifiedName(qualifier, expression) : {
			loc accessedField = expression@decl;
			if (isField(accessedField) && isLocDefinedInProject(accessedField, declarationsMap)) {  
				loc classOfQualifier = getClassOrInterfaceFromTypeSymbol(qualifier@typ);
				loc classOfExpression = getDefiningClassOrInterfaceOfALoc(accessedField, invClassAndInterfaceContainment);
				if (classOfQualifier != classOfExpression) {
					retList += <<classOfQualifier, classOfExpression>, EXTERNAL_REUSE_ACTUAL_VIA_FIELD_ACCESS, expression@src, accessedField>;
				}
			}
		} 
	}
	return retList;
}


public rel [inheritanceKey, inheritanceType] getExternalReuseCases(M3 projectM3) {
	// Decision: The external reuse cases are only about classes, see assumptions and decisions document.
	// TODO: This assumption has to change because there are also statistics for II in the paper, like nOnlyIIReuse
	rel [inheritanceKey, inheritanceType] resultRel = {};
	lrel [inheritanceKey, inheritanceSubtype, loc, loc] allExternalReuseCases = [];
	set	[loc] 				allClassesInProject 		= {decl | <decl, prjct> <- projectM3@declarations, isClass(decl) };
	map [loc, set [loc]] 	containmentMapForMethods 	= toMap({<owner, declared> | <owner,declared> <- projectM3@containment, isClass(owner), isMethod(declared)});
	map [loc, set [loc]] 	invertedClassContainment 	= toMap(invert({<owner, declared> | <owner,declared> <- projectM3@containment, isClass(owner)}));
	map [loc, set [loc]] 	invClassAndInterfaceContainment 	= getInvertedClassAndInterfaceContainment(projectM3);
	map [loc, set [loc]] 	declarationsMap				= toMap({<aLoc, aProject> | <aLoc, aProject> <- projectM3@declarations});
	rel [loc, loc] 			allInheritanceRelations 	= getInheritanceRelations(projectM3);
	map [loc, set[loc]] 	invertedUnitContainment 	= getInvertedUnitContainment(projectM3);
	for (oneClass <- allClassesInProject) {
		list [Declaration] ASTsOfOneClass = getASTsOfAClass(oneClass, invClassAndInterfaceContainment, invertedUnitContainment, declarationsMap);
		for (oneAST <- ASTsOfOneClass) {
			visit(oneAST) {
				case m2:\methodCall(_, receiver:_, _, _): {
					allExternalReuseCases += getExternalReuseViaMethodCall(m2, oneClass, invertedClassContainment, declarationsMap, allInheritanceRelations);
        		} // case methodCall()
        		case qName:\qualifiedName(_, _) : {
        			allExternalReuseCases += getExternalReuseViaFieldAccess(qName, invClassAndInterfaceContainment, declarationsMap);
        		}
        	} // visit()
		}	// for each method in the class															
	}	// for each class in the project
	for ( int i <- [0..size(allExternalReuseCases)]) { 
		tuple [ inheritanceKey iKey, inheritanceSubtype iType, loc srcLoc, loc accessedLoc] aCase = allExternalReuseCases[i];
		resultRel += <aCase.iKey, EXTERNAL_REUSE_ACTUAL>;
	}
	// TODO !!! I am here. getCandidatesExternalReuse
	rel [inheritanceKey, inheritanceType] candExtReuse = getCandidatesExternalReuse(allInheritanceRelations, projectM3);
	resultRel += candExtReuse;
	allExternalReuseCases += [<<_child, _parent>, EXTERNAL_REUSE_CANDIDATE_METHOD , DEFAULT_LOC, DEFAULT_LOC> | <<_child, _parent>, _> <- candExtReuse];
	iprintToFile(externalReuseLogFile, allExternalReuseCases);
	return resultRel;
}

