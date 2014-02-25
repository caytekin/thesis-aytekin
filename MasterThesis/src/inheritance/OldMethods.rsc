module inheritance::OldMethods

public inheritanceKey getInheritanceKeyFromTwoTypes(list [loc] twoTypes, rel [loc, loc] inhRelations , M3 projectM3) {
	rel [loc, loc] returnSet = { <from, to> | <from, to> <- inhRelations , 
												(from == twoTypes[0] 	&&  to == twoTypes[1]) ||
												(from == twoTypes[1] 	&& 	to == twoTypes[0]) };
	if (size(returnSet) != 1) {
		throw ("Size of list different from 1 for list: <twoTypes> in get inheritance key. Size of list is: <size(returnSet) >");
	}								
	return getOneFrom(returnSet);								
}


private rel [inheritanceKey, inheritanceType] getSubtypeViaAssignmentFromTypeDef(M3 projectM3) {
	rel [inheritanceKey, inheritanceType] resultRel = {<<DEFAULT_LOC, DEFAULT_LOC>, INITIAL_TYPE>};	
	lrel [inheritanceKey, subtypeViaAssignmentTypeDef] subtypeLog = [<<DEFAULT_LOC,DEFAULT_LOC>,<DEFAULT_LOC,INITIAL_TYPE>>]; 
	set [loc] allClassesAndInterfacesInProject = getAllClassesAndInterfacesInProject(projectM3);
	rel [loc, loc] subtypeAssignmentTypeDef = { <from, to> | <from, to> <- projectM3@typeDependency,
																isVariable(from), 
																to in allClassesAndInterfacesInProject, 
																isClass(to) || isInterface(to) };
	rel [loc, loc] all_CC_CI_II_NonFR_rels = getNonFrameworkInheritanceRels(getInheritanceRelations(projectM3), projectM3);	
	map [loc, set [loc] ] mapTypeDef = toMap(subtypeAssignmentTypeDef); 															
	map [loc, set [loc] ] varsAndClasses = (typeDef : mapTypeDef[typeDef] | typeDef <- mapTypeDef , size(mapTypeDef[typeDef]) == 2);
	for (loc aVariable <- varsAndClasses) {
		inheritanceKey iKey = getInheritanceKeyFromTwoTypes(toList(varsAndClasses[aVariable]), all_CC_CI_II_NonFR_rels, projectM3); 
		resultRel  += <iKey, SUBTYPE>;
		subtypeLog += <iKey, <aVariable, SUBTYPE_ASSIGNMENT_TYPE_DEPENDENCY>>;
	} // for
	iprintToFile(subtypeTypeDepLogFile, subtypeLog);
	return resultRel;
}

private rel [inheritanceKey, inheritanceType] getSubtypeCasesFromM3(M3 projectM3) {
	rel [inheritanceKey, inheritanceType] resultRel = {};
	lrel [inheritanceKey, subtypeM3Detail] subtypeLog = [];
	set [loc] 	allMethodsInProject = 	{decl | <decl, prjct> <- projectM3@declarations, isMethod(decl) };
	map [loc, set [loc] ] methodsAndTypes = toMap({ <from, to> | <from, to> <- projectM3@typeDependency,
																from in allMethodsInProject });

	map [loc, set [loc] ] subtypeMethods = (typeDep : methodsAndTypes[typeDep] | typeDep <- methodsAndTypes , size(methodsAndTypes[typeDep]) >= 1);
	
	iprintln(subtypeMethods);
	//iprintToFile(subtypeM3LogFile, subtypeLog);
	return resultRel;
}

private list [inheritanceKey, loc, inheritanceSubtype] getVariableListWithSubtype(Type typeOfVar, list [Expression] fragments) {
 	list [inheritanceKey, loc, inheritanceSubtype ] retList = [];
  	TypeSymbol lhsTypeSymbol = getTypeSymbolFromRascalType(typeOfVar);
	tuple [bool hasStatement, TypeSymbol rhsTypeSymbol] typeSymbolTuple = getTypeSymbolFromVariable(fragments[size(fragments) - 1]);
	if (typeSymbolTuple.hasStatement) {
		tuple [bool isSubtypeRel, inheritanceKey iKey] result = getSubtypeRelation(rhsTypeSymbol, lhstypeSymbol); 
		if (result.isSubtypeRel) {
			for (anExpression <- fragments) {
 					retList += <result.iKey, anExpression@decl, SUBTYPE_ASSIGNMENT_VAR_DECL>;
 				}
		}
	}
 	return retList;
}


