package edu.uva.analysis.samples.tct;

public class TCTGrandChild extends TCTChild {
	
	void aMethod() {
		new A(this);	// // this changing type candidate, case 402, tested, working, 6-5-2014
	}
}
