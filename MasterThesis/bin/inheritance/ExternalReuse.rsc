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
																						map [loc, set[loc]] invertedClassContainment,  map[loc, set[loc]] declarationsMap,
																						rel [loc, loc] allInheritanceRelations) {
	lrel [inheritanceKey, inheritanceSubtype, loc, loc] retList = [];
	visit (mCall) {
		case m2:\methodCall(_, receiver:_, _, _): {
			loc invokedMethod = m2@decl;        			
			loc classOfReceiver = getClassFromTypeSymbol(receiver@typ);
			// I am only interested in the classes and not interfaces, enums, etc.
			// I am not interested in this() and also variables of classOfMethodCall
			if ((invokedMethod in invertedClassContainment) && (classOfReceiver != classOfMethodCall) 
									&& isLocDefinedInProject(invokedMethod, declarationsMap) 
								 	&& ! inheritanceRelationExists(classOfMethodCall, classOfReceiver, allInheritanceRelations)) {
				// for external reuse, the invokedMethod should not be declared in the 
				// class classOfReceiver
				loc methodDefiningClass = getDefiningClassOfALoc(invokedMethod, invertedClassContainment);
				if ( isClass(classOfReceiver) && (methodDefiningClass != classOfReceiver)) {
						retList += <<classOfReceiver, methodDefiningClass>, EXTERNAL_REUSE_VIA_METHOD_CALL, m2@src, invokedMethod>; 
				}
			} // if inheritanceRelationExists
   		} // case methodCall()
   	}
	return retList;
}


public lrel [inheritanceKey, inheritanceSubtype, loc, loc] getExternalReuseViaFieldAccess(Expression qName, map [loc, set[loc]] invClassAndInterfaceContainment,
																											map[loc, set[loc]] declarationsMap) {
	lrel [inheritanceKey, inheritanceSubtype, loc, loc] retList = [];
	visit (qName) {
		case \qualifiedName(qualifier, expression) : {
			loc accessedField = expression@decl;
			if (isField(accessedField) && isLocDefinedInProject(accessedField, declarationsMap)) {  
				loc classOfQualifier = getClassOrInterfaceFromTypeSymbol(qualifier@typ);
				loc classOfExpression = getDefiningClassOrInterfaceOfALoc(accessedField, invClassAndInterfaceContainment);
				if (classOfQualifier != classOfExpression) {
					retList += <<classOfQualifier, classOfExpression>, EXTERNAL_REUSE_VIA_FIELD_ACCESS, expression@src, accessedField>;
				}
			}
		} 
	}
	return retList;
}


public rel [inheritanceKey, inheritanceType] getExternalReuseCases(M3 projectM3) {
	// Decision: The external reuse cases are only about classes, see assumptions and decisions document.
	rel [inheritanceKey, inheritanceType] resultRel = {};
	lrel [inheritanceKey, inheritanceSubtype, loc, loc] allExternalReuseCases = [];
	set	[loc] 				allClassesInProject 		= {decl | <decl, prjct> <- projectM3@declarations, isClass(decl) };
	map [loc, set [loc]] 	containmentMapForMethods 	= toMap({<owner, declared> | <owner,declared> <- projectM3@containment, isClass(owner), isMethod(declared)});
	map [loc, set [loc]] 	invertedClassContainment 	= toMap(invert({<owner, declared> | <owner,declared> <- projectM3@containment, isClass(owner)}));
	map [loc, set [loc]] 	invClassAndInterfaceContainment 	= getInvertedClassAndInterfaceContainment(projectM3);
	map [loc, set [loc]] 	declarationsMap				= toMap({<aLoc, aProject> | <aLoc, aProject> <- projectM3@declarations});
	rel [loc, loc] 			allInheritanceRelations 	= getInheritanceRelations(projectM3);
	map [loc, set[loc]] 	invertedUnitContainment 	= getInvertedUnitContainment(projectM3);
	//println("Containment locs for java class GenSample1 is: <invertedClassContainment[|java+class:///edu/uva/analysis/gensamples/GenSample1|]>");
	for (oneClass <- allClassesInProject) {
		list [Declaration] ASTsOfOneClass = getASTsOfAClass(oneClass, invClassAndInterfaceContainment, invertedUnitContainment, declarationsMap);
		// TODO:take also initializers in to account  
		// || getMethodASTEclipse does not work for initializers. declared.scheme == "java+initializer" 
		for (oneAST <- ASTsOfOneClass) {
			visit(oneAST) {
				case m2:\methodCall(_, receiver:_, _, _): {
					allExternalReuseCases += getExternalReuseViaMethodCall(m2, oneClass, invertedClassContainment, declarationsMap, allInheritanceRelations);
        		} // case methodCall()
        		case qName:\qualifiedName(_, _) : {
        			allExternalReuseCases += getExternalReuseViaFieldAccess(qName, invClassAndInterfaceContainment, declarationsMap);
        		}
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

