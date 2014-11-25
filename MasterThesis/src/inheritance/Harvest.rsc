module inheritance::Harvest

import IO;
import Map;
import Set;
import Relation;
import List;
import ListRelation;
import DateTime;
import ValueIO;

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



public list [str] projectList = [
"ant1.8.1",
"antlr-3.4", 
"aoi-2.8.1",
"argouml-0.34",
"aspectj-1.6.9_tools",		

"axion-1.0-M2",
"c_jdbc-2.0.2",

"castor-1.3.3_codegen",
"castor-1.3.3_cpactf",
"castor-1.3.3_ddlgen",
"castor-1.3.3_jdo",
"castor-1.3.3_testsuite-xml-framework",
"castor-1.3.3_xml",
"castor-1.3.3_xml-schema",

"cayenne-3.0.1",		

"checkstyle-5.6",
"cobertura-1.9.4.1",
"colt-1.2.0",
"columba-1.0_addressbook",
"columba-1.0_core",
"columba-1.0_mail",

"derby-10.9.1.0",		// not done yet, 17-11

"displaytag-1.2",
"drawswf-1.2.9",
//"drjava-stable-20100913-r5387",			// stack overflow
"emma-2.0.5312",

"exoportal-v1.0.2",		

"findbugs",
"fitjava-1.1",
"fitlibraryforfitnesse-20110301",
"freecol-0.10.3",
"FreeCS", 
"galleon-2.3.0",
"ganttproject-2.1.1",

"heritrix-1.14.4",

"hibernate-4.2.0",     	

"hsqldb-2.0.0",
"htmlunit-2.8",
"informa-0.7.0-alpha2",
"iReport-3.7.5",
"itext-5.0.3",
"james-2.2.0_src-java",
"jasml-0.10",
"javacc-5.0",
"jchempaint-3.0.1",
"jedit-4.3.2",
"jext-5.0",

"jFin_DateMath-R1.0.1_src-main",
"jfreechart-1.0.13",
"jgraph-5.13.0.0",
"jgraphpad-5.10.0.2",
"jgrapht-0.8.1",				// 50
"JGroups",
"jhotdraw-7.5.1",
"jmeter-2.5.1",
"jmoney-0.4.4",
"jOggPlayer114s",

"jparse-0.96",
"jpf-1.5.1",
"jrat-1-beta1_branches-nkadwa_nio-source-core-java",

// "jre-1.6.0",				could not be analyzed, Rascal error in Corba analysis
"jrefactory-2.9.19",
"JRuby",
"JSPWiki-2.8",
"jsXe-04_beta",
"jtopen-7.1",
"jung-2.0.1",
"junit-4.10",
"log4j-2.0-beta",

"lucene-4.2.0",		
	
"marauroa-3.8.1",
"maven-3.0.5",
"megamek-0.35.18",			// 70
"mvnforum-1.2.2-ga",
"myfaces_core-2.1.10_src-myfaces-api-2.1.10-sources",
// "myfaces_core-2.1.10_src-myfaces-core-module-2.1.10",		// not done, Rascal exception
"myfaces_core-2.1.10_src-myfaces-impl-2.1.10-sources",
"myfaces_core-2.1.10_src-myfaces-impl-shared-2.1.10-sources",

"nakedobjects-4.0.0",	

"nekohtml-1.9.14",
"openjms-0.7.7-beta-1",
"oscache-2.3",
"picocontainer-2.10.2",
"pmd-4.2.x",
"poi-3.6",
"pooka-3.0-080505",
"proguard-4.9",  
"quickserver-1.4.7",
"quilt-0.6-a-5",
//"roller-5.0.1",				// Rascal error - abort compilation...
"rssowl-2.0.5",
"sablecc-3.2",

"springframework-3.0.5_projects-org.springframework.core",
"springframework-3.0.5_projects-org.springframework.jdbc",

"squirrel",
"struts-2.2.1",
"sunflow-0.07.2",
"tapestry-5.1.0.5",
"tomcat-7.0.2",

"trove-2.1.0",
"velocity1.6.4",
"webmail-0.7.10",
"weka-3-6-9",				
"xalan-2.7.1",
"xerces-2.10.0"

];



public void harvest() {
	bool fileFound = false;
	loc harvestFile = beginPath + "Harvest.csv" ;
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


