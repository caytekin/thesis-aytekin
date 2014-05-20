package edu.uva.analysis.samples.dc;

public class DowncallChild extends DowncallParent implements ConstantInterface {

	void q() {
		System.out.println("The q() of Child is called...");
		
	}
	
	void x() {
		p();		// This is also a downcall... Yes, it is tested and caught as a downcall. 19-5-2014
	}
	
}
