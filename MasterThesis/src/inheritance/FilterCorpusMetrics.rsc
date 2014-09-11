module inheritance::FilterCorpusMetrics

import IO;
import Map;
import Set;
import Relation;
import List;
import ListRelation;
import DateTime;
import String;


public loc beginPath = |file:///home/aytekin/Documents/Metrics_Compiled_Corpus|;
 	
public str inputFileName = "Raw_Metrics_Copied.txt";
public str outputFileName = "Filtered_Metrics.txt";

//  regular expression : "(.)+(±[\\S]+\\s)+(.)+"

list [str] processFileLines(list [str] iLines) {
	list [str] retList = [];
	for (aLine <- iLines) {
		list [str] allValues = split(" ", aLine);
		list [str] replacedValues = [];
		for (aValue <- allValues) {
			repValue = aValue;
			int bIndex = findFirst(aValue, "±");
			if (bIndex != -1) {
				repValue = substring(aValue,0, bIndex);
			}
			replacedValues += repValue;
		}	
		retList += intercalate(" ", replacedValues) + "\n";
	}
	iprintln(retList);
	return retList;
}



public void filterMetrics(){
	loc inputFileLoc = beginPath + inputFileName;
	loc outputFileLoc = beginPath + outputFileName;
	
	list [str] inputLines = [];
	list [str] outputLines = [];
	try {
		inputLines = readFileLines(inputFileLoc);
	}
	catch PathNotFound  :  {
		println("<inputFileLoc> file not found.");
	}	
	
	outputLines = processFileLines(inputLines);
	try {
		writeFile(outputFileLoc, outputLines);
	}
	catch PathNotFound : {
		println("<outputFileLoc> file not found.");
	}


}