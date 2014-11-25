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
					}
				}
			}		
		}
		retBool = true;
	}
	return <retBool, descDowncalledMethod>;
}


map [loc, set[loc]] getInvertedOverridesMap (M3 projectM3) {
	map [loc, set[loc]] retMap = ();
	set [loc] allMethodsInProject 		= {definedMethod | <definedMethod, project> <- projectM3@declarations, isMethod(definedMethod)};
	rel [loc, loc] allOverriddenMethods = {<descMeth, ascMeth> | <descMeth, ascMeth> <- projectM3@methodOverrides, ascMeth in allMethodsInProject};
	if (!isEmpty(allOverriddenMethods)) {
		retMap = toMap(invert(allOverriddenMethods));
	}
	return retMap;
}


loc getDescOverridingMethod(set [loc] overridingMethods, loc _descClass,map [loc, set[loc]] invertedContainment) {
	loc retMethod 		= DEFAULT_LOC;
	int numOfMethods 	= size(overridingMethods);
	list [loc] methodList 	= toList(overridingMethods);
	int i = 0; 
	bool found 	= false;
	while ( ( i < numOfMethods) && (!found) ) {
		loc aMethod = methodList[i];
		loc definingClassOfAMethod = getDefiningClassOfALoc(aMethod, invertedContainment);
		if (definingClassOfAMethod == _descClass) {
			retMethod = aMethod;
			found = true;
		}		
		i = i + 1;
	}
	return retMethod;
}


private rel [loc, loc, loc, loc] getDowncallCandidatesFromInitializers(map[loc, set[loc]] invertedClassAndInterfaceContainment , M3 projectM3) {
	rel [loc ascendingClass, loc descendingClass, loc initializer, loc descDowncalledMethod] initializerCandidates = {};
	map [loc, set[loc]] invertedUnitContainment = getInvertedUnitContainment(projectM3);
	map [loc, set[loc]] invertedContainment 	= getInvertedClassAndInterfaceContainment(projectM3);
	map [loc, set[loc]] invertedClassInterfaceMethodContainment = getInvertedClassInterfaceMethodContainment(projectM3);
	map [loc, set[loc]] declarationsMap 		= toMap({<aLoc, aProject> | <aLoc, aProject> <- projectM3@declarations});
	set [loc] 			allClassesInProject 	= getAllClassesInProject(projectM3);
	rel [loc, loc] 		inhClassPairs 			= { <_descClass, _ascClass> | <_descClass, _ascClass> <- getInheritanceRelations(projectM3), 	_descClass in allClassesInProject , 
																																				_ascClass in allClassesInProject };
	map [ loc, set[loc]] invertedOverridesMap =  getInvertedOverridesMap (projectM3); 
	for ( <_descClass, _ascClass> <- inhClassPairs){
		list [Declaration] astsOfAscClass = getASTsOfAClass(_ascClass, invertedClassInterfaceMethodContainment, invertedUnitContainment, declarationsMap, projectM3);
		for (anAST <-astsOfAscClass) {
			visit (anAST) {
				case anInitializer:\initializer(Statement initializerBody) : {
					visit (anInitializer) {
						case m1:\methodCall(_,_,_) : {
							invokedMethod = m1@decl;
							set [loc] overridingMethods = invokedMethod in invertedOverridesMap ? invertedOverridesMap[invokedMethod] : {};
							loc overridingDescMethod = getDescOverridingMethod(overridingMethods, _descClass, invertedContainment);
							if (overridingDescMethod != DEFAULT_LOC) {
								initializerCandidates += <_ascClass, _descClass, anInitializer@decl, overridingDescMethod>;						
							}  // if
						}  // case methodCall
						case m2:\methodCall(_,Expression receiver,_,_) : {
							if (receiver := this()) {
								invokedMethod = m2@decl;
								set [loc] overridingMethods = invokedMethod in invertedOverridesMap ? invertedOverridesMap[invokedMethod] : {};
								loc overridingDescMethod = getDescOverridingMethod(overridingMethods, _descClass, invertedContainment);
								if (overridingDescMethod != DEFAULT_LOC) {
									initializerCandidates += <_ascClass, _descClass, anInitializer@decl, overridingDescMethod>;						
								}  // if				
							}		
						;} // case m2
					} // visit (initializer)
				} // case initializer
			} // visit AST
		} // for anAST
	} // for _descClass, _ascClass
	return initializerCandidates;
}


