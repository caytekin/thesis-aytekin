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
"ant-1.8.2",
"antlr-3.4", 
"aoi-2.8.1",
"argouml-0.34",
// "aspectj-1.6.9_matcher",   this project is contained in aspectj-1.6.9_tools 
// "aspectj-1.6.9_rt",		  this is also mostly contained in aspectj-1.6.9_tools. 
"aspectj-1.6.9_tools",
// "aspectj-1.6.9_weaver",	  this project is contained in aspectj-1.6.9_tools
"axion-1.0-M2",
"c_jdbc-2.0.2",
"castor-1.3.3",
"cayenne-3.0.1",
"checkstyle-5.6",
"cobertura-1.9.4.1",
"colt-1.2.0",
"columba-1.0_addressbook",
"columba-1.0_api",
"columba-1.0_core",
"columba-1.0_mail",
"columba-1.0_test",
"derby-10.9.1.0",
"displaytag-1.2",
"drawswf-1.2.9",
"drjava-stable-20100913-r5387",
"emma-2.0.5312",
"exoportal-v1.0.2",
"findbugs-1.3.9",
"fitjava-1.1",
"fitlibraryforfitnesse-201110301",
"freecol-0.10.3",
"freecs-1.3.20100406",
"FreeCS", 
"galleon-2.3.0",
"ganttproject-2.1.1",
"heritrix-1.14.4",
"hibernate-4.2.0",      
"hsqldb-2.0.0",
"htmlunit-2.8",
"informa-0.7.0-alpha2",
"ireport-3.7.5",
"itext-5.0.3",
"jFin_DateMath-R1.0.1",
"james-2.2.0",
"jasml-0.10",
"javacc-5.0",
"jchempaint-3.0.1",
"jedit-4.3.2",
"jext-5.0",
"jfreechart-1.0.13",
"jgraph-5.13.0.0",
"jgraphpad-5.10.0.2"

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


