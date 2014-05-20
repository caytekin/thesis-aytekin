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


public lrel [inheritanceKey, inheritanceSubtype, loc, loc] getExternalReuseViaMethodCall(Expression mCall, loc  classOfMethodCall, 
																						map [loc, set[loc]] 	invClassAndInterfaceContainment,  
																						map [loc, set[loc]] 	declarationsMap,
																						rel [loc, loc] 			allInheritanceRelations) {
	lrel [inheritanceKey, inheritanceSubtype, loc, loc] retList = [];
	visit (mCall) {
		case m2:\methodCall(_, receiver:_, _, _): {
			loc invokedMethod = m2@decl;        			
			loc classOrInterfaceOfReceiver = getClassOrInterfaceFromTypeSymbol(receiver@typ);
			if ((invokedMethod in invClassAndInterfaceContainment) && (classOrInterfaceOfReceiver != classOfMethodCall) 
									&& isLocDefinedInProject(invokedMethod, declarationsMap) 
								 	&& ! inheritanceRelationExists(classOfMethodCall, classOrInterfaceOfReceiver, allInheritanceRelations)) {
				// for external reuse, the invokedMethod should not be declared in the class classOrInterfaceOfReceiver
				loc methodDefiningClassOrInterface = getDefiningClassOrInterfaceOfALoc(invokedMethod, invClassAndInterfaceContainment);
				if  (methodDefiningClassOrInterface != classOrInterfaceOfReceiver) {
						retList += <<classOrInterfaceOfReceiver, methodDefiningClassOrInterface>, EXTERNAL_REUSE_VIA_METHOD_CALL, m2@src, invokedMethod>; 
				}
			} // if inheritanceRelationExists
   		} // case methodCall()
   	}
	return retList;
}


public lrel [inheritanceKey, inheritanceSubtype, loc, loc] getExternalReuseViaFieldAccess(Expression qName, map [loc, set[loc]] invClassAndInterfaceContainment,
																											map[loc, set[loc]] declarationsMap) {
	lrel [inheritanceKey, inheritanceSubtype, loc, loc] retList = [];
	loc accessedField = DEFAULT_LOC;
	TypeSymbol receiverTypeSymbol = DEFAULT_TYPE_SYMBOL;
	loc srcRef = DEFAULT_LOC;
	visit (qName) {
		case \qualifiedName(qualifier, expression) : {
			accessedField = expression@decl;
			if (isField(accessedField) ) { receiverTypeSymbol = qualifier@typ; }
			srcRef = expression@src;
		} 
		case fAccessStmt:\fieldAccess(isSuper, fAccessExpr:_, str name:_) : {
			accessedField = fAccessStmt@decl;
			receiverTypeSymbol = fAccessExpr@typ;
			srcRef = fAccessStmt@src;			
		}
	}
	if (isField(accessedField) && isLocDefinedInProject(accessedField, declarationsMap) && isLocDefinedInClassOrInterface(accessedField, invClassAndInterfaceContainment)) {  
		loc classOfQualifier 	= getClassOrInterfaceFromTypeSymbol(receiverTypeSymbol);
		loc classOfExpression 	= getDefiningClassOrInterfaceOfALoc(accessedField, invClassAndInterfaceContainment);
		if (classOfQualifier != classOfExpression) {
			retList += <<classOfQualifier, classOfExpression>, EXTERNAL_REUSE_VIA_FIELD_ACCESS, srcRef, accessedField>;
			//println("Field access : <classOfQualifier> , <classOfExpression>, at: <srcRef>, field: <accessedField> ");
		}
	}

	return retList;
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
	rel [loc, loc] 			allInheritanceRelations 	= getInheritanceRelations(projectM3);
	map [loc, set[loc]] 	invertedUnitContainment 	= getInvertedUnitContainment(projectM3);
	for (oneClass <- allClassesInProject) {
		list [Declaration] ASTsOfOneClass = getASTsOfAClass(oneClass, invClassInterfaceMethodContainment, invertedUnitContainment, declarationsMap);
		for (oneAST <- ASTsOfOneClass) {
			visit(oneAST) {
        		case qName:\qualifiedName(_, _) : {
        			allExternalReuseCases += getExternalReuseViaFieldAccess(qName, invClassAndInterfaceContainment, declarationsMap);
        		}
        		case fAccess:\fieldAccess(_,_,_) : {
        			allExternalReuseCases += getExternalReuseViaFieldAccess(fAccess, invClassAndInterfaceContainment, declarationsMap);
        		}
				case m2:\methodCall(_, receiver:_, _, _): {
					allExternalReuseCases += getExternalReuseViaMethodCall(m2, oneClass, invClassAndInterfaceContainment, declarationsMap, allInheritanceRelations);
        		} // case methodCall()
        	} // visit()
		}	// for each method in the class															
	}	// for each class in the project
	for ( int i <- [0..size(allExternalReuseCases)]) { 
		tuple [ inheritanceKey iKey, inheritanceSubtype iType, loc srcLoc, loc accessedLoc] aCase = allExternalReuseCases[i];
		resultRel += <aCase.iKey, EXTERNAL_REUSE>;
	}
	iprintToFile(externalReuseLogFile, allExternalReuseCases);
	return resultRel;
}

