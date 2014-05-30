package edu.uva.analysis.samples.tct;

public class TCTChild extends TCTParent {
	
	TCTChild() {
		super();				// now, this is also taken into consideration as this changing type occurrence, 30-5-2014
	}
	
	void callingWithoutAReference() {
		aMethod();				// this is also a this changing type occurrence, 30-5-2014
	}

}
