module inheritance::SubtypeInheritance

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



public list [TypeSymbol] getPassedSymbolList(Expression methExpr, M3 projectM3) {
	list [Expression] args 		= [];
	list [TypeSymbol] retList 	= [];
	visit (methExpr)  {
		case \methodCall(_,_,myArgs:_) : {
			args = myArgs;
		}
		case \methodCall(_,_,_,myArgs:_) : {
			args = myArgs;
		}
		case newObject1:\newObject(Type \type, list[Expression] expArgs) : {
			args = expArgs;
		}
		case newObject2:\newObject(Type \type, list[Expression] expArgs, Declaration class) : {
			args = expArgs;
		}
		case newObject3:\newObject(Expression expr, Type \type, list[Expression] expArgs) : {
			args = expArgs;		
		}
		case newObject4:\newObject(Expression expr, Type \type, list[Expression] expArgs, Declaration class) : {
			args = expArgs;
		}
		case consCall1:\constructorCall(bool isSuper, list[Expression] expArgs) : {
			args = expArgs;
		}
		case consCall2:\constructorCall(bool isSuper, Expression expr, list[Expression] expArgs) : {
			args = expArgs;
		}
	}
	TypeSymbol argTypeSymbol = DEFAULT_TYPE_SYMBOL;
	for ( int i <- [0..(size(args))]) {
		argTypeSymbol = getTypeSymbolFromAnnotation(args[i], projectM3);
		if (argTypeSymbol == DEFAULT_TYPE_SYMBOL) {
			println("No such symbol annotation for : Method expression: <methExpr>, args: <args>");
			retList = [];
			break;
		}
		retList += argTypeSymbol;
	}
	return retList;
}


private lrel [inheritanceKey, inheritanceSubtype , loc]  getSubtypeResultViaAssignment(Expression lhs, Expression rhs, loc sourceRef, M3 projectM3) {
	lrel [inheritanceKey, inheritanceSubtype , loc ] retList = [];
	//println("Assignment source ref: <sourceRef>");
	// error NoSuchAnnotation retExpr@typ
	TypeSymbol lhsTypeSymbol = getTypeSymbolFromAnnotation(lhs, projectM3);
	TypeSymbol rhsTypeSymbol = getTypeSymbolFromAnnotation(rhs, projectM3);
	if ( (lhsTypeSymbol == DEFAULT_TYPE_SYMBOL) || (rhsTypeSymbol == DEFAULT_TYPE_SYMBOL)) {
		println("In getSubtypeResultViaAssignment, NoSuchAnnotation exception thrown for: lhs: : <lhs>, or rhs: <rhs> at sourceref : <sourceRef>");
	}
	else {
		tuple [bool isSubtypeRel, inheritanceKey iKey] result = getSubtypeRelation(rhsTypeSymbol, lhsTypeSymbol);
		if (result.isSubtypeRel) {
			retList += <result.iKey, SUBTYPE_ASSIGNMENT_STMT, sourceRef>;
		} // if
	}
	return retList;
}



public lrel [inheritanceKey, inheritanceSubtype , loc ] getSubtypeViaAssignment(Expression asmtStmt, M3 projectM3) {
	lrel [inheritanceKey, inheritanceSubtype , loc ] retList = [];
	bool isConditional = false;
	visit (asmtStmt) {
		case aStmt:\assignment(lhs, operator, rhs) : {  
			visit (aStmt) {
				case conditionalS:\conditional(logicalExpr, thenBranch, elseBranch) : {		// ternary operator, ,ex: p4 = (i == 3) ? new C() : new G();
					isConditional = true;
					retList += getSubtypeResultViaAssignment(lhs, thenBranch, conditionalS@src, projectM3);
					retList += getSubtypeResultViaAssignment(lhs, elseBranch, conditionalS@src, projectM3);				
				} 
			}
			if (!isConditional) {
				retList += getSubtypeResultViaAssignment(lhs, rhs, aStmt@src, projectM3);
			}																					   
		}	// case	
	} // visit
	return retList;
}


