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


private tuple [bool, loc] isDowncall(loc invokedMethod, loc classOfReceiver, 	loc refToDowncall, rel [loc, loc, loc, loc] downcallCandidates, 
																				rel [loc, loc] allInheritanceRels, map[loc, set[loc]] extendsMap) {
	bool retBool = false;
	loc theIssuerMethod= DEFAULT_LOC, descDowncalledMethod = DEFAULT_LOC;
	rel [loc, loc, loc, loc] downcallSet = {<_ascClass, _descClass, _ascIssuerMethod, _descDowncalledMethod> | <_ascClass, _descClass, _ascIssuerMethod, _descDowncalledMethod> <- downcallCandidates, 
																		invokedMethod == _ascIssuerMethod,
																		classOfReceiver == _descClass ||
																		classOfReceiver in getDescendantsOfAClass(_descClass, allInheritanceRels)
																		};
	//println();
	//println("Downcall set:");																		
	//iprintln(<sort(downcallSet)>);
	if (size(downcallSet) >= 1) {
		tuple [loc _ascClass, loc _descClass, loc _ascIssuerMethod, loc _descDowncalledMethod] downcallCase = getOneFrom(downcallSet);
		theIssuerMethod = downcallCase._ascIssuerMethod;
		if (size(downcallSet) == 1) {
			descDowncalledMethod = downcallCase._descDowncalledMethod;
		}
		else {
			list [loc] ascendantsInOrder = getAscendantsInOrder(classOfReceiver, extendsMap);
			for ( aNode <- ascendantsInOrder) {
				set [loc] anotherDowncallSet = {_descDowncalledMethod | <_ascClass, _descClass, _ascIssuerMethod, _descDowncalledMethod> <- downcallSet, 
																_ascIssuerMethod == invokedMethod,		// added on 19-5-2014
																_descClass == aNode};
				if (size(anotherDowncallSet) == 1) {
					descDowncalledMethod = getOneFrom(anotherDowncallSet);
					break;
				}
				else {
					if (size(anotherDowncallSet) > 1) {
						// There are more than one descDowncalledmethod's. I put an arbitrarily slected one to the log
						descDowncalledMethod = getOneFrom(anotherDowncallSet);
						break;
						//
						//println("Problem with downcall at: <refToDowncall>. invokedMethod: <invokedMethod>, classOfReceiver: <classOfReceiver>, theIssuerMethod: <theIssuerMethod >");
						//throw "Size of Another downcallset is greater than one. anotherDowncallSet : <anotherDowncallSet>";
					}
				}
			}		
		}
		retBool = true;
	}
	return <retBool, descDowncalledMethod>;
}


