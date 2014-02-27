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


public lrel [inheritanceKey, inheritanceSubtype, loc, loc] getExternalReuseViaMethodCall(Expression mCall, loc  classOfMethodCall,  M3 projectM3) {
	lrel [inheritanceKey, inheritanceSubtype, loc, loc] retList = [];
	visit (mCall) {
		case m2:\methodCall(_, receiver:_, _, _): {
			loc invokedMethod = m2@decl;        			
			loc classOfReceiver = getClassFromTypeSymbol(receiver@typ);
			// I am only interested in the classes and not interfaces, enums, etc.
			// I am not interested in this() and also variables of classOfMethodCall
			if ((classOfReceiver != classOfMethodCall) && isLocDefinedInProject(invokedMethod, projectM3) 
								 && ! inheritanceRelationExists(classOfMethodCall, classOfReceiver, projectM3)) {
				// for external reuse, the invokedMethod should not be declared in the 
				// class classOfReceiver
				loc methodDefiningClass = getDefiningClassOfALoc(invokedMethod, projectM3);
				if ( isClass(classOfReceiver) && isClass(methodDefiningClass) && (methodDefiningClass != classOfReceiver)) {
					retList += <<classOfReceiver, methodDefiningClass>, EXTERNAL_REUSE_VIA_METHOD_CALL, m2@src, invokedMethod>; 
				}
			} // if inheritanceRelationExists
   		} // case methodCall()
   	}
	return retList;
}



public lrel [inheritanceKey, inheritanceSubtype, loc, loc] getExternalReuseViaFieldAccess(Expression qName, M3 projectM3) {
	lrel [inheritanceKey, inheritanceSubtype, loc, loc] retList = [];
	visit (qName) {
		case \qualifiedName(qualifier, expression) : {
			loc accessedField = expression@decl;
			if (isField(accessedField) && isLocDefinedInProject(accessedField, projectM3)) {  
				loc classOfQualifier = getClassOrInterfaceFromTypeSymbol(qualifier@typ);
				loc classOfExpression = getDefiningClassOfALoc(accessedField, projectM3);
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
	set		[loc] allClassesInProject = {decl | <decl, prjct> <- projectM3@declarations, isClass(decl) };
	for (oneClass <- allClassesInProject) {
		set [loc] methodsInClass = {declared | <owner,declared> <- projectM3@containment, 
																owner == oneClass, 
																isMethod(declared) }; 
		// TODO:take also initializers in to account  
		// || getMethodASTEclipse does not work for initializers. declared.scheme == "java+initializer" 
		for (oneMethod <- methodsInClass) {
			methodAST = getMethodASTEclipse(oneMethod, model = projectM3);	
			visit(methodAST) {
				case m2:\methodCall(_, receiver:_, _, _): {
					allExternalReuseCases += getExternalReuseViaMethodCall(m2, oneClass, projectM3);
        		} // case methodCall()
        		case qName:\qualifiedName(_, _) : {
        			allExternalReuseCases += getExternalReuseViaFieldAccess(qName, projectM3);
        		;
        		}
        	} // visit()
		};	// for each method in the class															
	};	// for each class in the project
	for ( int i <- [0..size(allExternalReuseCases)]) { 
		tuple [ inheritanceKey iKey, inheritanceSubtype iType, loc srcLoc, loc accessedLoc] aCase = allExternalReuseCases[i];
		resultRel += <aCase.iKey, EXTERNAL_REUSE>;
	}
	iprintToFile(externalReuseLogFile, allExternalReuseCases);
	return resultRel;
}