private lrel [inheritanceKey, inheritanceSubtype , loc ] getSubtypeResultViaVariable(TypeSymbol lhsTypeSymbol, Expression rhs, list [Expression] fragments, M3 projectM3) {
	lrel [inheritanceKey, inheritanceSubtype , loc ] retList = [];
	//println("Variable decl: <rhs@src>");	
	TypeSymbol rhsTypeSymbol = getTypeSymbolFromAnnotation(rhs, projectM3);
	if (rhsTypeSymbol != DEFAULT_TYPE_SYMBOL) {
		tuple [bool isSubtypeRel, inheritanceKey iKey] result = getSubtypeRelation(rhsTypeSymbol, lhsTypeSymbol); 
		if (result.isSubtypeRel) {
			//println("Fragments: "); iprintln(fragments); 
			for (anExpression <- fragments) {
				retList += <result.iKey, SUBTYPE_ASSIGNMENT_VAR_DECL, anExpression@decl>;
			}
		}
	}
	return retList;
}


public lrel [inheritanceKey, inheritanceSubtype , loc ]  getSubtypeViaVariables(Type typeOfVar, list[Expression] fragments, M3 projectM3) {
	lrel [inheritanceKey, inheritanceSubtype , loc ] retList = [];
	bool isConditional = false;
	TypeSymbol lhsTypeSymbol = getTypeSymbolFromRascalType(typeOfVar);
	//println("Type of var is: <typeOfVar> for variable: <fragments[0]@decl>");
	visit (fragments[size(fragments) - 1]) {
		case nullVar: \variable(_, _ , null()) : { 
			// a null initialization should not be counted as subtype
		;}
		case myVar: \variable(_,_,stmt) : {
			visit (stmt) {
				case conditionalS:\conditional(logicalExpr, thenBranch, elseBranch) : {
					isConditional = true;
					retList += getSubtypeResultViaVariable(lhsTypeSymbol , thenBranch, fragments, projectM3);
					retList += getSubtypeResultViaVariable(lhsTypeSymbol , elseBranch, fragments, projectM3);				
				}
			} 
			if (!isConditional) {
				retList += getSubtypeResultViaVariable(lhsTypeSymbol , stmt, fragments, projectM3);
			}	
		} // case myVar
  	}  // visit fragments
 	return retList;
}





private bool isUpCasting(loc aChild, loc aParent, map [loc, set [loc]] inheritanceRelsMap ) {
	bool retBool = false;
	if ( (aChild == OBJECT_CLASS) && (aParent != OBJECT_CLASS) ) {
		retBool = true;
	} 
	else {
		set [loc] allParentsOfAChild = (aChild in inheritanceRelsMap) ? inheritanceRelsMap[aChild] : {};
		if (aParent notin allParentsOfAChild) {
			// we suspect upcasting
			set [loc] reverseParentSet = (aParent in inheritanceRelsMap) ? inheritanceRelsMap[aParent] : {};
			if (aChild in reverseParentSet) {
				retBool = true;
			}
		}
	;}
	if (retBool) {	println("upcasting between <aChild> and <aParent>....."); }
	return retBool;
}


private tuple [bool , loc ] isSidewaysCast(loc aChild, loc aParent, map [loc, set [loc]] inheritanceRelsMap, map [loc, set [loc]] invertedInheritanceRelsMap,   loc castLoc) {
	bool isSideCast = false;
	loc implClass = DEFAULT_LOC;
	set [loc] allParentsOfAChild = (aChild in inheritanceRelsMap) ? inheritanceRelsMap[aChild] : {};
	set [loc] allParentsOfAParent = (aParent in inheritanceRelsMap) ? inheritanceRelsMap[aParent] : {};
	if ( isInterface(aParent) && isInterface(aChild) && (aParent notin allParentsOfAChild) && (aChild notin allParentsOfAParent)) {
		// we suspect sideways casting, find the implementing class
		set [loc] allImplClassesOfParent = (aParent in invertedInheritanceRelsMap) ? invertedInheritanceRelsMap[aParent] : {};
		set [loc] allImplClassesOfChild	 = (aChild in invertedInheritanceRelsMap) ? invertedInheritanceRelsMap[aChild] : {};		
		set [loc] implClasses = allImplClassesOfParent & allImplClassesOfChild;
		if (!isEmpty(implClasses)) {
			isSideCast = true;
			implClass = getOneFrom(implClasses);
		}
		else {
			// possibly non sytem (framework) types.
		;} 
	}
	return <isSideCast, implClass>;
}



