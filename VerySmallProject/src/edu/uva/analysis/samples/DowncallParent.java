package edu.uva.analysis.samples;

public class DowncallParent <T> {

	void p(T aT) {
		System.out.println("And the winner is!....: ");
		DowncallParent downcallParent = new DowncallParent();
		q(aT);
	}
	
	void q(T aT) {
		System.out.println("The q() of parent is called.");
	}
	
	DowncallParent getMeThis() {
		return this;
	}
	
}
