module inheritance::GraphExample

import analysis::graphs::Graph;
import IO;


private rel [loc, loc] getAllSystemInhRelsCC_CI(rel [loc, loc] allInheritanceRelations, M3 projectM3) {
	rel [loc, loc] retRel = {};
	set [loc] allSystemClasses = getAllClassesInProject(projectM3);
	set [loc] allSystemInterfaces = getAllInterfacesInProject(projectM3);
	retRel += {<_child, _parent> | <_child, _parent> <- allInheritanceRelations, _child in allSystemClasses, _parent in allSystemClasses};
	retRel += {<_child, _parent> | <_child, _parent> <- allInheritanceRelations, _child in allSystemInterfaces, _parent in allSystemInterfaces};	
	return retRel;
}



// This module stores the removed code which may be useful in the future 
// for inheritance analysis.


public lrel [inheritanceKey, inheritanceSubtype, loc, loc] getCandidatesExternalReuse(rel [loc, loc] allInheritanceRelations, M3 projectM3) {
	lrel [inheritanceKey, inheritanceSubtype, loc, loc] retRel = [];
	rel [loc, loc] 				allSystemInhRelsCC_II 	= getAllSystemInhRelsCC_CI(allInheritanceRelations, projectM3);
	map [loc, set[loc]] 		containmentMapMethods 	= toMap ({<_aClassOrInterface, _aMethod> | <_aClassOrInterface, _aMethod> <- projectM3@containment, isMethod(_aMethod), (isClass(_aClassOrInterface) || isInterface(_aClassOrInterface) ) });
	map [loc, set [Modifier]] 	modifiersMap 			= toMap({<_aLoc, _aModifier> | <_aLoc, _aModifier>  <- projectM3@modifiers});
	map [loc, set[loc]] 		invertedOverridesMap	= getInvertedOverrides(projectM3);
	for ( <_child, _parent> <- allSystemInhRelsCC_II) {
		set [loc] childMethods = _child in containmentMapMethods ? containmentMapMethods[_child] : {};
		set [loc] parentMethods = _parent in  containmentMapMethods ? containmentMapMethods[_parent] : {};
		set [loc] oneNotOverriddenMethodSet = getOneNotOverriddenMethod (parentMethods, childMethods, invertedOverridesMap, modifiersMap);
		if (!isEmpty(oneNotOverriddenMethodSet )) {
			retRel += <<_child, _parent>, EXTERNAL_REUSE_CANDIDATE_METHOD, getOneFrom(oneNotOverriddenMethodSet), DEFAULT_LOC>;
		}
	 } 
	 // TODO: Until I get the answer from the authors, I do not do anything about field external reuse...
	 // TODO: No, I decided to include field external reuse candidates already, independent from what the authors say...
	 // TODO: Code this!
	 return retRel;
}


private set [loc] getOneNotOverriddenMethod (	set [loc] parentMethods, set [loc] childMethods, 
												map[loc, set[loc]] invertedOverridesMap, map [loc, set[Modifier]] allModifiers) {
	// get one of the parent methods which are not overridden by the child, if any, otherwise return an epty set.
	set [loc] retSet = {};
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
				retSet += aParentMethod;
			}
		} 
		else {
			if (size (overridingChildMethods) > 1 ) {
				throw "in getAllNotOverriddenMethods, size is greater than 1. Set is: <overridingChildMethods> for parent method: <aParentMethod>";
			}
		}
		listIndex += 1;
	}
	return retSet;
}

private bool isPrivate(loc aMethod, map[loc, set[Modifier]] allModifiers) {
	bool isPrivate = false;
	set [Modifier] methodModifiers = aMethod in allModifiers ? allModifiers[aMethod] : {} ;
 	if (!isEmpty ( {_aModifier | _aModifier <- methodModifiers , (_aModifier := \private()) } ) ) {
		isPrivate = true;
	}
	return isPrivate;
}


private void snippetsExternalReuseCandidate() {
	allCandExtReuseCases = getCandidatesExternalReuse(allInheritanceRelations, projectM3);
	for ( int i <- [0..size(allCandExtReuseCases )]) { 
		tuple [ inheritanceKey iKey, inheritanceSubtype iType, loc srcLoc, loc accessedLoc] aCase = allCandExtReuseCases[i];
		resultRel += <aCase.iKey, EXTERNAL_REUSE_CANDIDATE>;
	}
	iprintToFile(candidateExternalReuseLogFile,  allCandExtReuseCases);

}











//private rel [inheritanceKey, inheritanceType] getCC_CI_II_NonFR_Relations (rel [loc child, loc parent] inheritRelation, M3 projectM3) {
//	rel [inheritanceKey, inheritanceType] CC_CI_II_NonFR_Relations = {};
//	set [loc] allClassesAndInterfacesInProject = getAllClassesAndInterfacesInProject(projectM3);
//	set [inheritanceKey] allInheritanceRels = getInheritanceRelations(projectM3);
//	CC_CI_II_NonFR_Relations += {<<child, parent>, CLASS_CLASS> | <child, parent> <- inheritRelation, isClass(child), isClass(parent)};
//	CC_CI_II_NonFR_Relations += {<<child, parent>, CLASS_INTERFACE> | <child, parent> <- inheritRelation, isClass(child), isInterface(parent)};
//	CC_CI_II_NonFR_Relations += {<<child, parent>, INTERFACE_INTERFACE> | <child, parent> <- inheritRelation, isInterface(child), isInterface(parent)};
//	CC_CI_II_NonFR_Relations += {<<child, parent>, NONFRAMEWORK_CC> | <child, parent> <- inheritRelation, isClass(child), isClass(parent), parent in allClassesAndInterfacesInProject};
//	CC_CI_II_NonFR_Relations += {<<child, parent>, NONFRAMEWORK_CI> | <child, parent> <- inheritRelation, isClass(child), isInterface(parent), parent in allClassesAndInterfacesInProject};
//	CC_CI_II_NonFR_Relations += {<<child, parent>, NONFRAMEWORK_II> | <child, parent> <- inheritRelation, isInterface(child), isInterface(parent), parent in allClassesAndInterfacesInProject};
//	return CC_CI_II_NonFR_Relations;
//}




public void getAllPredecessors() {
	rel [int, int] r = { <1,2>}; 
	Graph g = {<1, 2>, <1, 3>, <2, 4>, <3, 4> };
	set [int] immPredecessors = predecessors(g, 4);
	iprintln(immPredecessors); 
}





set [loc] getGenericParentCanidates (set [Declaration] projectASts) {
	set [loc] retSet = {};
	for ( Declaration anAST <- projectASTs) {
		list [Expression] passedArguments = [];
		visit (anAST) {
			case methCall1:methodCall(_,_,args:_) : {
				passedArguments = args;
			}
			case methCall2:methodCall(_,_,_,args:_) : {
				passedArguments = args;
			}
		}
		
	}
	return retSet;
}


