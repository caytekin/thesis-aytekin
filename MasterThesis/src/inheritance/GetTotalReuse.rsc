module inheritance::GetTotalReuse


import IO;
import Map;
import Set;
import Relation;
import List;
import ListRelation;
import DateTime;
import util::Math;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;


import inheritance::InheritanceDataTypes;
import inheritance::InheritanceModules;
import inheritance::InternalReuse;
import inheritance::ExternalReuse;







public void getTotalReuse() {
	setPrecision(4);
	rel [inheritanceKey, int] allInheritanceCases = {};	
	println("Date: <printDate(now())>");
	loc projectLoc = |project://VerySmallProject|; 
	M3 projectM3 = getM3ForProjectLoc(projectLoc);
	addedPercentagesFile = "AddedPercentagesStandAlone.txt";
	str totalReuseFile = "TotalReuseFile.txt";
	loc reuseFileLoc = beginPath + totalReuseFile;
	errorLog = "ErrorStandAlone.log";
	writeFile(getFilename(projectM3.id, errorLog), "Error log for stand alone version :<projectM3.id.authority>\n" );
	writeFile(getFilename(projectM3.id, addedPercentagesFile), " ");

	rel [inheritanceKey, int] internalReuseCases = {};	
	rel [inheritanceKey, int] externalReuseCases = {};	

	
	println("Starting with internal reuse cases at: <printTime(now())> ");
	internalReuseCases = getInternalReuseCases(projectM3);
	println("Internal use cases are done...<printTime(now())>");
	
	println("Starting with external reuse cases at: <printTime(now())> ");
	externalReuseCases += getExternalReuseCases(projectM3);	
	println("External use cases are done at <printTime(now())>...");	
	
	internalKeySet = {inhKey | <inhKey, inhType> <- internalReuseCases};
	externalKeySet = {inhKey | <inhKey, inhType> <- externalReuseCases};
	
	int totalReuse = size(internalKeySet + externalKeySet);
	println("Total reuse number for project : <projectLoc> is: <totalReuse>");

	if (!exists(reuseFileLoc)) {
		writeFile(reuseFileLoc, "sysver total_reuse \n");
	}
	appendToFile(reuseFileLoc, "<projectM3.id.authority>  <totalReuse> \n");
}