public lrel [inheritanceKey, inheritanceSubtype , loc ] getSubtypeViaCast(Expression castStmt, map [loc, set [loc]] inheritanceRelsMap, map [loc, set [loc]] invertedInheritanceRelsMap,
																												M3 projectM3 ) {
// The cast can be from child to parent, but also from parent to child
// Also, sideways cast is possible. 
	lrel [inheritanceKey, inheritanceSubtype , loc ] retList = [];
	visit (castStmt) {
		case \cast(castType, castExpr) : {  
			TypeSymbol castExprTypeSymbol = getTypeSymbolFromAnnotation(castExpr, projectM3);
			if (castExprTypeSymbol != DEFAULT_TYPE_SYMBOL) {
				tuple [bool isSubtypeRel, inheritanceKey iKey] result = getSubtypeRelation(getTypeSymbolFromRascalType(castType), castExprTypeSymbol);
				if (result.isSubtypeRel) {
					bool upcasting = isUpCasting(result.iKey.child, result.iKey.parent, inheritanceRelsMap);
					if (upcasting) {
						// reverse the order if there is upcasting.
						retList += < <result.iKey.parent, result.iKey.child> , SUBTYPE_VIA_UPCASTING, castStmt@src>;				
					}
					else {
						if (isInterface(result.iKey.child) && isInterface (result.iKey.parent) ) {
							tuple [bool isSidewaysCast, loc implChild] sidewaysResult = isSidewaysCast(result.iKey.child, result.iKey.parent, inheritanceRelsMap, invertedInheritanceRelsMap, castStmt@src);
							if (sidewaysResult.isSidewaysCast) {
								retList += <<sidewaysResult.implChild, result.iKey.child>, SUBTYPE_VIA_SIDEWAYS_CASTING, castStmt@src>;
								retList += <<sidewaysResult.implChild, result.iKey.parent>, SUBTYPE_VIA_SIDEWAYS_CASTING, castStmt@src>;						
							}
							else {
								retList += <result.iKey, SUBTYPE_VIA_CAST, castStmt@src>;
							}							
						}
						else {
							retList += <result.iKey, SUBTYPE_VIA_CAST, castStmt@src>;
						}
					}	
				}
			}	 
		} // case
	} // visit
	return retList;
}


private TypeSymbol getTypeSymbolFromTypeParameterList(TypeSymbol collTypeSymbol, loc forLoopRef, list [TypeSymbol] typeParameters, M3 projectM3) {
	TypeSymbol retSymbol = DEFAULT_TYPE_SYMBOL;
	if (size(typeParameters) == 0) { retSymbol = OBJECT_TYPE_SYMBOL; }
	else {
		if (size(typeParameters) == 1)  { 
			retSymbol = typeParameters[0]; 
		}
		else {
			appendToFile(getFilename(projectM3.id, errorLog), "More than one type parameter in class/interface collection def: <collTypeSymbol> at <forLoopRef>. Type parameters: <typeParameters>\n\n");
			println("More than one type parameter in class/interface collection def: <collTypeSymbol> at <forLoopRef>. Type parameters: <typeParameters>"); 
		}	
	}	
	return retSymbol;
}



