package edu.uva.analysis.samples.st;

import java.util.ArrayList;
import java.util.List;

import edu.uva.analysis.gensamples.st.ArrayListChild;
import edu.uva.analysis.gensamples.st.ArrayListParent;

public class ReturnRunner {
	
	C fieldC = new C();
	
	C returnAC() {
		return new C();
	}
	
	CastGrandChild getMeAGrandChild() {
		return new CastGrandChild();
	}
	/*
	CastParent returnCastParent1() {
		return new CastChild();					// subtype, case 120, tested, working, 1-5-2014
	}
	
	P returnAP1() {
		return new C();							// subtype, case 121, tested, working, 1-5-2014
	}
	
	P returnAP2() {
		return returnAC(); 						// subtype, case 122, tested, working, 1-5-2014
	}
	
	P returnAP3() {
		return this.fieldC;						// subtype, case 123, tested, working, 1-5-2014
	}
	
	
	CastParent returnCastParent2() {
		return new CastGrandChild();			// subtype, case 124, tested, working, 1-5-2014
	}
	
	P anotherReturnP() {
		return getMeAGrandChild().getMeAC();	// subtype, case 125, tested, working, 1-5-2014
	}
	
	P[] returnAPArray() {
		return new C[3];						// subtype, case 126, tested, working, 1-5-2014
	}
	
	P anotherPReturn() {
		return (new C[3])[0];					// subtype, case 127, tested, working, 1-5-2014
	}

	P aPReturn1() {
		List <C> aCList = new ArrayList <C> ();
		return aCList.get(0);					// subtype, case 128, tested, working, 1-5-2014
	}
	
	ArrayListParent <CastChild> listReturn() {
		return new ArrayListChild <CastChild> ();	// subtype, case 129, tested, working, 1-5-2014
	}
	
	CastParent retCastParent() {
		return new CastChild();					// subtype, case 130, tested, working, 1-5-2014
	}
	
	ArrayListParent <NestedChild <P>> returnAListParent() {
		return new ArrayListChild <NestedChild <P>> ();	// subtype, case 131, tested, working, 1-5-2014
	}
	
	NestedParent <P> retNestedParent() {
		ArrayListChild <NestedChild <P>> aChildList = new ArrayListChild <NestedChild <P>> ();
		return aChildList.get(0);					// subtype, case 132, tested, working, 1-5-2014
	}
	
	
	P doubleReturn() {
		boolean aBool = false;
		if (aBool) {
			return new C();						// subtype, case 133, tested, working, 1-5-2014
		}
		else return new C();					// subtype, case 134, tested, working, 1-5-2014
	}
	
	
	CastParent secondDoubleReturn() {
		int anInt = 7;
		if (anInt <= 8) {
			return new CastChild();				// subtype, case 135, tested, working, 1-5-2014
		}
		return new CastGrandChild();			// subtype, case 136, tested, working, 1-5-2014
	}
	*/
}
