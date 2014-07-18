module inheritance::ExternalReuse

import IO;
import Map;
import Set;
import Relation;
import List;
import ListRelation;
import Node;
import ValueIO;

import util::ValueUI;

import lang::java::m3::Core;
import lang::java::m3::AST;
import lang::java::jdt::m3::Core;
import lang::java::m3::TypeSymbol;

import inheritance::InheritanceDataTypes;
import inheritance::InheritanceModules;





public loc getImmParentForAccess(loc classOrInterfaceOfReceiver, loc accessedFieldOrMethod, 	
																	map [loc, set[loc]] 	invClassAndInterfaceContainment,  
																	map [loc, set[loc]] 	declarationsMap,
																	rel [loc, loc] 			allInheritanceRelations, 
																	map [loc, set[loc]] 	extendsMap,
																	map [loc, set[loc]] 	implementsMap, 
												M3 projectM3) {
	loc immediateParentOfReceiver = DEFAULT_LOC; 
	bool direct = false;
	
	if (isLocDefinedInProject(classOrInterfaceOfReceiver, declarationsMap) && !	(isLocDefinedInGivenType(accessedFieldOrMethod, classOrInterfaceOfReceiver, invClassAndInterfaceContainment))) {   // external reuse
		if (isLocDefinedInProject(accessedFieldOrMethod,  declarationsMap)) {
			loc locDefiningClassOrInterface = getDefiningClassOrInterfaceOfALoc(accessedFieldOrMethod, invClassAndInterfaceContainment, projectM3);
			immediateParentOfReceiver = getImmediateParentGivenAnAsc(classOrInterfaceOfReceiver, locDefiningClassOrInterface, extendsMap, implementsMap, allInheritanceRelations);
		}
		else { 
			immediateParentOfReceiver = getImmediateParent(classOrInterfaceOfReceiver, extendsMap, implementsMap, declarationsMap);
		}
	}
	return immediateParentOfReceiver ;
}



public lrel [inheritanceKey, inheritanceSubtype, loc, loc] getExternalReuseGeneral (TypeSymbol recTypeSymbol, loc accessedLoc, loc srcRef, 
																						map [loc, set[loc]] 	invClassAndInterfaceContainment,  
																						map [loc, set[loc]] 	declarationsMap,
																						rel [loc, loc] 			allInheritanceRelations, 
																						map[loc, set[loc]] 		extendsMap,
																						map[loc, set[loc]] 		implementsMap,
																						M3 projectM3) {
	lrel [inheritanceKey, inheritanceSubtype, loc, loc] retList = [];
	loc classOrInterfaceOfReceiver 	= getClassOrInterfaceFromTypeSymbol(recTypeSymbol);
	immediateParentOfReceiver = getImmParentForAccess(classOrInterfaceOfReceiver, accessedLoc, 	invClassAndInterfaceContainment,  declarationsMap, 
																				allInheritanceRelations, extendsMap, implementsMap, projectM3);
	if (immediateParentOfReceiver != DEFAULT_LOC) { // external reuse
		if ((isLocDefinedInProject(accessedLoc, declarationsMap)) && isLocDefinedInGivenType(accessedLoc, immediateParentOfReceiver, invClassAndInterfaceContainment)) {
			retList += <<classOrInterfaceOfReceiver, immediateParentOfReceiver>, EXTERNAL_REUSE_DIRECT, srcRef, accessedLoc>; 
		}  
		else {
			if (isLocDefinedInProject(accessedLoc, declarationsMap) ) {
				loc definingTypeOfLoc = getDefiningClassOrInterfaceOfALoc(accessedLoc, invClassAndInterfaceContainment, projectM3);
				lrel [loc, loc] inhChain = getInheritanceChainGivenAsc( classOrInterfaceOfReceiver, definingTypeOfLoc,  extendsMap, implementsMap,  declarationsMap, allInheritanceRelations);
				for (aPair <- inhChain) {
					retList += <aPair, EXTERNAL_REUSE_INDIRECT, srcRef, accessedLoc>; 
				}
			}
			else {	// LIMITATION! If the accessedLoc is defined outside of the project, we just insert the immediate parent and nothing else in between.
				retList += <<classOrInterfaceOfReceiver, immediateParentOfReceiver>, EXTERNAL_REUSE_INDIRECT, srcRef, accessedLoc>; 
			}
		}
	}

	return retList;
}






