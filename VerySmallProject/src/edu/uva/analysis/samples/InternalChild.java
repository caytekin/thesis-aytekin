package edu.uva.analysis.samples;

public class InternalChild extends InternalParent {
	
	String childString = parentString;
	String yetAnotherString = getMeAString();
	
	void yetAnotherMethod() {
		getMeNothing();
		parentString = "Xyz";
	}

}
