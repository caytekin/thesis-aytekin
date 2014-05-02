package edu.uva.analysis.samples.st;

import java.util.ArrayList;
import java.util.List;

import edu.uva.analysis.gensamples.st.ArrayListChild;
import edu.uva.analysis.gensamples.st.ArrayListGrandChild;
import edu.uva.analysis.gensamples.st.ArrayListParent;

public class ParamPassRunner {
	
	C fieldC = new C();
	
	C returnAC() {
		return new C();
	}
	
	CastGrandChild getMeAGrandChild() {
		return new CastGrandChild();
	}
	
	
	void acceptCastParent(CastParent cParent) {
		
	}

	void acceptArrayListParent(ArrayListParent<CastChild> aParam) {
		
	}
	
	void acceptNested(ArrayListParent <NestedChild <P>> aNestedParam) {
		
	}

	void acceptNestedParent(NestedParent <P> aParam) {
		
	}
	
	void acceptNestedWOParam(NestedParent aParam) {
		
	}
	
	void acceptManyParameters(P aP, CastParent aCP, ArrayListParent <NestedChild <P>> anNP) {
		
	}
	
	/*
	
	void runParamPass() {
		ParamPassHolder h = new ParamPassHolder();
		acceptCastParent(new CastChild());				// subtype, case 201, tested, working OK, 2-5-2014
		h.acceptP(new C());								// subtype, case 202, tested, working OK, 2-5-2014
		h.acceptP(returnAC());							// subtype, case 203, tested, working OK, 2-5-2014
		h.acceptP(this.fieldC);							// subtype, case 204, tested, working OK, 2-5-2014
		acceptCastParent(new CastGrandChild());			// subtype, case 205, tested, working OK, 2-5-2014
		h.acceptP(getMeAGrandChild().getMeAC());		// subtype, case 206, tested, working OK, 2-5-2014
		C[] aCArray = new C[6];
		h.acceptPArray(new C[3]);						// subtype, case 207, tested, working OK, 2-5-2014
		h.acceptPArray(aCArray);						// subtype, case 208, tested, working OK, 2-5-2014
		acceptCastParent((new CastGrandChild[4])[0]);	// subtype, case 209, tested, working OK, 2-5-2014
		List <C> aCList = new ArrayList <C> ();
		h.acceptP(aCList.get(0));						// subtype, case 210, tested, working OK, 2-5-2014
		acceptArrayListParent(new ArrayListChild<CastChild>());	// subtype, case 211 , tested, working OK, 2-5-2014
		acceptNested(new ArrayListChild <NestedChild <P>> ()); // subtype, case 212, tested, working OK, 2-5-2014
		ArrayListChild <NestedChild <P>> aChildList = new ArrayListChild <NestedChild <P>> ();
		acceptNestedParent(aChildList.get(0));					// subtype, case 213, tested, working OK, 2-5-2014
		acceptNestedWOParam(new NestedParent ()); 				// subtype, case 214, tested, NOT WORKING, 2-5-2014
		acceptManyParameters(new C(), new CastChild(), new ArrayListChild <NestedChild <P>> ()); 	// subtype, case 215, tested, working OK, 2-5-2014
																									// subtype, case 222, tested, working OK, 2-5-2014
																									// subtype, case 223, tested, working OK, 2-5-2014
	}
	
	void createParamPass() {
		ParamPassHolder h1 = new ParamPassHolder(new CastChild());	// subtype, case 216, tested, working OK, 2-5-2014
		ParamPassHolder h2 = new ParamPassHolder(new ArrayListChild<CastChild> ());	// subtype, case 217, tested, working OK, 2-5-2014
		ParamPassHolder h3 = new ParamPassHolder(new ArrayListGrandChild <NestedChild <P>> ());	// subtype, case 218, tested, working OK, 2-5-2014
		ParamPassHolder h4 = new ParamPassHolder(new NestedGrandChild <P> ()); 	// subtype, case 219, tested, working OK, 2-5-2014
		ParamPassHolder h5 = new ParamPassHolder(new NestedParent ()); 			// subtype, case 220, tested, NOT WORKING, 2-5-2014
		ParamPassHolder h6 = new ParamPassHolder(new C(), new CastChild (), new ArrayListChild<NestedChild <P>> ());		// subtype, case 221, tested, working OK, 2-5-2014
																															// subtype, case 224, tested, working OK, 2-5-2014
																															// subtype, case 225, tested, working OK, 2-5-2014
	}
	
	*/
	
}
