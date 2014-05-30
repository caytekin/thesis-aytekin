package edu.uva.analysis.samples.tct;

public class X {
	A aNewA = new A(this);	// this changing type candidate, case 420, tested, working, 6-5-2014
	
	X() {
		
	}
}
