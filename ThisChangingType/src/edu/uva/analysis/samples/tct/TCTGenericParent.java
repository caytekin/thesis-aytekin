package edu.uva.analysis.samples.tct;

public class TCTGenericParent <T> {
	TCTGenericParent() {
		
	}
	
	TCTGenericParent (TCTGenericParent <T> aT) {
		
	}
	
	void aMethod() {
		new TCTGenericParent(this);			// this changing type candidate, case 401, tested, working, 6-5-2014
	} 
}
