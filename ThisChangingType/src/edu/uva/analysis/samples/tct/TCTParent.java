package edu.uva.analysis.samples.tct;

public class TCTParent {
	
	public A anA = new A (this);	// this changing type candidate, case 430, tested, working, 6-5-2014
	
	public TCTParent() {
		new A(this);			// // this changing type candidate, case 403, tested, working, 6-5-2014
	}

	void aMethod() {
		TCTParent anotherParentXxxxxxxx = this; // this changing type candidate, case 404,tested, working, 6-5-2014
		TCTParent aParent;
		
		aParent = this;			// this changing type candidate, case 405,tested, working, 6-5-2014
		anA.iAlsoTakeArgThis(this);	// this changing type candidate, case 406,tested, working, 6-5-2014
		new A(this);			// this changing type candidate, case 407,tested, working, 6-5-2014
	}
}
