module inheritance::InternalReuse

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


lrel [inheritanceKey, internalReuseDetail, loc] getOneInternalReuse(loc accessedLoc, loc accessingClass, 	TypeSymbol receiverTypeSymbol, loc srcRef, 
																											map [loc, set [loc]] invClassAndInterfaceContainment, 
																											map [loc, set [loc]] declarationsMap,
																											M3 projectM3) {
	lrel [inheritanceKey, internalReuseDetail, loc] resultRel = [];
	loc receivingClassOrInt = getClassOrInterfaceFromTypeSymbol(receiverTypeSymbol);
	if ((receivingClassOrInt == accessingClass) && (isLocDefinedInProject(accessedLoc, declarationsMap )) ) {  // internal
		loc definingTypeOfLoc = getDefiningClassOrInterfaceOfALoc(accessedLoc, invClassAndInterfaceContainment, projectM3);
		if (definingTypeOfLoc != accessingClass) { // reuse, accessed loc is defined somewhere else than accessing class
			resultRel += <<accessingClass, definingTypeOfLoc>, <accessedLoc, accessingClass>, srcRef>;
		}
	} 
	return resultRel;
}

public void main() {
	M3 projectM3 = getM3ForProjectLoc(|project://antlr-3.4|);
	getInternalReuseCases(projectM3); 
}


public rel [inheritanceKey, inheritanceType] getInternalReuseCases(M3 projectM3) {
	rel [inheritanceKey, inheritanceType] resultRel = {};
	lrel [inheritanceKey, internalReuseDetail, loc] internalReuseLog = []; 
	set	[loc] 				allClassesInProject 		= {decl | <decl, prjct> <- projectM3@declarations, isClass(decl) };
	map [loc, set [loc]] 	invClassAndInterfaceContainment 	= getInvertedClassAndInterfaceContainment(projectM3);
	map [loc, set [loc]] 	invClassInterfaceMethodContainment  = getInvertedClassInterfaceMethodContainment(projectM3); 
	map [loc, set [loc]] 	declarationsMap				= toMap({<aLoc, aProject> | <aLoc, aProject> <- projectM3@declarations});
	map [loc, set[loc]] 	invertedUnitContainment 	= getInvertedUnitContainment(projectM3);
	for (oneClass <- allClassesInProject) {
		//println("Internal reuse cases for class: <oneClass> are going to be collected...");
		list [Declaration] ASTsOfOneClass = getASTsOfAClass(oneClass, invClassInterfaceMethodContainment, invertedUnitContainment, declarationsMap, projectM3);
		for (oneAST <- ASTsOfOneClass) {
			visit(oneAST) {
        		case qName:\qualifiedName(qualifier, expression): {
        			loc accessedField = expression@decl;
        			if (isField(accessedField)) {
        				TypeSymbol receiverTypeSymbol = qualifier@typ; 
        				internalReuseLog += getOneInternalReuse(accessedField, oneClass, receiverTypeSymbol, qName@src, invClassAndInterfaceContainment,  declarationsMap,  projectM3); 
					}
        		}
        		case sName:\simpleName(str name) : {
        			if (isField(sName@decl)) {
        				loc accessedField = sName@decl;
						TypeSymbol receiverTypeSymbol = class(oneClass, []);
        				internalReuseLog += getOneInternalReuse(accessedField, oneClass, receiverTypeSymbol, sName@src, invClassAndInterfaceContainment,  declarationsMap, projectM3); 
        			}	
        		}
        		case fAccessStmt1:\fieldAccess(isSuper, fAccessExpr:_, str name:_) : {
        			loc accessedField = fAccessStmt1@decl;
					TypeSymbol receiverTypeSymbol = fAccessExpr@typ;
        			internalReuseLog += getOneInternalReuse(accessedField, oneClass, receiverTypeSymbol, fAccessStmt1@src, invClassAndInterfaceContainment,  declarationsMap, projectM3); 
        		}
        		case fAccessStmt2:\fieldAccess(isSuper, str name:_) : {
        			loc accessedField = fAccessStmt2@decl;
					TypeSymbol receiverTypeSymbol = class(oneClass, []);
        			internalReuseLog += getOneInternalReuse(accessedField, oneClass, receiverTypeSymbol, fAccessStmt2@src, invClassAndInterfaceContainment,  declarationsMap, projectM3); 
        		}        		
        		case m1:\methodCall(_,_,_) : {
					loc accessedMethod = m1@decl;
					TypeSymbol receiverTypeSymbol = class(oneClass, []);
        			internalReuseLog += getOneInternalReuse(accessedMethod ,oneClass, receiverTypeSymbol, m1@src, invClassAndInterfaceContainment,  declarationsMap, projectM3 ); 
        		}
				case m2:\methodCall(_, receiver:_, _, _): {
					loc accessedMethod = m2@decl;
					TypeSymbol receiverTypeSymbol = receiver@typ;
        			internalReuseLog += getOneInternalReuse(accessedMethod, oneClass, receiverTypeSymbol, m2@src, invClassAndInterfaceContainment,  declarationsMap, projectM3); 
        		} // case methodCall()
        	} // visit()
		}	// for each method in the class															
	}	// for each class in the project
	
	iprintToFile(getFilename(projectM3.id, internalReuseLogFile), internalReuseLog);
	resultRel = {<iKey, INTERNAL_REUSE> | <iKey, <_,_>, _> <- internalReuseLog};
	println("Number of internal reuse cases: <size(resultRel)>");
	return resultRel;
}

