package edu.uva.analysis.samples;

public class DowncallChild <T> extends DowncallParent <T>  {

	void q(T aT) {
		System.out.println("The q() of Child is called...");
		
	}
	
}
