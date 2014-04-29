package edu.uva.analysis.samples.er;

public class LastClass {
	
	C fieldC = new C();

	    private class FooBar extends LastClass {
	        void doAnything(){
//	            boolean myBool = LastClass.this.fieldC.boolFieldParent;  // external reuse, 25,  tested, working, 29-4-2014
//	            LastClass.this.getMeAC().p11();        // external reuse 26, tested, working, 29-4-2014
//	            String myString = LastClass.this.getMeAC().strFieldParent; // external reuse 27, tested, working, 29-4-2014
	        }
	    }

	C getMeAC() {
		return new C();
	}
	    
	void anotherRun() {
		GenExRChild <C> aChild = new GenExRChild <C> ();
		int anotherInt = aChild.aT.intFieldParent;	// external reuse 21, (aT),  tested, working 28-4-2014
													// external reuse, 22 (intFieldParenT), tested , NOT WORKING. 
//		
//		C aC = new C();
//		boolean b = aC.boolFieldParent;					// external reuse, 23, tested, working 28-4
	}
	
	
	void thisTest() {
//		boolean myBool = this.fieldC.boolFieldParent;		// external reuse, 24,  tested, working, 29-4-2014
	}
	
	
	void anotherChaining() {
		ExRChild erChild = new ExRChild(); 
//		erChild.getMeAC().p();									// external reuse, 28, getMeAC(), tested, working, 29-4-2014
//																// external reuse, 29, p(), tested, working, 29-4-2014
//		String  erString = erChild.getMeAC().strFieldParent;	// external reuse, 30, getMeAC(), tested, working, 29-4-2014
//																// external reuse, 31, strFieldParent, tested, working, 29-4-2014

		boolean erBool = erChild.getMeAC().exRChildField.getMeAC().boolFieldParent; // external reuse, 32, getMeAC(),  tested, working, 29-4-2014
																					// external reuse, 33, exRChildField,  tested, working, 29-4-2014
																					// external reuse, 34, getMeAC(),  tested, working, 29-4-2014
																					// external reuse, 35, boolFieldParent,  tested, working, 29-4-2014
	}

	
	
}
