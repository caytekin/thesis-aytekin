module inheritance::FilterTemperoResults

import IO;
import Map;
import Set;
import Relation;
import List;
import ListRelation;
import DateTime;
import String;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;



public loc beginPath = |file:///home/aytekin/Documents/InheritanceUseData/inheritance-graphs|; 	

public str filteredDir = "/filtered";

public str fileSuffix = "-graph.csv";

list [str] projectList = [
"ant-1.8.1",
"antlr-3.2",
"aoi-2.8.1",
"argouml-0.30.2",
"aspectj-1.6.9",
"axion-1.0-M2",
"c_jdbc-2.0.2",
"castor-1.3.1",
"cayenne-3.0.1",
"checkstyle-5.1",
"cobertura-1.9.4.1",
"colt-1.2.0",
"columba-1.0",
"derby-10.6.1.0",
"displaytag-1.2",
"drawswf-1.2.9",
"drjava-stable-20100913-r5387",
"emma-2.0.5312",
"exoportal-v1.0.2",
"findbugs-1.3.9",
"fitjava-1.1",
"fitlibraryforfitnesse-20100806",
"freecol-0.9.4",
"freecs-1.3.20100406",
"galleon-2.3.0",
"ganttproject-2.0.9",
"heritrix-1.14.4",
"hibernate-3.6.0-beta4",
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
"jgraphpad-5.10.0.2",
"jgrapht-0.8.1",
"jgroups-2.10.0",
"jhotdraw-7.5.1",
"jmeter-2.4",
"jmoney-0.4.4",
"joggplayer-1.1.4s",
"jparse-0.96",
"jpf-1.0.2",
"jrat-0.6",
"jre-1.5.0_22",
"jrefactory-2.9.19",
"jruby-1.5.2",
"jsXe-04_beta",
"jspwiki-2.8.4",
"jtopen-7.1",
"jung-2.0.1",
"junit-4.8.2",
"log4j-1.2.16",
"lucene-2.4.1",
"marauroa-3.8.1",
"maven-3.0",
"megamek-0.35.18",
"mvnforum-1.2.2-ga",
"myfaces_core-2.0.2",
"nakedobjects-4.0.0",
"nekohtml-1.9.14",
"openjms-0.7.7-beta-1",
"oscache-2.4.1",
"picocontainer-2.10.2",
"pmd-4.2.5",
"poi-3.6",
"pooka-3.0-080505",
"proguard-4.5.1",
"quickserver-1.4.7",
"quilt-0.6-a-5",
"roller-4.0.1",
"rssowl-2.0.5",
"sablecc-3.1",
"springframework-1.2.7",
"squirrel_sql-3.1.2",
"struts-2.2.1",
"sunflow-0.07.2",
"tapestry-5.1.0.5",
"tomcat-7.0.2",
"trove-2.1.0",
"velocity-1.6.4",
"webmail-0.7.10",
"weka-3.7.2",
"xalan-2.7.1",
"xerces-2.10.0"
];


public str EXPLICIT = "Explicit";
public str IMPLICIT_KONWN = "ImplicitKnown";
public str USER_DEFINED = "UserDefined";


public str CC = "CC";
public str CI = "CI";
public str II = "II";

public str DOWNCALL = "Downcall"; 

public str DIRECT_SUBTYPE = "DirectSubtype";
public str INDIRECT_SUBTYPE = "DirectSubtype";

public str DIRECT_EXTERNAL_REUSE_METHOD = "DirectExReuseMethod"; 
public str DIRECT_EXTERNAL_REUSE_FIELD = "DirectExReuseField"; 
public str INDIRECT_EXTERNAL_REUSE_METHOD = "IndirectExReuseMethod"; 
public str INDIRECT_EXTERNAL_REUSE_FIELD = "IndirectExReuseField"; 

public str INTERNAL_USE_FIELD = "UpcallField";
public str INTERNAL_USE_METHOD = "UpcallMethod";


public str CAST = "Cast";
public str CATEGORY = "Category";
public str FRAMEWORK = 	"Framework";
public str GENERIC_USE = "GenericUse";
public str MARKER = "Marker";
public str SINGLE = "Single";
public str SUPER = "UpcallConstructorSuper";






list [str] processFileLines(list [str] fileLines) {
	int i = 0;
	set [str] ccLines = {};
	set [str] ciLines = {};
	set [str] iiLines = {};
	for (aLine <-fileLines) {
		//println("Line: <i>");
		if (!startsWith(aLine, "#")) {
			list [str] tokens = split("\t", aLine);
			set [str] tokenSet = toSet(tokens);
			//iprintln(sort(tokenSet));
			str _child = tokens[0];
			str _parent = tokens[1];
			// we only want explicit and user defined
			if ({EXPLICIT, USER_DEFINED} <= tokenSet) { 
				if (CC in tokenSet) { ccLines += "<aLine> \n"; }
				if (CI in tokenSet) { ciLines += "<aLine> \n"; }
				if (II in tokenSet) { iiLines += "<aLine> \n";}
			}
		} 
		i = i + 1;
	}  // for 
	return ("\n" + sort(ccLines) + "\n" + sort (ciLines) + "\n" + sort (iiLines) );
} 



public void filterFiles() {

	for (aProject <- projectList) {
		loc fileLoc = beginPath + (aProject + fileSuffix);
		loc processedFileLoc = beginPath + "/filtered/" + (aProject + fileSuffix);
		list [str] fileLines = [];
		list [str] processedFileLines = [];
		try {
			fileLines = readFileLines(fileLoc);
		}
		catch PathNotFound  :  {
			println("<fileLoc> file not found.");
		}	
		processedFileLines = processFileLines(fileLines);
		try {
			writeFile(processedFileLoc, processedFileLines);
		}
		catch PathNotFound : {
			println("<processedFileLoc> file not found.");
		}
		println("Project <aProject> is processed.");
	} // for
}


