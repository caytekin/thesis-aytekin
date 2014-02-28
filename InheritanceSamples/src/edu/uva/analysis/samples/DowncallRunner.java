package edu.uva.analysis.samples;

public class DowncallRunner {
	void runDowncall() {
		Parent aParent = new Parent();
		Child aChild = new Child();
		GrandChild aGrandChild = new GrandChild();
		GrandGrandChild aGrandGrandChild = new GrandGrandChild();

		aParent.p();		// not a downcall
		
		aChild.p();			// downcall
		
		aGrandChild.p();	// downcall
		
		aGrandGrandChild.p();	// downcall
		
	
	
	
	}
}
