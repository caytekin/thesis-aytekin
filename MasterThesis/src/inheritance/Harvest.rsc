module inheritance::Harvest

import IO;
import Map;
import Set;
import Relation;
import List;
import ListRelation;
import DateTime;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import inheritance::InheritanceDataTypes;
import inheritance::InheritanceModules;



public str readFileLine(loc fileLoc) {
	str retStr = "";
	try {
		list [str] fileLines = readFileLines(fileLoc);
		retStr = fileLines[0];
	}
	catch PathNotFound  :  {
		println("<fileLoc> file not found.");
	;}	
	return retStr;
}


public void writeMetricNames(loc fileLoc) {
	appendToFile(fileLoc, "Sysver\t");
	for (aMetric <- [numExplicitCC..perUnexplainedII + 1]) {
		appendToFile(fileLoc, "<getNameOfInheritanceMetric(aMetric)>\t");
	}
	appendToFile(fileLoc,"\n");
}



list [str] projectList = [
"cobertura-1.9.4.1" ,
"displaytag-1.2" ,
"emma-2.0.5312"  ,
"fitjava-1.1"  ,
"FreeCS" 
];
 

/*
list [str] projectList = [
"InheritanceSamples", 
"VerySmallProject" ,
"ThisChangingType" ,
"Category"  ,
"GenericProject"  ,
"Subtype" 
];
*/


public void harvest() {
	loc fileName = DEFAULT_LOC;
	bool fileFound = false;
	loc harvestFile = beginPath + "Harvest.txt" ;
	writeFile(harvestFile, "FINAL RESULTS \n");
	writeMetricNames(harvestFile);
	for (aProject <- projectList) {
		loc fileLoc = beginPath + aProject + resultsFile;
		str resultStr = readFileLine(fileLoc) + " \n" ;
		if (resultStr != "") {
			appendToFile(harvestFile, resultStr); 
			println("The results for project <aProject> are harvested.");
		}
		else {
			println("The results for project <aProject> are not found." );
		}  
	}
}


