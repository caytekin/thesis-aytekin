package edu.uva.analysis.samples.er;

public class InterfaceRunner {

	ParentInterface pi; 
	ChildInterface ci;
	
	public InterfaceRunner() {
		// TODO Auto-generated constructor stub
	}

	
	void runInterface() {
		ci.parentInterfaceMethod1();
	}
}
