package edu.uva.analysis.samples.er;

import java.util.ArrayList;
import java.util.List;



public class GenExRRunner {
/*	
	GenExRChild <C> exRunnerChild = new GenExRChild <C> ();
	
	void runIt() {
		GenExRChild <P> aChild = new GenExRChild <P> ();
		aChild.genParent(new P());      // external reuse 1, tested, working 28-4
		aChild.genExChild(new P());
		
		GenExRChild secChild = new GenExRChild ();
		secChild.genParent(new Object());	// external reuse 2, tested, working 28-4
		secChild.genExChild(new Object());
		
		GenExRParent <G> aParent = new GenExRParent <G> ();
		aParent.genParent(new G());
		
		List <GenExRChild <P> > aList = new ArrayList <GenExRChild <P> > (); 
		aList.get(0).genParent(new P());     // external reuse 3, tested, working 28-4
	}
	
	
	
	void otherExreuse() {
		GenExRChild <C> aChild = new GenExRChild <C> ();
		boolean myBool = true;
		if (myBool) {     
			int aLength = aChild.getAString().length(); 	// external reuse 5, tested, working 28-4
															// however, it is logged twice!
			int anInt = aChild.getAnInt() 			// external reuse 6, tested, working 28-4
							+ aChild.getAnInt(); 	// external reuse 7, tested, working 28-4		
		if (aChild.getABoolean()) {}			 // external reuse 4, tested, working 28-4
		}
		int anotherInt = aChild.aT.intFieldParent;		// external reuse 8, , tested, working 28-4 (aT is counted OK)
														// external reuse, 9 , intFieldParent,  tested, working 28-4 
	}

	void methodChain() {
		GenExRChild <C> aChild = new GenExRChild <C> ();		
		
		aChild.getAT().p();                     // external reuse 10, getAT(), tested, working 28-4
												// external reuse 11, p(), tested, working 28-4
		int anInt = aChild.getAT().intFieldParent;	// external reuse 12, getAt(), tested, working, 28 -4 
													// external reuse 13, intFieldParent, NOT WORKING!
		aChild.getAT().CofP().booleanOfP();			// external reuse 14, getAT(), tested, working 28-4 (LOGGED 3 TIMES)
													// external reuse 15, CofP(), tested, working 28-4
													// external reuse 16, booleanOfP(), tested, working 28-4
	}

	
	void anotherMethod() {
		C aC = new C();
		int anInt = aC.intFieldParent;				// external reuse 17, tested, working 28-4
		
		GenExRChild <NestedGen <C, P>> nestedChild = new GenExRChild <NestedGen <C, P>> ();
		nestedChild.getAT().getX().p();				// external reuse 18, (getAT()), tested, working 28-4
													// external reuse 19, (.p()), tested, working 28-4
	}
	
	
	*/
}
