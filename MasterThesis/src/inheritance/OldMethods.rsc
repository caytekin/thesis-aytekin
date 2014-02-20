module inheritance::OldMethods

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

