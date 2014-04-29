package edu.uva.analysis.samples.st;

public class CastRunner {
	
	void runIt() {
		CastParent aParent = new CastParent();
		aParent = (CastParent)(new CastChild());			// subtype, case 50
															// upcasting
		P aP = new P();
		C aC = (C)aP;			// subtype, case 51
								// downcasting
		
		// do not forget sideways casting!
		
		
	}

}
