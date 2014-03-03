module inheritance::DowncallCases

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


private tuple [bool, loc] isDowncall(loc invokedMethod, loc classOfReceiver, 	rel [loc, loc, loc, loc] downcallCandidates, 
																				rel [loc, loc] allInheritanceRels, M3 projectM3) {
	bool retBool = false;
	loc theIssuerMethod= DEFAULT_LOC, descDowncalledMethod = DEFAULT_LOC;
	rel [loc, loc, loc, loc] downcallSet = {<_ascClass, _descClass, _ascIssuerMethod, _descDowncalledMethod> | <_ascClass, _descClass, _ascIssuerMethod, _descDowncalledMethod> <- downcallCandidates, 
																		invokedMethod == _ascIssuerMethod,
																		classOfReceiver == _descClass ||
																		classOfReceiver in getDescendantsOfAClass(_descClass, allInheritanceRels)
																		};
	if (size(downcallSet) >= 1) {
		tuple [loc _ascClass, loc _descClass, loc _ascIssuerMethod, loc _descDowncalledMethod] downcallCase = getOneFrom(downcallSet);
		theIssuerMethod = downcallCase._ascIssuerMethod;
		if (size(downcallSet) == 1) {
			descDowncalledMethod = downcallCase._descDowncalledMethod;
		}
		else {
			list [loc] ascendantsInOrder = getAscendantsInOrder(classOfReceiver, projectM3);
			for ( aNode <- ascendantsInOrder) {
				set [loc] anotherDowncallSet = {_descDowncalledMethod | <_ascClass, _descClass, _ascIssuerMethod, _descDowncalledMethod> <- downcallSet, 
																_descClass == aNode};
				if (size(anotherDowncallSet) == 1) {
					descDowncalledMethod = getOneFrom(anotherDowncallSet);
					break;
				}
				else {
					if (size(anotherDowncallSet) > 1) {
						throw "Size of Another downcallset is greater than one. anotherDowncallSet : <anotherDowncallSet>";
					}
				}
			}		
		}
		retBool = true;
	}
	return <retBool, descDowncalledMethod>;
}


private rel [loc, loc, loc, loc] getDowncallCandidates(M3 projectM3) {
	// TODO: Think about how to deal with constructors...
	rel [loc ascendingClass, loc descendingClass, loc ascIssureMethod, loc descDowncalledMethod] downcallCandidates = {};
	set [loc] allMethodsInProject = {definedMethod | <definedMethod, project> <- projectM3@declarations, isMethod(definedMethod)};
	rel [loc, loc] allOverriddenMethods = {<descMeth, ascMeth> | <descMeth, ascMeth> <- projectM3@methodOverrides, ascMeth in allMethodsInProject};
	for (<descMeth, ascMeth> <- allOverriddenMethods) {
		loc ascClass = getDefiningClassOfALoc(ascMeth, projectM3);
		loc descClass = getDefiningClassOfALoc(descMeth, projectM3);
		set [loc] methodsInAscClass = {declared | <owner,declared> <- projectM3@containment, owner == ascClass, isMethod(declared) };
		for (issuerMethod <- methodsInAscClass) {
			methodAST = getMethodASTEclipse(issuerMethod, model = projectM3);	
			visit(methodAST) {
				case mCall1:\methodCall(_,_,_) : {
					if ((mCall1@decl == ascMeth) && !isMethodOverriddenByDescClass(issuerMethod, descClass, projectM3)) {
						downcallCandidates += <ascClass, descClass, issuerMethod, descMeth >;						
					}
				 }
			} // visit
		}				 
	}
	println("Number of down call candidates for project: <size(downcallCandidates)>");
	return downcallCandidates;	
}


public rel [inheritanceKey, inheritanceType] getDowncallOccurrences(M3 projectM3) {
	rel [loc, loc] allInheritanceRels = getNonFrameworkInheritanceRels(getInheritanceRelations(projectM3), projectM3);
	rel [loc ascendingClass, loc descendingClass, loc ascIssuerMethod, loc descDowncalledMethod] downcallCandidates = getDowncallCandidates(projectM3);
	lrel [inheritanceKey, downcallDetail] downcallLog = [];
	rel [inheritanceKey, inheritanceType] resultRel = {};
	set [loc] allClassesInProject = getAllClassesInProject(projectM3);
	for (oneClass <- allClassesInProject ) {
		set [loc] methodsInClass = {declared | <owner,declared> <- projectM3@containment, owner == oneClass, isMethod(declared) }; 
		// TODO:take also initializers in to account  
		// || getMethodASTEclipse does not work for initializers. declared.scheme == "java+initializer" 
		for (oneMethod <- methodsInClass) {
			methodAST = getMethodASTEclipse(oneMethod, model = projectM3);	
			visit(methodAST) {
				case mCall1:\methodCall(_, receiver:_, _, _): {
					loc invokedMethod = mCall1@decl;
					loc classOfReceiver = getClassFromTypeSymbol(receiver@typ);
					tuple [bool downcallBool, loc descDCallMeth] downcallResult = isDowncall(invokedMethod, classOfReceiver, downcallCandidates, allInheritanceRels, projectM3);
					if (downcallResult.downcallBool) {
						downcallLog += <<classOfReceiver, getDefiningClassOfALoc(invokedMethod, projectM3)>, <mCall1@src, invokedMethod, downcallResult.descDCallMeth>>;
					}	
				}
				case mCall2:\methodCall(_,_,_) : {
					loc invokedMethod = mCall2@decl;
					loc classOfReceiver = oneClass;
					tuple [bool downcallBool, loc descDCallMeth] downcallResult = isDowncall(invokedMethod, classOfReceiver, downcallCandidates, allInheritanceRels, projectM3);					
					if (downcallResult.downcallBool) {
						downcallLog += <<classOfReceiver, getDefiningClassOfALoc(invokedMethod, projectM3)>, <mCall2@src, invokedMethod, downcallResult.descDCallMeth>>;
					}	
				}
			}
		}		
	}	
	for ( int i <- [0..size(downcallLog)]) { 
		tuple [ inheritanceKey iKey, downcallDetail dDetail] aCase = downcallLog[i];
		resultRel += <aCase.iKey, DOWNCALL>;
	}
	iprintToFile(downcallLogFile,downcallLog);
	return resultRel;
}