package edu.uva.analysis.samples;


public class ARunner {

	GenCaseParent 	aGenParent; 
	GenCaseChild 	aGenChild; 
	
	X returnAnX() {
		return new Y();
	}
	
	void genericII() {
		Object o = new Object();
		aGenParent = (GenCaseParent)o;
	}
}