private lrel [inheritanceKey, inheritanceSubtype , loc ] getSubtypeResultViaForLoop(TypeSymbol paramTypeSymbol, Expression collExpression, loc forLoopRef, M3 projectM3) {
	lrel [inheritanceKey, inheritanceSubtype , loc ] retList = [];
	TypeSymbol compTypeSymbol = DEFAULT_TYPE_SYMBOL;
	TypeSymbol collTypeSymbol = getTypeSymbolFromAnnotation(collExpression,  projectM3); 
	if (collTypeSymbol != DEFAULT_TYPE_SYMBOL) {
		switch (collTypeSymbol) {
			case anArray:\array(TypeSymbol component, int dimension) : {
				compTypeSymbol = component;
			}
			case anInterfaceColl:\class(loc decl, list[TypeSymbol] typeParameters) : {
				compTypeSymbol = getTypeSymbolFromTypeParameterList(collTypeSymbol, forLoopRef, typeParameters, projectM3);
			}
			case aClassColl:\interface(loc decl, list[TypeSymbol] typeParameters) : {
				compTypeSymbol = getTypeSymbolFromTypeParameterList(collTypeSymbol, forLoopRef, typeParameters, projectM3);
			}
		}
		if (compTypeSymbol != DEFAULT_TYPE_SYMBOL) {
			//println("For loop: <forLoopRef>");
			tuple [bool isSubtypeRel, inheritanceKey iKey] result = getSubtypeRelation(compTypeSymbol, paramTypeSymbol);
			if (result.isSubtypeRel) { retList += <result.iKey, SUBTYPE_VIA_FOR_LOOP, forLoopRef>; }
		}
	} 		
	return retList;
}


public lrel [inheritanceKey, inheritanceSubtype , loc ] getSubtypeViaReturnStmt(Statement returnStmt, loc methodLoc,map [loc, set[TypeSymbol]] typesMap, M3 projectM3 ) {
	lrel [inheritanceKey, inheritanceSubtype , loc ] retList = [];
	TypeSymbol retTypeSymbol = DEFAULT_TYPE_SYMBOL;
	visit (returnStmt) {
		case \return(retExpr) : {
			//println("Via return statement: <retExpr@src>");
			// error NoSuchAnnotation retExpr@typ
			retTypeSymbol = getTypeSymbolFromAnnotation(retExpr, projectM3);
			if (retTypeSymbol != DEFAULT_TYPE_SYMBOL) {
				tuple [bool isSubtypeRel, inheritanceKey iKey] result = getSubtypeRelation(retTypeSymbol, 
																						getDeclaredReturnTypeSymbolOfMethod(methodLoc, typesMap));
				if (result.isSubtypeRel) {
					retList += <result.iKey, SUBTYPE_VIA_RETURN, retExpr@src>;
				}
			}	 
		}  
	}
	return retList;
}


private TypeSymbol getTypeSymbolOfVararg(TypeSymbol varargSymbol) {
	TypeSymbol retSymbol = DEFAULT_TYPE_SYMBOL;
	//println("Vararg symbol is: <varargSymbol>");
	if (array(TypeSymbol component, int dimension) := varargSymbol ) {
		retSymbol = component;
	}
	else {
		throw ("In getTypesymbolOfVararg, the vararg is not of type array : <varargSymbol>");
	}
	return retSymbol;
}


private bool isVararg(TypeSymbol passedSymbol, TypeSymbol declaredSymbol, rel [loc, loc] allInheritanceRelations) {
	bool retBool = false;
	if ( array(TypeSymbol component, int dimension) := declaredSymbol ) {
		println("Declared symbol: <declaredSymbol>");
		println("Passed symbol: <passedSymbol>");
		loc declaredLoc = getClassOrInterfaceFromTypeSymbol(declaredSymbol);
		loc passedLoc 	= getClassOrInterfaceFromTypeSymbol(passedSymbol);	
		if (inheritanceRelationExists(passedLoc, declaredLoc, allInheritanceRelations)) {
			retBool = true;
		} 
		//if (component == passedSymbol) {
		//	retBool = true;
		//}
	}
	return retBool;
}



