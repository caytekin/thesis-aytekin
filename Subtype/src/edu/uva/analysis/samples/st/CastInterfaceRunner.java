package edu.uva.analysis.samples.st;

import java.util.ArrayList;
import java.util.List;

import edu.uva.analysis.gensamples.st.ArrayListChild;
import edu.uva.analysis.gensamples.st.ArrayListParent;

public class CastInterfaceRunner {
	/*

	C fieldC = new C();
	
	C returnAC() {
		return new C();
	}
	
	void acceptAP(P paramP) {
		
	}
	
	CastGrandChild getMeAGrandChild() {
		return new CastGrandChild();
	}
	
	void runIt() {
		STInterface aParent;
		aParent = (STInterface)(new STClass());			// subtype, case 320, tested, working, 5-5-2014
															// upcasting
		
		ArrayListChild <STClass> aListChild = new ArrayListChild <STClass> ();
		ArrayListParent <STClass> aListParent = new ArrayListParent <STClass> ();
		
		aListParent = (ArrayListParent <STClass>)aListChild;		// subtype, case 321, tested, working, 5-5-2014
		
		STInterface aSTInterface;
		aSTInterface = (STInterface)aListChild.get(0);				// subtype, case 322, tested, working, 5-5-2014
		
		ArrayListChild <STClass > aNestedList = new ArrayListChild <STClass> (); 
		STInterface anInterface = (STInterface) aNestedList.get(0);		// subtype, case 324, tested, working, 5-5-2014
		
		
		STClass anotherChild= (STClass)aParent;				// subtype, case 325, tested, 5-5-2014
															// downcasting.
		
	}
	*/
}
