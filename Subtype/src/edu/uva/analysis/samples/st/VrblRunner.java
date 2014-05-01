package edu.uva.analysis.samples.st;

import edu.uva.analysis.gensamples.st.*;

public class VrblRunner {
	/*
	
	{
		VrblParent initParent =  new VrblChild();			// subtype case 25,  tested, working, 29-4-2014
	}

	static {
		VrblParent initParent, iParent2, iParent3= new VrblChild();			// subtype case 26, tested, working, 01-5-2014
																			// subtype case 43, tested, working, 29-4-2014
																			// subtype case 44, tested, working, 29-4-2014
	}
	

	
	VrblRunner getMeARunner() {
		return new VrblRunner();
	}
	
	VrblChild getMeAChild() {
		return new VrblChild();
	}
	
	C getMeAC () {
		return new C();
	}
	
	void methodChain() {
		VrblParent aParent = this.getMeAChild();				// subtype case 27,   tested, working, 29-4-2014
		
		ArrayListParent <NestedParent<P>> nestedListParent = new ArrayListChild <NestedParent<P>> ();   // subtype case 28,   
		
		VrblParent  anotherParent = getMeAChild();				// subtype case 29,   tested, working, 29-4-2014
		
		P aP = this.getMeARunner().getMeAC();					// subtype case 30,   tested, working, 29-4-2014
	}

	void runIt() {
		VrblParent aParent = new VrblChild();			// subtype case 31,  tested, working, 29-4-2014
		
		VrblParent [] parentArray = new VrblChild [3]; // subtype case 32,  tested, working, 29-4-2014
		
		VrblChild [] childArray = new VrblChild[100]; 
		
		VrblParent aCell = childArray [0];	// subtype case 33,  tested, working, 29-4-2014
		
		ArrayListParent <VrblChild> listParent = new ArrayListParent <VrblChild> ();
		VrblParent secondParent  = listParent.get(0);		// subtype case 34,  tested, working, 29-4-2014
	
		ArrayListParent <VrblChild> thirdParent = new ArrayListChild <VrblChild> ();	// subtype case 35, tested, working, 29-4-2014  
		
		ArrayListChild <VrblChild> listChild = new ArrayListChild <VrblChild> ();		
		ArrayListParent <VrblChild> secondListParent = listChild;					// subtype case 36,  tested, working, 29-4-2014
		
	}

	void runGrandChild() {
		VrblParent aParent = new VrblGrandChild();			// subtype case 37,  tested, working, 29-4-2014
		
		VrblParent [] parentArray = new VrblGrandChild [3]; // subtype case 38,  tested, working, 29-4-2014
		
		VrblGrandChild [] childArray = new VrblGrandChild[100]; 
		
		VrblParent aCell = childArray [0];	// subtype case 39,  tested, working, 29-4-2014
		
		ArrayListParent <VrblGrandChild> listParent = new ArrayListParent <VrblGrandChild> ();
		VrblParent secondParent  = listParent.get(0);		// subtype case 40,  tested, working, 29-4-2014
	
		ArrayListParent <VrblGrandChild> thirdParent = new ArrayListChild <VrblGrandChild> ();	// subtype case 41, tested, working, 29-4-2014  
		
		ArrayListChild <VrblGrandChild> listChild = new ArrayListChild <VrblGrandChild> ();		
		ArrayListParent <VrblGrandChild> secondListParent = listChild;					// subtype case 42,  tested, working, 29-4-2014
		
	}
*/
}
