package edu.uva.analysis.samples.dc;

public class DowncallParent {

	boolean p() {
		System.out.println("And the winner is!....: ");
		DowncallParent downcallParent = new DowncallParent();
		q();
		return true;
	}
	
	void q() {
		System.out.println("The q() of parent is called.");
	}
	
	DowncallParent getMeThis() {
		return this;
	}
	
}
