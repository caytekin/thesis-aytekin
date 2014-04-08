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






public list [TypeSymbol] getPassedSymbolList(Expression methExpr) {
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
	}
	for ( int i <- [0..(size(args))]) retList += args[i]@typ;
	return retList;
}


private lrel [inheritanceKey, inheritanceSubtype, loc]  getSubtypeResultViaAssignment(Expression lhs, Expression rhs, loc sourceRef) {
	lrel [inheritanceKey, inheritanceSubtype, loc] retList = [];
	tuple [bool isSubtypeRel, inheritanceKey iKey] result = getSubtypeRelation(rhs@typ, lhs@typ);
	if (result.isSubtypeRel) {
		retList += <result.iKey, SUBTYPE_ASSIGNMENT_STMT, sourceRef>;
	} // if
	return retList;
}



public lrel [inheritanceKey, inheritanceSubtype, loc] getSubtypeViaAssignment(Expression asmtStmt) {
	lrel [inheritanceKey, inheritanceSubtype, loc] retList = [];
	bool isConditional = false;
	visit (asmtStmt) {
		case aStmt:\assignment(lhs, operator, rhs) : {  
			visit (aStmt) {
				case conditionalS:\conditional(logicalExpr, thenBranch, elseBranch) : {
					isConditional = true;
					retList += getSubtypeResultViaAssignment(lhs, thenBranch, conditionalS@src);
					retList += getSubtypeResultViaAssignment(lhs, elseBranch, conditionalS@src);				
				} 
			}
			if (!isConditional) {
				retList += getSubtypeResultViaAssignment(lhs, rhs, aStmt@src);
			}																					   
		}	// case	
	} // visit
	return retList;
}


private lrel [inheritanceKey, inheritanceSubtype, loc] getSubtypeResultViaVariable(TypeSymbol lhsTypeSymbol, Expression rhs, list [Expression] fragments) {
	lrel [inheritanceKey, inheritanceSubtype, loc] retList = [];
	tuple [bool isSubtypeRel, inheritanceKey iKey] result = getSubtypeRelation(rhs@typ, lhsTypeSymbol); 
	if (result.isSubtypeRel) {
		for (anExpression <- fragments) {
			retList += <result.iKey, SUBTYPE_ASSIGNMENT_VAR_DECL, anExpression@decl>;
		}
	}
	return retList;
}


public lrel [inheritanceKey, inheritanceSubtype, loc]  getSubtypeViaVariables(Declaration vars) {
	lrel [inheritanceKey, inheritanceSubtype, loc] retList = [];
	bool isConditional = false;
	visit(vars) {
		case \variables(typeOfVar, fragments) : {
  			TypeSymbol lhsTypeSymbol = getTypeSymbolFromRascalType(typeOfVar);
  			//println("Type of var is: <typeOfVar> for variable: <fragments[0]@decl>");
  			visit (fragments[size(fragments) - 1]) {
  				case nullVar : \variable(_,_, null()) : { 
					// a null initialization should not be counted as subtype
				;}
				case myVar: \variable(_,_,stmt) : {
					visit (stmt) {
						case conditionalS:\conditional(logicalExpr, thenBranch, elseBranch) : {
							isConditional = true;
							retList += getSubtypeResultViaVariable(lhsTypeSymbol , thenBranch, fragments);
							retList += getSubtypeResultViaVariable(lhsTypeSymbol , elseBranch, fragments);				
						}
					} 
					if (!isConditional) {
						retList += getSubtypeResultViaVariable(lhsTypeSymbol , stmt, fragments);
					}	
				} // case myVar
  			}  // visit fragments
		} // case
	} // visit
 	return retList;
}


public lrel [inheritanceKey, inheritanceSubtype, loc] getSubtypeViaCast(Expression castStmt) {
// The cast can be from child to parent, but also from parent to child
// Also, sideways cast is possible. This will give some irregularities 
// in the statistics, because we assume a <child, parent> tuple in CC, CI or II. 
	lrel [inheritanceKey, inheritanceSubtype, loc] retList = [];
	visit (castStmt) {
		case \cast(castType, castExpr) : {  
			tuple [bool isSubtypeRel, inheritanceKey iKey] result = getSubtypeRelation(castExpr@typ, getTypeSymbolFromRascalType(castType));
			if (result.isSubtypeRel) {
				retList += <result.iKey, SUBTYPE_VIA_CAST, castStmt@src>;
				// TODO: Is it possible to log sideways cast and casting from child to parent 
				// 		 with different inheritance subtype? Think about it...
			} 
		}
	}
	return retList;
}


