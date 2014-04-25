package edu.uva.analysis.samples.dc;

public class StaticDCParent {
	
	static void p() {
		System.out.println("Static parent p() is called");		
		q();
	}
	
	static void q() {
		System.out.println("Static parent q() is called");
	}

}
