package edu.uva.analysis.samples.st;

public class CastGrandChild extends CastChild {
	
	C getMeAC() {
		return new C();
	}

	public STClass getMeASTC() {
		return new STClass();
	}

}
