package edu.uva.analysis.samples.st;

import java.util.ArrayList;
import java.util.List;

import edu.uva.analysis.gensamples.st.ArrayListChild;
import edu.uva.analysis.gensamples.st.ArrayListParent;

public class CastRunner {
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
		CastParent aParent = new CastParent();
		aParent = (CastParent)(new CastChild());			// subtype, case 50, tested, working, 1-5-2014
															// upcasting
		P aP = new P();
		C aC = (C)aP;			// subtype, case 51, tested, working, 1-5-2014
								// downcasting
		
		
		aP = (P)returnAC();						// subtype, case 52, tested, working, 1-5-2014
		
		aP = (P)(new CastGrandChild()).getMeAC();  // subtype, case 53, tested, working, 1-5-2014
		
		aP = (P)getMeAGrandChild().getMeAC();  // subtype, case 54, tested, working, 1-5-2014
		
		aP = (P)fieldC;					// subtype, case 55, tested, working, 1-5-2014
		
		aP = (P)this.getMeAGrandChild().getMeAC();  // subtype, case 56, tested, working, 1-5-2014
		
		aP = (P)this.fieldC;					// subtype, case 57, tested, working, 1-5-2014
		
		acceptAP((P)(new C()));					// subtype, case 58, tested, working, 1-5-2014
		
		C[] cArray = new C [5];
		P[] pArray = new P [5];
		pArray = (P[])cArray;					// subtype, case 59, tested, working, 1-5-2014
		
		pArray[0] = (P)cArray[0];				// subtype, case 60, tested, working, 1-5-2014
		
		List <C> aCList = new ArrayList <C> ();
		List <P> aPList = new ArrayList <P> ();
		aP = (P)aCList.get(0);					// subtype, case 61, tested, working, 1-5-2014
		
		
		ArrayListChild <CastChild> aListChild = new ArrayListChild <CastChild> ();
		ArrayListParent <CastChild> aListParent = new ArrayListParent <CastChild> ();
		
		aListParent = (ArrayListParent <CastChild>)aListChild;		// subtype, case 62, tested, working, 1-5-2014
		
		CastParent aCastParent = new CastParent();
		aCastParent = (CastParent)aListChild.get(0);				// subtype, case 65, tested, working, 1-5-2014
		
		ArrayListChild <NestedChild <P> > aNestedList = new ArrayListChild <NestedChild <P>> (); 
		ArrayListParent <NestedChild <P> > aNestedParentList;
		aNestedParentList = (ArrayListParent <NestedChild <P>>) aNestedList;		// subtype, case 63, tested, working, 1-5-2014
		NestedParent <P> aNestedParent = (NestedParent <P>) aNestedList.get(0);		// subtype, case 64, tested, working, 1-5-2014
		
		
		CastParent anotherParent = new CastParent();
		CastGrandChild aGrandChild = new CastGrandChild ();
		anotherParent = (CastParent)aGrandChild;				// subtype, case 66, tested, working, 1-5-2014
		
		CastChild anotherChild= new CastChild();
		aGrandChild = (CastGrandChild) anotherParent;			// subtype, case 67, tested, working, 1-5-2014
		
	}
*/
}