public lrel [inheritanceKey, inheritanceSubtype, loc, loc] getExternalReuseViaMethodCall(Expression mCall, loc  classOfMethodCall, 
																						map [loc, set[loc]] 	invClassAndInterfaceContainment,  
																						map [loc, set[loc]] 	declarationsMap,
																						rel [loc, loc] 			allInheritanceRelations, 
																						map[loc, set[loc]] 		extendsMap,
																						map[loc, set[loc]] 		implementsMap,
																						M3 projectM3) {
	lrel [inheritanceKey, inheritanceSubtype, loc, loc] retList = [];
	loc methodDefiningClassOrInterface = DEFAULT_LOC;
	visit (mCall) {
		case m2:\methodCall(_, receiver:_, _, _): {
			loc invokedMethod = m2@decl;        	
			if (invokedMethod == |unresolved:///|) {
				appendToFile(getFilename(projectM3.id, errorLog), "In getExternalReuseViaMethodCall, methodcall decl unresolved for method call: <invokedMethod>, at <m2@src>. Receiver is: <receiver>\n");
				println("Methodcall decl unresolved for method call: <invokedMethod>, at <m2@src>. Receiver is: <receiver>");
			}
			else {		
				retList = getExternalReuseGeneral (receiver@typ, invokedMethod, m2@src, invClassAndInterfaceContainment,  declarationsMap, allInheritanceRelations, extendsMap, implementsMap, projectM3);
			} // else	
   		} // case methodCall()
   	}  // visit
	return retList;
}


public lrel [inheritanceKey, inheritanceSubtype, loc, loc] getExternalReuseViaFieldAccess(Expression qName, map [loc, set[loc]] 	invClassAndInterfaceContainment,  
																											map [loc, set[loc]] 	declarationsMap,
																											rel [loc, loc] 			allInheritanceRelations, 
																											map[loc, set[loc]] 		extendsMap,
																											map[loc, set[loc]] 		implementsMap,
																											M3 projectM3) {
	lrel [inheritanceKey, inheritanceSubtype, loc, loc] retList = [];
	loc accessedField = DEFAULT_LOC;
	TypeSymbol receiverTypeSymbol = DEFAULT_TYPE_SYMBOL;
	loc srcRef = DEFAULT_LOC;
	bool isThisReference = false; 
	visit (qName) {
		case qName:\qualifiedName(qualifier, expression) : {
			accessedField = expression@decl;
			if (isField(accessedField) ) { receiverTypeSymbol = qualifier@typ; }
			srcRef = expression@src;
			fieldReceiver = qualifier@decl;
		} 
		case fAccessStmt:\fieldAccess(isSuper, fAccessExpr:_, str name:_) : {
			accessedField = fAccessStmt@decl;
			receiverTypeSymbol = fAccessExpr@typ;
			srcRef = fAccessStmt@src;		
			isThisReference = (fAccessExpr := this());
		}
	}  // visit
	if (isField(accessedField) && !(isThisReference) ) {
		retList = getExternalReuseGeneral (receiverTypeSymbol, accessedField, srcRef, invClassAndInterfaceContainment,  declarationsMap, allInheritanceRelations, extendsMap, implementsMap, projectM3);
	} // if
	return retList;
}

private map [metricsType, num]  calculateExternalReuseIndirectPercentages(	rel [inheritanceKey, inheritanceType] explicitFoundInhrels, 
																			rel [inheritanceKey, inheritanceType]  addedImplicitRels, M3 projectM3) {
	map [metricsType, num] addedResultsMap = ();
	addedResultsMap += (perAddedCCExtReuse : getPercentageAdded(explicitFoundInhrels, addedImplicitRels, EXTERNAL_REUSE, "java+class", "java+class"));
	addedResultsMap += (perAddedCIExtReuse : getPercentageAdded(explicitFoundInhrels, addedImplicitRels, EXTERNAL_REUSE, "java+class", "java+interface"));
	addedResultsMap += (perAddedIIExtReuse : getPercentageAdded(explicitFoundInhrels, addedImplicitRels, EXTERNAL_REUSE, "java+interface", "java+interface"));
	for (aMetric <- [perAddedCCExtReuse, perAddedCIExtReuse, perAddedIIExtReuse]) {
		println("<getNameOfInheritanceMetric(aMetric)> : <addedResultsMap[aMetric]>");
		appendToFile(getFilename(projectM3.id, addedPercentagesFile), "<addedResultsMap[aMetric]> \t");
	}
	return addedResultsMap;
}




