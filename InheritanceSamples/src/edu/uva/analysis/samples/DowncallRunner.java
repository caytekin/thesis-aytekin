package edu.uva.analysis.samples;

public class DowncallRunner {
	void runDowncall() {
		Parent aParent = new Parent();
		Child aChild = new Child();
		GrandChild aGrandChild = new GrandChild();
		GrandGrandChild aGrandGrandChild = new GrandGrandChild();

		aParent.p();		// not a downcall
		
		aChild.p();			// downcall, tested, working
		
		aGrandChild.p();	// downcall, tested, working
		
		aGrandGrandChild.p();	// downcall, tested, working
	}
	
	void runWithThis() {
		DowncallChild dChild = new DowncallChild();
		dChild.p();		// downcall, tested, working
	}
	
	public static void main (String[] args) {
		DowncallChild dChild = new DowncallChild();
		dChild.p();				// downcall, tested, working.
	}
}