private rel [loc, loc, loc, loc] getDowncallCandidates(map[loc, set[loc]] invertedClassAndInterfaceContainment , M3 projectM3) {
	// Constructors are also included in the candidate analysis.
	rel [loc ascendingClass, loc descendingClass, loc ascIssureMethod, loc descDowncalledMethod] downcallCandidates = {};
	set [loc] 				allMethodsInProject 		= {definedMethod | <definedMethod, project> <- projectM3@declarations, isMethod(definedMethod)};
	rel [loc, loc] 			allOverriddenMethods 		= {<descMeth, ascMeth> | <descMeth, ascMeth> <- projectM3@methodOverrides, ascMeth in allMethodsInProject};
	map [loc, set [loc]] 	containmentMapForMethods 	= toMap({<owner, declared> | <owner,declared> <- projectM3@containment, isClass(owner), isMethod(declared)});
	for (<descMeth, ascMeth> <- allOverriddenMethods) {
		loc ascClass 				= getDefiningClassOrInterfaceOfALoc(ascMeth, invertedClassAndInterfaceContainment, projectM3 );
		loc descClass 				= getDefiningClassOrInterfaceOfALoc(descMeth, invertedClassAndInterfaceContainment, projectM3 );
		if ((ascClass != DEFAULT_LOC) && (descClass != DEFAULT_LOC)) {
			set [loc] methodsInAscClass = ascClass in  containmentMapForMethods ? containmentMapForMethods[ascClass] : {};
			for (issuerMethod <- methodsInAscClass) {
				methodAST = getMethodASTEclipse(issuerMethod, model = projectM3);	
				visit(methodAST) {
					case mCall1:\methodCall(_,_,_) : {
						if ((mCall1@decl == ascMeth) && !isMethodOverriddenByDescClass(issuerMethod, descClass, invertedClassAndInterfaceContainment , projectM3)) {
							downcallCandidates += <ascClass, descClass, issuerMethod, descMeth >;						
						}
					 }
					 case mCall2:\methodCall(_, Expression receiver, _, _) : {
					 	if (receiver := this() && (mCall2@decl == ascMeth) && !isMethodOverriddenByDescClass(issuerMethod, descClass, invertedClassAndInterfaceContainment , projectM3)) {
							downcallCandidates += <ascClass, descClass, issuerMethod, descMeth >;						
					 	}
					 }
				} // visit
			}	// for
		} // if 			 
	}
	downcallCandidates += getDowncallCandidatesFromInitializers(invertedClassAndInterfaceContainment, projectM3); 
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
		list [Declaration] ASTsOfOneClass = getASTsOfAClass(oneClass, invertedClassInterfaceMethodContainment, invertedUnitContainment, declarationsMap, projectM3);
		for (oneAST <- ASTsOfOneClass) {
			visit(oneAST) {
				case mCall1:\methodCall(_, receiver:_, _, _): {
					loc invokedMethod = mCall1@decl;
					TypeSymbol receiverTypeSymbol = getTypeSymbolFromAnnotation(receiver,  projectM3);
					if (receiverTypeSymbol != DEFAULT_TYPE_SYMBOL) {
						loc classOfReceiver = getClassFromTypeSymbol(receiverTypeSymbol);
						tuple [bool downcallBool, loc descDCallMeth] downcallResult = isDowncall(invokedMethod, classOfReceiver, mCall1@src, downcallCandidates, allInheritanceRels, extendsMap);
						if (downcallResult.downcallBool) {
							downcallLog += <<classOfReceiver, getDefiningClassOrInterfaceOfALoc(invokedMethod, invertedClassAndInterfaceContainment, projectM3 )>, <mCall1@src, invokedMethod, downcallResult.descDCallMeth>>;
						}
					}	
				}
				case mCall2:\methodCall(_,_,_) : {
					loc invokedMethod = mCall2@decl;
					loc classOfReceiver = oneClass;
					tuple [bool downcallBool, loc descDCallMeth] downcallResult = isDowncall(invokedMethod, classOfReceiver, mCall2@src, downcallCandidates, allInheritanceRels, extendsMap);					
					if (downcallResult.downcallBool) {
						downcallLog += <<classOfReceiver, getDefiningClassOrInterfaceOfALoc(invokedMethod, invertedClassAndInterfaceContainment, projectM3 )>, <mCall2@src, invokedMethod, downcallResult.descDCallMeth>>;
					}	
				}
			}
		}		
	}	
	println("Downcall actual log: ");
	for ( int i <- [0..size(downcallLog)]) { 
		tuple [ inheritanceKey iKey, downcallDetail dDetail] aCase = downcallLog[i];
		resultRel += <aCase.iKey, DOWNCALL_ACTUAL>;
		println(<downcallLog[i]>);
	}
	resultRel += {<<_child, _parent>, DOWNCALL_CANDIDATE> | <_parent, _child, _issMethod, _downcalledMethod> <- downcallCandidates };
	println("Result relation for down-call: "); iprintln(resultRel); println("\n\n\n");
	num sizeOfActuals = size({<_child, _parent> | <<_child, _parent>, _actualCandidate> <- resultRel, _actualCandidate == DOWNCALL_ACTUAL} );
	print("Number of actual down-calls counted for project is:   " ); println("<sizeOfActuals> \n\n");
	writeTextValueFile(getFilename(projectM3.id, numDCOccFile), sizeOfActuals);
	downcallLog += [<<_child, _parent>, <DEFAULT_LOC, _issMethod, _downcalledMethod>> | <_parent, _child, _issMethod, _downcalledMethod> <- downcallCandidates ];
	iprintToFile(getFilename(projectM3.id,downcallLogFile), downcallLog);
	return resultRel;
}