public rel [inheritanceKey, inheritanceType] getExternalReuseCases(M3 projectM3) {
	rel [inheritanceKey, inheritanceType] resultRel = {};
	lrel [inheritanceKey, inheritanceSubtype, loc, loc] allExternalReuseCases = [];
	lrel [inheritanceKey, inheritanceType, loc, loc] allCandExtReuseCases = [];
	set	[loc] 				allClassesInProject 		= {decl | <decl, prjct> <- projectM3@declarations, isClass(decl) };
	map [loc, set [loc]] 	containmentMapForMethods 	= toMap({<owner, declared> | <owner,declared> <- projectM3@containment, isClass(owner), isMethod(declared)});
	map [loc, set [loc]] 	invertedClassContainment 	= toMap(invert({<owner, declared> | <owner,declared> <- projectM3@containment, isClass(owner)}));
	map [loc, set [loc]] 	invClassAndInterfaceContainment 	= getInvertedClassAndInterfaceContainment(projectM3);
	map [loc, set [loc]] 	invClassInterfaceMethodContainment  = getInvertedClassInterfaceMethodContainment(projectM3); 
	map [loc, set [loc]] 	declarationsMap				= toMap({<aLoc, aProject> | <aLoc, aProject> <- projectM3@declarations});
	map [loc, set [loc]]	extendsMap 		= toMap({<_child, _parent> | <_child, _parent> <- projectM3@extends});
	map [loc, set [loc]]    implementsMap  	= toMap({<_child, _parent> | <_child, _parent> <- projectM3@implements});
	rel [loc, loc] 			allInheritanceRelations 	= getInheritanceRelations(projectM3);
	map [loc, set[loc]] 	invertedUnitContainment 	= getInvertedUnitContainment(projectM3);
	for (oneClass <- allClassesInProject) {
		list [Declaration] ASTsOfOneClass = getASTsOfAClass(oneClass, invClassInterfaceMethodContainment, invertedUnitContainment, declarationsMap, projectM3);
		for (oneAST <- ASTsOfOneClass) {
			visit(oneAST) {
        		case qName:\qualifiedName(_, _) : {
        			allExternalReuseCases += getExternalReuseViaFieldAccess(qName, invClassAndInterfaceContainment, declarationsMap, allInheritanceRelations, extendsMap, implementsMap, projectM3);
        		}
        		case fAccess:\fieldAccess(_,_,_) : {
        			allExternalReuseCases += getExternalReuseViaFieldAccess(fAccess, invClassAndInterfaceContainment, declarationsMap, allInheritanceRelations, extendsMap, implementsMap, projectM3);
        		}
			case m2:\methodCall(_, receiver:_, _, _): {
				allExternalReuseCases += getExternalReuseViaMethodCall(m2, oneClass, invClassAndInterfaceContainment, declarationsMap, allInheritanceRelations, extendsMap, implementsMap, projectM3);
        		} // case methodCall()
        	} // visit()
		}	// for each method in the class															
	}	// for each class in the project
	rel [inheritanceKey, inheritanceType] directExReusePairs = {};
	rel [inheritanceKey, inheritanceType] indirectExReusePairs = {};
	for ( int i <- [0..size(allExternalReuseCases)]) { 
		tuple [ inheritanceKey iKey, inheritanceSubtype iType, loc srcLoc, loc accessedLoc] aCase = allExternalReuseCases[i];
		if (aCase.iType == EXTERNAL_REUSE_DIRECT) { directExReusePairs += <aCase.iKey, EXTERNAL_REUSE> ; }
		if (aCase.iType == EXTERNAL_REUSE_INDIRECT) { indirectExReusePairs += <aCase.iKey, EXTERNAL_REUSE> ; }
		resultRel += <aCase.iKey, EXTERNAL_REUSE>;
	}
	calculateExternalReuseIndirectPercentages(directExReusePairs, indirectExReusePairs, projectM3);
	iprintToFile(getFilename(projectM3.id, externalReuseLogFile), allExternalReuseCases);
	return resultRel;
}

