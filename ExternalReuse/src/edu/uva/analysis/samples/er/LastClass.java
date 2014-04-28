package edu.uva.analysis.samples.er;

public class LastClass {

	void anotherRun() {
		GenExRChild <C> aChild = new GenExRChild <C> ();
		int anotherInt = aChild.aT.intFieldParent;	// external reuse 21, (aT),  tested, working 28-4-2014
													// external reuse, 22 (intFieldParenT), tested , NOT WORKING. 
//		
//		C aC = new C();
//		boolean b = aC.boolFieldParent;					// external reuse, 23, tested, working 28-4
	}

}