private rel [loc, loc, loc, loc] getDowncallCandidates(map[loc, set[loc]] invertedClassAndInterfaceContainment , M3 projectM3) {
	// TODO: Think about how to deal with constructors...
	rel [loc ascendingClass, loc descendingClass, loc ascIssureMethod, loc descDowncalledMethod] downcallCandidates = {};
	set [loc] allMethodsInProject = {definedMethod | <definedMethod, project> <- projectM3@declarations, isMethod(definedMethod)};
	rel [loc, loc] allOverriddenMethods = {<descMeth, ascMeth> | <descMeth, ascMeth> <- projectM3@methodOverrides, ascMeth in allMethodsInProject};
	map [loc, set [loc]] 	containmentMapForMethods 	= toMap({<owner, declared> | <owner,declared> <- projectM3@containment, isClass(owner), isMethod(declared)});
	for (<descMeth, ascMeth> <- allOverriddenMethods) {
		loc ascClass 		= getDefiningClassOrInterfaceOfALoc(ascMeth, invertedClassAndInterfaceContainment );
		loc descClass 		= getDefiningClassOrInterfaceOfALoc(descMeth, invertedClassAndInterfaceContainment );
		set [loc] methodsInAscClass = ascClass in  containmentMapForMethods ? containmentMapForMethods[ascClass] : {};
		for (issuerMethod <- methodsInAscClass) {
			methodAST = getMethodASTEclipse(issuerMethod, model = projectM3);	
			visit(methodAST) {
				case mCall1:\methodCall(_,_,_) : {
					if ((mCall1@decl == ascMeth) && !isMethodOverriddenByDescClass(issuerMethod, descClass, invertedClassAndInterfaceContainment , projectM3)) {
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
	// Downcall is only possible between class class edges, by definition.
	map [loc, set[loc]] 	invertedClassAndInterfaceContainment = getInvertedClassAndInterfaceContainment(projectM3);
	map [loc, set[loc]] 	invertedClassInterfaceMethodContainment = getInvertedClassInterfaceMethodContainment(projectM3);
	map [loc, set [loc]] 	containmentMapForMethods 	= toMap({<owner, declared> | <owner,declared> <- projectM3@containment, isClass(owner), isMethod(declared)});
	map [loc, set [loc]]	extendsMap 					= toMap({<_child, _parent> | <_child, _parent> <- projectM3@extends});
	rel [loc, loc] 			allInheritanceRels 			= getNonFrameworkInheritanceRels(getInheritanceRelations(projectM3), projectM3);
	map [loc, set[loc]] 	invertedUnitContainment 	= getInvertedUnitContainment(projectM3);
	map [loc, set [loc]] 	declarationsMap				= toMap({<aLoc, aProject> | <aLoc, aProject> <- projectM3@declarations});
	rel [loc ascendingClass, loc descendingClass, loc ascIssuerMethod, loc descDowncalledMethod] downcallCandidates = getDowncallCandidates(invertedClassAndInterfaceContainment , projectM3);
	lrel [inheritanceKey, downcallDetail] downcallLog = [];
	rel [inheritanceKey, inheritanceType] resultRel = {};
	set [loc] allClassesInProject = getAllClassesInProject(projectM3);
	for (oneClass <- allClassesInProject ) {
		list [Declaration] ASTsOfOneClass = getASTsOfAClass(oneClass, invertedClassInterfaceMethodContainment, invertedUnitContainment, declarationsMap);
		for (oneAST <- ASTsOfOneClass) {
			visit(oneAST) {
				case mCall1:\methodCall(_, receiver:_, _, _): {
					loc invokedMethod = mCall1@decl;
					loc classOfReceiver = getClassFromTypeSymbol(receiver@typ);
					tuple [bool downcallBool, loc descDCallMeth] downcallResult = isDowncall(invokedMethod, classOfReceiver, mCall1@src, downcallCandidates, allInheritanceRels, extendsMap);
					if (downcallResult.downcallBool) {
						downcallLog += <<classOfReceiver, getDefiningClassOrInterfaceOfALoc(invokedMethod, invertedClassAndInterfaceContainment )>, <mCall1@src, invokedMethod, downcallResult.descDCallMeth>>;
					}	
				}
				case mCall2:\methodCall(_,_,_) : {
					loc invokedMethod = mCall2@decl;
					loc classOfReceiver = oneClass;
					tuple [bool downcallBool, loc descDCallMeth] downcallResult = isDowncall(invokedMethod, classOfReceiver, mCall2@src, downcallCandidates, allInheritanceRels, extendsMap);					
					if (downcallResult.downcallBool) {
						downcallLog += <<classOfReceiver, getDefiningClassOrInterfaceOfALoc(invokedMethod, invertedClassAndInterfaceContainment )>, <mCall2@src, invokedMethod, downcallResult.descDCallMeth>>;
					}	
				}
			}
		}		
	}	
	for ( int i <- [0..size(downcallLog)]) { 
		tuple [ inheritanceKey iKey, downcallDetail dDetail] aCase = downcallLog[i];
		resultRel += <aCase.iKey, DOWNCALL_ACTUAL>;
	}
	resultRel += {<<_child, _parent>, DOWNCALL_CANDIDATE> | <_parent, _child, _issMethod, _downcalledMethod> <- downcallCandidates };
	downcallLog += [<<_child, _parent>, <DEFAULT_LOC, _issMethod, _downcalledMethod>> | <_parent, _child, _issMethod, _downcalledMethod> <- downcallCandidates ];
	iprintToFile(downcallLogFile,downcallLog);
	return resultRel;
}
