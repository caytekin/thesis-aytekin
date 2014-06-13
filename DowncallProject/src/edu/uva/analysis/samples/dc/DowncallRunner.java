package edu.uva.analysis.samples.dc;

import java.util.List;
import java.util.ArrayList;


public class DowncallRunner {
	
	I3 anI3;

	I3 getI3() {
		return anI3;
	}
	
	void acceptABoolean(boolean aBool) {
		
	}
	
	void ifDowncall() {
		DowncallChild dc = new DowncallChild();
		if (dc.p()) {		// downcall, tested, 25-04, working 
			// it's true
		}
		else {
			// it's false
		}
		
		
		while (dc.p()) {		// downcall , tested, 25-04, working 
			
		}
		
		acceptABoolean(dc.p());		// downcall , tested, 25-04, working 
	}
	
	
	void runGenDowncall() {
		GenDownChild <P>  aChild = new GenDownChild <P> ();
		aChild.p(new P());                // downcall, tested, working, 25-04

		// Generic arrays are not allowed in Java
		
		GenDownChild [] childArray = new GenDownChild [3];
		childArray[0].p(new P());		// downcall,  tested, working, 25-04
		
		List <GenDownChild > aList = new ArrayList <GenDownChild > ();
		
		aList.add (new GenDownChild());
		P  aP = new P();
		aList.get(0).p(aP);		// downcall, tested, working, 25-04
		
	}
	
	
	void runDowncall() {
		Parent aParent = new Parent();
		Child aChild = new Child();
		GrandChild aGrandChild = new GrandChild();
		GrandGrandChild aGrandGrandChild = new GrandGrandChild();

		aParent.p();		// not a downcall
		
		aChild.p();			// downcall, tested, working, 25-04
		
		aGrandChild.p();	// downcall, tested, working, 25-04
		
		aGrandGrandChild.p();	// downcall, tested, working, 25-04
	}
	
	void runWithThis() {
		DowncallChild dChild = new DowncallChild();
		dChild.p();		// downcall, tested, working, 25-04
		
		I1 anotherI1 = getI3();
	}
	
	public static void main (String[] args) {
		DowncallChild dChild = new DowncallChild();
		dChild.p();				// downcall, tested, working, , 25-04
		
		Q aQ = new S();
		
		I1 anI1 = new C2();		
	}
}