public lrel [inheritanceKey, inheritanceSubtype, loc] getSubtypeViaReturnStmt(Statement returnStmt, loc methodLoc,map [loc, set[TypeSymbol]] typesMap ) {
	lrel [inheritanceKey , inheritanceSubtype  , loc] retList = [];
	visit (returnStmt) {
		case \return(retExpr) : {
			tuple [bool isSubtypeRel, inheritanceKey iKey] result = getSubtypeRelation(	retExpr@typ, 
																						getDeclaredReturnTypeSymbolOfMethod(methodLoc, typesMap));
			if (result.isSubtypeRel) {
				retList += <result.iKey, SUBTYPE_VIA_RETURN, retExpr@src>;
			} 
		}  
	}
	return retList;
}


private TypeSymbol getTypeSymbolOfVararg(TypeSymbol varargSymbol) {
	TypeSymbol retSymbol = DEFAULT_TYPE_SYMBOL;
	if (array(TypeSymbol component, int dimension) := varargSymbol ) {
		retSymbol = component;
	}
	else {
		throw ("In getTypesymbolOfVararg, the vararg is not of type array : <varargSymbol>");
	}
	return retSymbol;
}


private bool isVararg(TypeSymbol passedSymbol, TypeSymbol declaredSymbol) {
	bool retBool = false;
	if ( array(TypeSymbol component, int dimension) := declaredSymbol ) {
		if (component == passedSymbol) {
			retBool = true;
		}
	}
	return retBool;
}



