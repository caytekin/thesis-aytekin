package edu.uva.analysis.samples.st;

import edu.uva.analysis.gensamples.st.*;

public class SRunner {
	void runIt() {
		
		// TODO: Think more examples of CI subtype for assignment, 
		// variable, etc.
		
		SInterface sInterface;
		sInterface = new SClass();			// subtype case 50,  
		
		SInterface  [] parentArray = new SClass [3];
		SClass [] childArray = new SClass [3];
		parentArray = childArray;			// subtype case 51,  
		
		parentArray[0] = childArray [1];	// subtype case 52,  
		
		ArrayListParent <SClass> listParent = new ArrayListParent <SClass> ();
		sInterface  = listParent.get(0);		// subtype case 53,  
	
		ArrayListParent <SInterface> aList;
		aList = new ArrayListChild <SInterface> ();	// subtype case 54,  
		
		ArrayListChild <SClass> listChild = new ArrayListChild <SClass> ();		
		listParent = listChild;					// subtype case 55,  
		
	}


}