private list [TypeSymbol] updateDeclaredSymbolListForVararg(list [TypeSymbol] passedSymbolList, list [TypeSymbol] declaredSymbolList, rel [loc, loc] allInheritanceRelations, M3 projectM3 ) {
	list [TypeSymbol] retList = [];
	if ( size(passedSymbolList) == size(declaredSymbolList) ) {
		retList = declaredSymbolList;
		if ( size(passedSymbolList) > 0 ) {
			if ( last(passedSymbolList) != last(declaredSymbolList) ) {
				if (isVararg(last(passedSymbolList), last(declaredSymbolList), allInheritanceRelations)) {
					retList[size(retList)-1] = getTypeSymbolOfVararg(last(declaredSymbolList)); 
				}
 			} 
		}
	}
	else {
		if (size(passedSymbolList) < size(declaredSymbolList) ) {
			retList = prefix(declaredSymbolList);
		}
		else {
			if (size(passedSymbolList) > size(declaredSymbolList)) {
				retList = prefix(declaredSymbolList);
				int numOfElementsToAdd = size(passedSymbolList) - size(declaredSymbolList);
				if (isVararg(last(passedSymbolList), last(declaredSymbolList), allInheritanceRelations)) {
					TypeSymbol typeSymbolToAdd = getTypeSymbolOfVararg(declaredSymbolList[size(declaredSymbolList) - 1] );
					for (int i <- [0..numOfElementsToAdd+1]) { retList +=  typeSymbolToAdd ; }
				}
				else {
					appendToFile(getFilename(projectM3.id, errorLog), "In updateDeclaredSymbolListForVararg, the vararg could not be analyzed. Passed symbol list: <passedSymbolList>, declared symbol list: <declaredSymbolList> \n\n");
					println("In updateDeclaredSymbolListForVararg, the vararg could not be analyzed. Passed symbol list: <passedSymbolList>, declared symbol list: <declaredSymbolList> "); 
					retList = [];
				}
			}
		}
	}
	return retList;
}



public lrel [inheritanceKey, inheritanceSubtype , loc ] getSubtypeViaParameterPassing(Expression methOrConstExpr, map [loc, set[loc]] declarationsMap, 
														map [loc, set[TypeSymbol]] 	typesMap, 
														map [loc, set[loc]] 		invertedClassAndInterfaceContainment, 
														map [loc, set [str]] 		invertedNamesMap, 
														rel [loc, loc]				allInheritanceRelations,
														M3 projectM3) {
	lrel [inheritanceKey, inheritanceSubtype , loc ]  retList = [];
	bool analyzeMethod = false;
	list [TypeSymbol] finalDeclaredSymbolList = [];
	list [TypeSymbol] passedSymbolList 		= getPassedSymbolList(methOrConstExpr, projectM3);
	if (methOrConstExpr@decl in typesMap) {
		analyzeMethod = true; 
		list [TypeSymbol] declaredSymbolList	= getDeclaredParameterTypes(methOrConstExpr, typesMap, invertedClassAndInterfaceContainment, projectM3);
		println("For method call at: <methOrConstExpr@src>, method decl: <methOrConstExpr@decl>");
		finalDeclaredSymbolList 				= updateDeclaredSymbolListForVararg(passedSymbolList, declaredSymbolList, allInheritanceRelations,  projectM3);
	}
	else {	// method is not defined in the source, we try to get the method parameters wuth a heuristic.
		str methodStr = (methOrConstExpr@decl).file; 
		finalDeclaredSymbolList = getArgTypeSymbols(methodStr, invertedNamesMap);
	}
	if (!isEmpty(finalDeclaredSymbolList)) {analyzeMethod = true;} 	
	else { analyzeMethod = false; }
	if (analyzeMethod) { 
		if (size(finalDeclaredSymbolList) < size(passedSymbolList)) {	// the number of declared method arguments is less than the number of passed parameters 
			println("For method call at: <methOrConstExpr@src>, the method:<methOrConstExpr@decl> ");
			println("passed symbol list: <passedSymbolList>");
			println("final declared symbol list: <finalDeclaredSymbolList>");
			retList = [];
		}
		else {
			for (int i <- [0..size(passedSymbolList)]) {
				tuple [bool isSubtypeRel, inheritanceKey iKey] result = getSubtypeRelation(passedSymbolList[i], finalDeclaredSymbolList[i]);
				if (result.isSubtypeRel) {
					retList +=  <result.iKey, SUBTYPE_VIA_PARAMETER, methOrConstExpr@src>;
				}
			}
		}
	}
	return retList;
}







