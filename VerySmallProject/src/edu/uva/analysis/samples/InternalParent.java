package edu.uva.analysis.samples;

public class InternalParent {

	public String parentString = "I am ainternal parent String";
	
	public void getMeNothing() {
		
	}
	
	public String getMeAString() {
		return this.parentString;
	}
}
