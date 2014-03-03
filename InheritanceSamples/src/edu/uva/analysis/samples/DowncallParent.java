package edu.uva.analysis.samples;

public class DowncallParent {

	void p() {
		System.out.println("And the winner is!....: ");
		DowncallParent downcallParent = new DowncallParent();
		q();
	}
	
	void q() {
		System.out.println("The q() of parent is called.");
	}
	
	DowncallParent getMeThis() {
		return this;
	}
	
}
