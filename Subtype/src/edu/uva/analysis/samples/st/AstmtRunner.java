package edu.uva.analysis.samples.st;

import edu.uva.analysis.gensamples.st.*;


public class AstmtRunner {
	/*
	{
		AstmtParent initParent;
		initParent = new AstmtChild();			// subtype case 13, tested, working, 29-4	
	}

	static {
		AstmtParent initParent;
		initParent = new AstmtChild();			// subtype case 17,  tested, working, 29-4	
	}
	
	AstmtRunner getMeARunner() {
		return new AstmtRunner();
	}
	
	AstmtChild getMeAChild() {
		return new AstmtChild();
	}
	
	C getMeAC () {
		return new C();
	}
	
	void methodChain() {
		AstmtParent aParent; 
		aParent = this.getMeAChild();			// subtype case 14,  tested, working, 29-4	
		
		ArrayListParent <NestedParent<P>> nestedListParent;
		ArrayListChild <NestedParent<P>> nestedListChild = new ArrayListChild <NestedParent<P>> ();
		nestedListParent = nestedListChild;		// subtype case 15,  tested, working, 29-4	
		
		aParent = getMeAChild();				// subtype case 16,  tested, working, 29-4	
		
		P aP;
		aP = this.getMeARunner().getMeAC();		// subtype case 18,  tested, working, 29-4	
	}

	void runIt() {
		AstmtParent aParent;
		aParent = new AstmtChild();			// subtype case 1, tested, working, 29-4
		
		AstmtParent [] parentArray = new AstmtParent [3];
		AstmtChild [] childArray = new AstmtChild [3];
		parentArray = childArray;			// subtype case 2, tested, working, 29-4
		
		parentArray[0] = childArray [1];	// subtype case 3, tested, working, 29-4
		
		ArrayListParent <AstmtChild> listParent = new ArrayListParent <AstmtChild> ();
		aParent  = listParent.get(0);		// subtype case 4, tested, working, 29-4
	
		listParent = new ArrayListChild <AstmtChild> ();	// subtype case 5, tested, working, 29-4
		
		ArrayListChild <AstmtChild> listChild = new ArrayListChild <AstmtChild> ();		
		listParent = listChild;					// subtype case 6, tested, working, 29-4
		
	}

	void runGrandChild() {
		AstmtParent aParent;
		aParent = new AstmtGrandChild();			// subtype case 7, tested, working, 29-4
		
		AstmtParent [] parentArray = new AstmtParent [3];
		AstmtGrandChild [] childArray = new AstmtGrandChild [3];
		parentArray = childArray;			// subtype case 8, tested, working, 29-4
		
		parentArray[0] = childArray [1];	// subtype case 9, tested, working, 29-4
		
		ArrayListParent <AstmtGrandChild> listParent = new ArrayListParent <AstmtGrandChild> ();
		aParent  = listParent.get(0);		// subtype case 10, tested, working, 29-4
		
	
		listParent = new ArrayListChild <AstmtGrandChild> ();	// subtype case 11, tested, working, 29-4
		
		ArrayListChild <AstmtGrandChild> listChild = new ArrayListChild <AstmtGrandChild> ();		
		listParent = listChild;					// subtype case 12, tested, working, 29-4
		
	}
*/
}