private list [TypeSymbol] updateDeclaredSymbolListForVararg(list [TypeSymbol] passedSymbolList, list [TypeSymbol] declaredSymbolList ) {
	list [TypeSymbol] retList = [];
	if ( size(passedSymbolList) == size(declaredSymbolList) ) {
		retList = declaredSymbolList;
		if ( size(passedSymbolList) > 0 ) {
			if ( last(passedSymbolList) != last(declaredSymbolList) ) {
				if (isVararg(last(passedSymbolList), last(declaredSymbolList))) {
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
				TypeSymbol typeSymbolToAdd = getTypeSymbolOfVararg(declaredSymbolList[size(declaredSymbolList) - 1] );
				for (int i <- [0..numOfElementsToAdd+1]) { retList +=  typeSymbolToAdd ; }
			}
		}
	}
	return retList;
}



public lrel [inheritanceKey, inheritanceSubtype, loc] getSubtypeViaParameterPassing(Expression methOrConstExpr, map [loc, set[loc]] declarationsMap, map [loc, set[TypeSymbol]] typesMap ) {
	lrel [inheritanceKey , inheritanceSubtype , loc ] retList = [];
	// TODO: Because of a bug in Rascal, I can only test this with method calls at the moment
	// When that's fixed I should also test newObject()
	if (isLocDefinedInProject(methOrConstExpr@decl, declarationsMap)) { 
		list [TypeSymbol] passedSymbolList 		= getPassedSymbolList(methOrConstExpr);
		list [TypeSymbol] declaredSymbolList	= getDeclaredParameterTypes(methOrConstExpr, typesMap);
		list [TypeSymbol] updatedDeclaredSymbolList = updateDeclaredSymbolListForVararg(passedSymbolList, declaredSymbolList);
		for (int i <- [0..size(passedSymbolList)]) {
			tuple [bool isSubtypeRel, inheritanceKey iKey] result = getSubtypeRelation(passedSymbolList[i], updatedDeclaredSymbolList[i]);
			if (result.isSubtypeRel) {
				retList += <result.iKey, SUBTYPE_VIA_PARAMETER, methOrConstExpr@src>;
			}
		}
	}
	println();
	return retList;
}


public rel [inheritanceKey, inheritanceType] getSubtypeCases(M3 projectM3) {
	rel [inheritanceKey, inheritanceType] 			resultRel 	= {};
	lrel [inheritanceKey, inheritanceSubtype, loc] 	subtypeLog 	= [];
	lrel [inheritanceKey, inheritanceSubtype, loc] 	allSubtypeCases = [];
	set [loc] 				allClassesAndInterfacesInProject 	= getAllClassesAndInterfacesInProject(projectM3);
	set [loc] 				allClassesInProject 				= getAllClassesInProject(projectM3);
	map [loc, set [loc]] 	declarationsMap 					= toMap({<aLoc, aProject> | <aLoc, aProject> <- projectM3@declarations});
	map [loc, set [loc]] 	methodsOfClasses   					= toMap({<owner, declared> | <owner,declared> <- projectM3@containment, isClass(owner), isMethod(declared)});
	map [loc, set[TypeSymbol]] typesMap 						= toMap({<from, to> | <from, to> <- projectM3@types});
	map [loc, set[loc]] 	invertedUnitContainment 			= getInvertedUnitContainment(projectM3);
	map [loc, set[loc]] 	invertedClassAndInterfaceContainment = getInvertedClassAndInterfaceContainment(projectM3);
	for (oneClass <- allClassesInProject ) {
		// TODO : Do not forget to think about encahnced for loop, there can also be a subtype there.
		list [Declaration] ASTsOfOneClass = getASTsOfAClass(oneClass, invertedClassAndInterfaceContainment, invertedUnitContainment, declarationsMap);
		for (oneAST <- ASTsOfOneClass) {
			visit(oneAST) {
				case aStmt:\assignment(lhs, operator, rhs) : {  
					allSubtypeCases += getSubtypeViaAssignment(aStmt);
				}
				case variables:\variables(typeOfVar, fragments) : {
					allSubtypeCases += getSubtypeViaVariables(variables);
				} 
				case castStmt:\cast(castType, castExpr) : {  
					allSubtypeCases += getSubtypeViaCast(castStmt);					
				} // case \cast
				case  methExpr1:\methodCall(_,_, _) : {
					allSubtypeCases += 	getSubtypeViaParameterPassing(methExpr1, declarationsMap, typesMap);
				}
				case methExpr2:\methodCall(_, _, _, _): {
					allSubtypeCases += 	getSubtypeViaParameterPassing(methExpr2, declarationsMap, typesMap);					
				} 
				case newObject1:\newObject(Type \type, list[Expression] expArgs) : {
					allSubtypeCases += 	getSubtypeViaParameterPassing(newObject1, declarationsMap, typesMap);
				}
				case newObject2:\newObject(Type \type, list[Expression] expArgs, Declaration class) : {
					allSubtypeCases += 	getSubtypeViaParameterPassing(newObject2, declarationsMap, typesMap);					
				}
				case newObject3:\newObject(Expression expr, Type \type, list[Expression] expArgs) : {
					allSubtypeCases += 	getSubtypeViaParameterPassing(newObject3, declarationsMap, typesMap);
				}
				case newObject4:\newObject(Expression expr, Type \type, list[Expression] expArgs, Declaration class) : {
					allSubtypeCases += 	getSubtypeViaParameterPassing(newObject4, declarationsMap, typesMap);
				}
        	} // visit()
		}
	
		set [loc] methodsInClass = oneClass in methodsOfClasses ? methodsOfClasses[oneClass] : {}; 
		for (oneMethod <- methodsInClass) {
			methodAST = getMethodASTEclipse(oneMethod, model = projectM3);	
			visit(methodAST) {
				case returnStmt:\return(retExpr) : {
					allSubtypeCases += getSubtypeViaReturnStmt(returnStmt, oneMethod, typesMap );
				}  // case \return(_)
        	} // visit()
		}	// for each method in the class															
	}	// for each class in the project
	for ( int i <- [0..size(allSubtypeCases)]) { 
		tuple [ inheritanceKey iKey, inheritanceSubtype iType, loc detLoc] aCase = allSubtypeCases[i];
		if (aCase.iKey.parent in allClassesAndInterfacesInProject ) {
			resultRel += <aCase.iKey, SUBTYPE>;
			subtypeLog += aCase;	
		}
	}
	iprintToFile(subtypeLogFile,subtypeLog );
	return resultRel;
}




