package edu.uva.analysis.samples.st;

import java.util.ArrayList;
import java.util.List;

import edu.uva.analysis.gensamples.st.ArrayListChild;
import edu.uva.analysis.gensamples.st.ArrayListParent;

public class ReturnInterfaceRunner {
	
	STClass fieldC = new STClass();
	
	STClass returnAC() {
		return new STClass();
	}
	
	CastGrandChild getMeAGrandChild() {
		return new CastGrandChild();
	}

	
	STInterface returnAP1() {
		return new STClass();							// subtype, case 351, tested, working, 5-5-2014
	}
	
	STInterface returnAP2() {
		return returnAC(); 						// subtype, case 352, tested, working, 5-5-2014
	}
	
	STInterface returnAP3() {
		return this.fieldC;						// subtype, case 353, tested, working, 5-5-2014
	}
	
	
	
	STInterface anotherReturnP() {
		return getMeAGrandChild().getMeASTC();	// subtype, case 354, tested, working, 5-5-2014
	}
	
	STInterface[] returnAPArray() {
		return new STClass[3];						// subtype, case 355, tested, working, 5-5-2014
	}
	
	STInterface anotherPReturn() {
		return (new STClass[3])[0];					// subtype, case 356, tested, working, 5-5-2014
	}

	STInterface aPReturn1() {
		List <STClass> aCList = new ArrayList <STClass> ();
		return aCList.get(0);					// subtype, case 357, tested, working, 5-5-2014
	}
	
	
	
	ArrayListParent <NestedChild <STInterface>> returnAListParent() {
		return new ArrayListChild <NestedChild <STInterface>> ();	// subtype, case 358, tested, working, 5-5-2014
	}
	
	NestedParent <STInterface> retNestedParent() {
		ArrayListChild <NestedChild <STInterface>> aChildList = new ArrayListChild <NestedChild <STInterface>> ();
		return aChildList.get(0);					// subtype, case 359, tested, working, 5-5-2014
	}
	
	
	STInterface doubleReturn() {
		boolean aBool = false;
		if (aBool) {
			return new STClass();						// subtype, case 360, tested, working, 5-5-2014
		}
		else return new STClass();					// subtype, case 361, tested, working, 5-5-2014
	}
}
