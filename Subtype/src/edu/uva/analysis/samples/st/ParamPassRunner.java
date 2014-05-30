package edu.uva.analysis.samples.st;

import java.util.ArrayList;
import java.util.List;

import edu.uva.analysis.gensamples.st.ArrayListChild;
import edu.uva.analysis.gensamples.st.ArrayListGrandChild;
import edu.uva.analysis.gensamples.st.ArrayListParent;

public class ParamPassRunner {
	/*
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
		
		acceptNestedWOParam(new NestedChild ()); 				// subtype, case 214, tested, Working OK, 22-5-2014
		acceptManyParameters(new C(), new CastChild(), new ArrayListChild <NestedChild <P>> ()); 	// subtype, case 215, tested, working OK, 2-5-2014
																									 subtype, case 222, tested, working OK, 2-5-2014
																									// subtype, case 223, tested, working OK, 2-5-2014
	}
	
	void createParamPass() {
		
		ParamPassHolder h1 = new ParamPassHolder(new CastChild());	// subtype, case 216, tested, working OK, 2-5-2014
		ParamPassHolder h2 = new ParamPassHolder(new ArrayListChild<CastChild> ());	// subtype, case 217, tested, working OK, 2-5-2014
		ParamPassHolder h3 = new ParamPassHolder(new ArrayListGrandChild <NestedChild <P>> ());	// subtype, case 218, tested, working OK, 2-5-2014
		ParamPassHolder h4 = new ParamPassHolder(new NestedGrandChild <P> ()); 	// subtype, case 219, tested, working OK, 2-5-2014
		ParamPassHolder h5 = new ParamPassHolder(new NestedChild ()); 			// subtype, case 220, tested, working, 22-5-2014
		ParamPassHolder h6 = new ParamPassHolder(new C(), new CastChild (), new ArrayListChild<NestedChild <P>> ());		// subtype, case 221, tested, working OK, 2-5-2014
																															// subtype, case 224, tested, working OK, 2-5-2014
																															// subtype, case 225, tested, working OK, 2-5-2014
	}
	
	
	
	void varArgsTesting() {
		
		ParamPassHolder pph = new ParamPassHolder(new CastChild(), new CastChild(), new CastParent()) ;			// subtype, case 235, 	tested, working, 5-5-2014
																												// subtype, case 236,	tested, working, 5-5-2014
																												// no subtype, case 237,	tested, working, 5-5-2014
		
		pph.acceptVarArgs(new NestedChild<P> (), new C(), new C(), new P(), new C());							// subtype, case 238,		tested, working, 5-5-2014																											
																												// subtype, case 239,		tested, working, 5-5-2014
																												// no subtype, case 240,	tested, working, 5-5-2014
																												// subtype, case 241,		tested, working, 5-5-2014
																												
	 
		ParamPassHolder pph2 = new ParamPassHolder(new CastGrandChild(), new CastChild());								// subtype, case 242,,		tested, working, 5-5-2014
																														// subtype, case 243,,		tested, working, 5-5-2014
		
		pph2.acceptVarArgsAnother(new C(), new CastGrandChild(), new CastChild(), new CastParent(), new CastParent());	// subtype, case 244, ,		tested, working, 5-5-2014
																														// subtype, case 245,,		tested, working, 5-5-2014
																														// subtype, case 246,,		tested, working, 5-5-2014
																														// no subtype, case 247,,		tested, working, 5-5-2014
																														// no subtype, case 248,,		tested, working, 5-5-2014
	
	}
	*/
}
