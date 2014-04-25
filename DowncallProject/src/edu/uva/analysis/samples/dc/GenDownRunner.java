package edu.uva.analysis.samples.dc;

public class GenDownRunner {
	
	GenDownChild <String> getMeAChild() {
		return new GenDownChild <String> ();
	}
	
	
	void functionChain() {
		GenDownChild <String> gc = new GenDownChild <String>();
		gc.returnString();					// downcall, tested, 25-04, working 
		
		this.getMeAChild().returnString(); 	// downcall, tested, 25-04, working 
		
		gc.returnString().length(); 		// downcall , tested,25-04, working
		
		boolean aBool = false;
		
		if (aBool) {
			gc.p(new String());           	// downcall , tested, 25-04, working 
		}
		else {
			
		}
		
	}

}
