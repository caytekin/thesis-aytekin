package edu.uva.analysis.samples.st;

import edu.uva.analysis.gensamples.st.ArrayListChild;
import edu.uva.analysis.gensamples.st.ArrayListParent;

public class VrblInterfaceRunner {
	/*
	
	{
		STInterface initParent =  new STClass();			// subtype case 331,  tested, working, 5-5-2014
	}

	static {
		STInterface initParent, iParent2, iParent3= new STClass();			// subtype case 332, tested, working, 5-5-2014
																			// subtype case 333, tested, working, 5-5-2014
																			// subtype case 334, tested, working, 5-5-2014
	}
	

	
	VrblInterfaceRunner getMeARunner() {
		return new VrblInterfaceRunner();
	}
	
	STClass getMeAChild() {
		return new STClass();
	}
	
	C getMeAC () {
		return new C();
	}
	
	void methodChain() {
		STInterface aParent = this.getMeAChild();				// subtype case 335,   tested, working, 5-5-2014
		
		ArrayListParent <NestedParent<P>> nestedListParent = new ArrayListChild <NestedParent<P>> ();   // subtype case 336,	,  tested, working, 5-5-2014   
		
		STInterface  anotherParent = getMeAChild();				// subtype case 337,   tested, working, 5-5-2014
		
		P aP = this.getMeARunner().getMeAC();					// subtype case 338,   tested, working, 5-5-2014
	}

	void runIt() {
		STInterface aParent = new STClass();			// subtype case 339,  tested, working, 5-5-2014
		
		STInterface [] parentArray = new STClass [3]; // subtype case 340,  tested, working, 5-5-2014
		
		STClass [] childArray = new STClass[100]; 
		
		STInterface aCell = childArray [0];	// subtype case 341,  tested, working, 5-5-2014
		
		ArrayListParent <STClass> listParent = new ArrayListParent <STClass> ();
		STInterface secondParent  = listParent.get(0);		// subtype case 342,  tested, working, 5-5-2014
	
	}
*/

}