public rel [inheritanceKey, inheritanceType] getSubtypeCases(M3 projectM3) {
	rel [inheritanceKey, inheritanceType] 			resultRel 	= {};
	lrel [inheritanceKey, inheritanceSubtype , loc ] 			subtypeLog 	= [];
	lrel [inheritanceKey, inheritanceSubtype , loc ] 			allSubtypeCases = [];
	set [loc] 				allClassesAndInterfacesInProject 	= getAllClassesAndInterfacesInProject(projectM3);
	set [loc] 				allClassesInProject 				= getAllClassesInProject(projectM3);
	map [loc, set [loc]] 	declarationsMap 					= toMap({<aLoc, aProject> | <aLoc, aProject> <- projectM3@declarations});
	map [loc, set [loc]] 	methodsOfClasses   					= toMap({<owner, declared> | <owner,declared> <- projectM3@containment, isClass(owner), isMethod(declared)});
	map [loc, set[TypeSymbol]] typesMap 						= toMap({<from, to> | <from, to> <- projectM3@types});
	map [loc, set[loc]] 	invertedUnitContainment 			= getInvertedUnitContainment(projectM3);
	map [loc, set[loc]] 	invertedClassAndInterfaceContainment = getInvertedClassAndInterfaceContainment(projectM3);
	map [loc, set[loc]] 	invertedClassInterfaceMethodContainment = getInvertedClassInterfaceMethodContainment (projectM3);
	rel [loc, loc] 			projectInhRels 						 = getInheritanceRelations(projectM3);
	map [loc, set [loc]] 	inheritanceRelsMap 					= toMap(projectInhRels);
	map [loc, set [loc]] 	invertedInheritanceRelsMap 			= toMap(invert(projectInhRels));
	map [loc, set [loc]]	extendsMap 							= toMap({<_child, _parent> | <_child, _parent> <- projectM3@extends});
	map [loc, set [loc]]    implementsMap  						= toMap({<_child, _parent> | <_child, _parent> <- projectM3@implements});
	map [loc, set [str]] 	invertedNamesMap					= getInvertedNamesMap(projectM3@names);
	rel [loc, loc] 			allInheritanceRelations 			= getInheritanceRelations(projectM3);		
	for (oneClass <- allClassesInProject ) {
		list [Declaration] ASTsOfOneClass = getASTsOfAClass(oneClass, invertedClassInterfaceMethodContainment , invertedUnitContainment, declarationsMap, projectM3);
		for (oneAST <- ASTsOfOneClass) {
			visit(oneAST) {
				case aStmt:\assignment(lhs, operator, rhs) : {  
					allSubtypeCases += getSubtypeViaAssignment(aStmt, projectM3);
				}
				case _variables:\variables(typeOfVar, fragments) : {
					allSubtypeCases += getSubtypeViaVariables(typeOfVar, fragments, projectM3);
				} 
				case _fields:\field(typeOfField, fragments) : {
					allSubtypeCases += getSubtypeViaVariables(typeOfField, fragments, projectM3);
				}
				case castStmt:\cast(castType, castExpr) : {  
					allSubtypeCases += getSubtypeViaCast(castStmt, inheritanceRelsMap, invertedInheritanceRelsMap, projectM3);					
				} // case \cast
				case enhForStmt:\foreach(Declaration parameter, Expression collection, Statement body) : {
					allSubtypeCases += getSubtypeResultViaForLoop(parameter@typ, collection, enhForStmt@src, projectM3);
				}
				case  methExpr1:\methodCall(_,_, _) : {
					allSubtypeCases += 	getSubtypeViaParameterPassing(methExpr1, declarationsMap, typesMap, invertedClassAndInterfaceContainment, invertedNamesMap, allInheritanceRelations, projectM3);
				}
				case methExpr2:\methodCall(_, _, _, _): {
					allSubtypeCases += 	getSubtypeViaParameterPassing(methExpr2, declarationsMap, typesMap, invertedClassAndInterfaceContainment, invertedNamesMap, allInheritanceRelations, projectM3);					
				} 
				case newObject1:\newObject(Type \type, list[Expression] expArgs) : {
					allSubtypeCases += 	getSubtypeViaParameterPassing(newObject1, declarationsMap, typesMap, invertedClassAndInterfaceContainment, invertedNamesMap, allInheritanceRelations, projectM3);
				}
				case newObject2:\newObject(Type \type, list[Expression] expArgs, Declaration class) : {
					allSubtypeCases += 	getSubtypeViaParameterPassing(newObject2, declarationsMap, typesMap, invertedClassAndInterfaceContainment, invertedNamesMap, allInheritanceRelations, projectM3);					
				}
				case newObject3:\newObject(Expression expr, Type \type, list[Expression] expArgs) : {
					allSubtypeCases += 	getSubtypeViaParameterPassing(newObject3, declarationsMap, typesMap, invertedClassAndInterfaceContainment, invertedNamesMap, allInheritanceRelations, projectM3);
				}
				case newObject4:\newObject(Expression expr, Type \type, list[Expression] expArgs, Declaration class) : {
					allSubtypeCases += 	getSubtypeViaParameterPassing(newObject4, declarationsMap, typesMap, invertedClassAndInterfaceContainment, invertedNamesMap, allInheritanceRelations, projectM3);
				}
				case consCall1:\constructorCall(bool isSuper, list[Expression] arguments) : {
					Expression consCallExpr1 = createMethodCallFromConsCall(consCall1);
					allSubtypeCases += 	getSubtypeViaParameterPassing(consCallExpr1, declarationsMap, typesMap, invertedClassAndInterfaceContainment, invertedNamesMap, allInheritanceRelations, projectM3);					
				}
				case consCall2:\constructorCall(bool isSuper, Expression expr, list[Expression] arguments) : {
					// TODO: When does this ever happen? I need a Java example for this...
					Expression consCallExpr2 = createMethodCallFromConsCall(consCall2);
					allSubtypeCases += 	getSubtypeViaParameterPassing(consCallExpr2, declarationsMap, typesMap, invertedClassAndInterfaceContainment, invertedNamesMap, allInheritanceRelations, projectM3);					
				}
				
        	} // visit()
		}
	
		set [loc] methodsInClass = oneClass in methodsOfClasses ? methodsOfClasses[oneClass] : {}; 
		for (oneMethod <- methodsInClass) {
			methodAST = getMethodASTEclipse(oneMethod, model = projectM3);	
			visit(methodAST) {
				case returnStmt:\return(retExpr) : {
					allSubtypeCases += getSubtypeViaReturnStmt(returnStmt, oneMethod, typesMap, projectM3 );
				}  // case \return(_)
        	} // visit()
		}	// for each method in the class															
	}	// for each class in the project
	for ( int i <- [0..size(allSubtypeCases)]) { 
		tuple [ inheritanceKey iKey, inheritanceSubtype iType, loc detLoc] aCase = allSubtypeCases[i];
		resultRel += <<aCase.iKey.child, aCase.iKey.parent>, SUBTYPE> ;
		subtypeLog += aCase;
	} 
	iprintToFile(getFilename(projectM3.id,subtypeLogFile),subtypeLog );
	return resultRel;
}




