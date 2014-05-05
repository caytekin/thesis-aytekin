package edu.uva.analysis.samples.st;

import edu.uva.analysis.gensamples.st.ArrayListChild;
import edu.uva.analysis.gensamples.st.ArrayListParent;

public class AstmtInterfaceRunner {
	
	/*
	{
		STInterface initParent;
		initParent = new STClass();			// subtype case 301, tested, working, 5-5-2014
	}

	static {
		STInterface initParent;
		initParent = new STClass();			// subtype case 302,  tested, working, 5-5-2014
	}
	
	AstmtInterfaceRunner getMeARunner() {
		return new AstmtInterfaceRunner();
	}
	
	STClass getMeAChild() {
		return new STClass();
	}
	
	C getMeAC () {
		return new C();
	}
	
	void methodChain() {
		STInterface aParent; 
		aParent = this.getMeAChild();			// subtype case 303,  tested, working, 5-5-2014	
		
		ArrayListParent <NestedParent<P>> nestedListParent;
		ArrayListChild <NestedParent<P>> nestedListChild = new ArrayListChild <NestedParent<P>> ();
		nestedListParent = nestedListChild;		// subtype case 304,  tested, working, 5-5-2014
		
		aParent = getMeAChild();				// subtype case 305,  tested, working, 5-5-2014
		
		P aP;
		aP = this.getMeARunner().getMeAC();		// subtype case 306,  tested, working, 5-5-2014
	}

	void runIt() {
		STInterface aParent;
		aParent = new STClass();			// subtype case 307, tested, working, 5-5-2014
		
		STInterface [] parentArray = new STInterface [3];
		STClass [] childArray = new STClass [3];
		parentArray = childArray;			// subtype case 308, tested, working, 5-5-2014
		
		parentArray[0] = childArray [1];	// subtype case 309, tested, working, 5-5-2014
		
		ArrayListParent <STClass> listParent = new ArrayListParent <STClass> ();
		aParent  = listParent.get(0);		// subtype case 310, tested, working, 5-5-2014
	
		listParent = new ArrayListChild <STClass> ();	// subtype case 311, tested, working, 5-5-2014
		
		ArrayListChild <STClass> listChild = new ArrayListChild <STClass> ();		
		listParent = listChild;					// subtype case 312, tested, working, 5-5-2014
		
	}
	*/
}
