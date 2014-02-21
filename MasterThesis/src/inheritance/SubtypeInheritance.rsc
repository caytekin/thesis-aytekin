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

//public alias boolTypeSymbolTuple


public TypeSymbol getTypeSymbolFromSimpleType(Type aType) {
	TypeSymbol returnSymbol = DEFAULT_TYPE_SYMBOL; 
	visit (aType) {
		case sType: \simpleType(typeExpr) : {
			returnSymbol =  typeExpr@typ;
		}
 	}
 	return returnSymbol;
}




public tuple [bool, TypeSymbol] getTypeSymbolFromVariable(Expression varExpression) {
	bool expressionHasStatement = false;
	TypeSymbol returnSymbol = DEFAULT_TYPE_SYMBOL;
	//println("getTypeSymbolForVariable is called with <varExpression>");
	visit (varExpression) {
		case nullVar : \variable(_,_, null()) : { 
			// a null initialization should not be counted as subtype
		; }
		case myVar: \variable(_,_,stmt) : {
			returnSymbol = stmt@typ;
			expressionHasStatement = true;
		}
	} 
	tuple [bool, TypeSymbol] returnTuple;
	returnTuple = <expressionHasStatement, returnSymbol>;
	return returnTuple;
}


TypeSymbol getTypeSymbolFromRascalType(Type rascalType) {
	TypeSymbol retTypeSymbol = DEFAULT_TYPE_SYMBOL;
 	visit (rascalType) {
 		 // I'm only interested in the simpleType and arrayType at the moment
 		// TODO: I look only in simpleType and ArrayType. How about more complex types like parametrizdeType() ?
 		case sType: \simpleType(typeExpr) : {
 			retTypeSymbol =  getTypeSymbolFromSimpleType(sType);
 		}
 		case aType :\arrayType(simpleTypeOfArray) : {
 			retTypeSymbol = getTypeSymbolFromSimpleType(simpleTypeOfArray);
 		}
 	}
 	return retTypeSymbol;	
}






private rel [inheritanceKey, loc] getVariableListWithSubtype(Type typeOfVar, list [Expression] fragments) {
 	rel [inheritanceKey, loc] returnList = {};
 	TypeSymbol lhsTypeSymbol = getTypeSymbolFromRascalType(typeOfVar);
 	//println("Variables are : <{vars@decl| vars <- fragments}> ------------");
 	if (lhsTypeSymbol != DEFAULT_TYPE_SYMBOL) {
 		//println("lhsTypeSymbol is: <lhsTypeSymbol>");
 		loc lhsJavaType = getClassOrInterfaceFromTypeSymbol(lhsTypeSymbol);
 		tuple [bool hasStatement, TypeSymbol rhsTypeSymbol] typeSymbolTuple = getTypeSymbolFromVariable(fragments[size(fragments) - 1]);
 		//println("hasStatement is: <typeSymbolTuple.hasStatement>, rhsTypeSymbol is: <typeSymbolTuple.rhsTypeSymbol>");
 		if ((typeSymbolTuple.hasStatement) && (typeSymbolTuple.rhsTypeSymbol != DEFAULT_TYPE_SYMBOL)) {
 			loc rhsJavaType = getClassOrInterfaceFromTypeSymbol(typeSymbolTuple.rhsTypeSymbol);
 			if (lhsJavaType != rhsJavaType)  {
 				for (anExpression <- fragments) {
 					returnList += <<rhsJavaType, lhsJavaType>, anExpression@decl>;
 				}
 			}
 		}
 	}
 	return returnList;
}






private rel [inheritanceKey, inheritanceType] getSubtypeCasesFromAST(M3 projectM3) {
	rel [inheritanceKey, inheritanceType] resultRel = {};
	lrel [inheritanceKey, subtypeViaAssignmentDetail] subtypeLog = []; 
	set [loc] allClassesAndInterfacesInProject = getAllClassesAndInterfacesInProject(projectM3);
	set [loc] allClassesInProject = getAllClassesAndInterfacesInProject(projectM3);
	for (oneClass <- allClassesInProject ) {
		set [loc] methodsInClass = {declared | <owner,declared> <- projectM3@containment, 
																owner == oneClass, 
																isMethod(declared) }; 
		// TODO:take also initializers in to account  
		// || getMethodASTEclipse does not work for initializers. declared.scheme == "java+initializer" 
		for (oneMethod <- methodsInClass) {
			methodAST = getMethodASTEclipse(oneMethod, model = projectM3);	
			visit(methodAST) {
				case aStmt:\assignment(lhs, operator, rhs) : {  
		        	// 	\assignment(Expression lhs, str operator, Expression rhs)
		        	loc lhsClass = getClassOrInterfaceFromTypeSymbol(lhs@typ);
		        	loc rhsClass = getClassOrInterfaceFromTypeSymbol(rhs@typ);
					if (lhsClass != rhsClass) {
						if ( (lhsClass in allClassesAndInterfacesInProject) && (rhsClass in allClassesAndInterfacesInProject)) {
							inheritanceKey iKey = <rhsClass, lhsClass>;
							resultRel  += < iKey, SUBTYPE>;
							subtypeLog += <iKey, <aStmt@src, SUBTYPE_ASSIGNMENT_STMT>>;
						}
					}		
				} // case \assignment
				case variables : \variables(typeOfVar, fragments) : {
					rel [inheritanceKey, loc] variablesList = getVariableListWithSubtype(typeOfVar, fragments);
					for (<inheritanceKey iKey, loc varLoc> <- variablesList) {
						if ( (iKey.parent in allClassesAndInterfacesInProject) && (iKey.parent in allClassesAndInterfacesInProject) ) {
							resultRel += <iKey, SUBTYPE>;
							subtypeLog += <iKey, <varLoc, SUBTYPE_ASSIGNMENT_VAR_DECL>>;
						}
					}
				;
				} // case \variables
				case castStmt:\cast(castType, castExpr) : {  
					// The cast can be from child to parent, but also from parent to child
					// Also, sideways cast is possible. This will give some irregularities 
					// in the statistics, because we assume a <child, parent> tuple in CC, CI or II. 
					TypeSymbol lhsTypeSymbol = getTypeSymbolFromRascalType(castType);
					TypeSymbol rhsTypeSymbol = castExpr@typ;
					if ((lhsTypeSymbol != DEFAULT_TYPE_SYMBOL) && (lhsTypeSymbol != rhsTypeSymbol)) { 
						inheritanceKey iKey = <getClassOrInterfaceFromTypeSymbol(rhsTypeSymbol), 
												getClassOrInterfaceFromTypeSymbol(lhsTypeSymbol)>;
						if ( (iKey.child in allClassesAndInterfacesInProject) && (iKey.parent in allClassesAndInterfacesInProject) ) {
							resultRel += <iKey, SUBTYPE>;
							subtypeLog += <iKey, <castStmt@src, SUBTYPE_VIA_CAST>>;
						}
					} // if
				} // case \cast
        	} // visit()
		};	// for each method in the class															
	};	// for each class in the project
	iprintToFile(subtypeASTLogFile, subtypeLog);
	return resultRel;
}




public rel [inheritanceKey, inheritanceType] getSubtypeCases(M3 projectM3) {
	rel [inheritanceKey, inheritanceType] resultRel = {};
	resultRel += getSubtypeCasesFromAST(projectM3);
	return resultRel;
}

