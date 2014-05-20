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
	
	void fieldAccess() {
		int i = ci.parentField; 
	}
	
	void aCIMethodAccess() {
		ParentImplementor pImpl = new ParentImplementor();
		pImpl.parentInterfaceMethod1();
	}
	
	void aCIFieldAccess() {
		ParentImplementor pImpl2 = new ParentImplementor();
		int anotherInt = pImpl2.parentField;
	}

}
