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
		case myVar: \variable(_,_,stmt) : {
			returnSymbol = stmt@typ;
			expressionHasStatement = true;
		}
	} 
	tuple [bool, TypeSymbol] returnTuple;
	returnTuple = <expressionHasStatement, returnSymbol>;
	return returnTuple;
}





private rel [inheritanceKey, loc] getVariableListWithSubtype(Type typeOfVar, list [Expression] fragments) {
 	rel [inheritanceKey, loc] returnList = {};
 	TypeSymbol lhsTypeSymbol = DEFAULT_TYPE_SYMBOL ;
 	//println("Variable is : <fragments[0]@decl> ------------");
 	visit (typeOfVar) {
 		// TODO: I look only in simpleType and ArrayType. How about more complex types like parametrizdeType() ?
 		case sType: \simpleType(typeExpr) : {
 			lhsTypeSymbol =  getTypeSymbolFromSimpleType(sType);
 		}
 		case aType :\arrayType(simpleTypeOfArray) : {
 			lhsTypeSymbol = getTypeSymbolFromSimpleType(simpleTypeOfArray);
 		}
 	}
 	// I'm only interested in the simpleType and arrayType
 	if (lhsTypeSymbol != DEFAULT_TYPE_SYMBOL) {
 		loc lhsJavaType = getClassOrInterfaceFromTypeSymbol(lhsTypeSymbol);
 		tuple [bool hasStatement, TypeSymbol rhsTypeSymbol] typeSymbolTuple = getTypeSymbolFromVariable(fragments[0]);
 		if (typeSymbolTuple.hasStatement) {
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




private rel [inheritanceKey, inheritanceType] getSubtypeViaCastingFromAST(M3 projectM3) {
	rel [inheritanceKey, inheritanceType] resultRel = {};
	lrel [inheritanceKey, subtypeViaAssignmentDetail] subtypeLog = []; 
	set [loc] allClassesAndInterfacesInProject = getAllClassesAndInterfacesInProject(projectM3);
	set [loc] allClassesInProject = getAllClassesAndInterfacesInProject(projectM3);
	for (oneClass <- allClassesInProject) {
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
        	} // visit()
		};	// for each method in the class															
	};	// for each class in the project
	iprintToFile(subtypeAssignmentLogFile, subtypeLog);
	return resultRel;
}




private rel [inheritanceKey, inheritanceType] getSubtypeViaAssignmentFromAST(M3 projectM3) {
	rel [inheritanceKey, inheritanceType] resultRel = {};
	lrel [inheritanceKey, subtypeViaAssignmentDetail] subtypeLog = []; 
	set [loc] allClassesAndInterfacesInProject = getAllClassesAndInterfacesInProject(projectM3);
	set [loc] allClassesInProject = getAllClassesAndInterfacesInProject(projectM3);
	for (oneClass <- allClassesInProject) {
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
        	} // visit()
		};	// for each method in the class															
	};	// for each class in the project
	iprintToFile(subtypeAssignmentLogFile, subtypeLog);
	return resultRel;
}




public rel [inheritanceKey, inheritanceType] getSubtypeCases(M3 projectM3) {
	rel [inheritanceKey, inheritanceType] resultRel = {};
	resultRel += getSubtypeViaAssignmentFromAST(projectM3);
	resultRel += getSubtypeViaCastingFromAST(projectM3);	
	return resultRel;
}

