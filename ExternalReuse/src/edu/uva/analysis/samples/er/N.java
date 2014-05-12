package edu.uva.analysis.samples.er;

import java.util.HashSet;
import java.util.Iterator;

public class N {
	String theFieldOfN = "I am a field of N"; 

	{
		C aC = new C();
		int myInt = aC.intFieldParent; 			// external reuse in initializer, tested, working 28-4
		aC.p22();                               // external reuse in initializer, tested, working 28-4
	}
	
	
	public N() {
	}
	
	
	void aNewTrial() {
		int j = 21;
		int k = 43;
		int l = 33;
		int w, x = 1;
		System.out.println(x);
		
	}
	
	void extReuse2222() {
		this.theFieldOfN = "I am being updated";
		theFieldOfN = "I am being updated again.";
		C aCGlow = new C();
		int k = aCGlow.intFieldParent;	// external reuse - field, tested working 28-4
		aCGlow.intFieldParent = 0;		// external reuse - field , tested working 28-4
	}
	
	
	
	
	
	
	void extReuse() {
		this.theFieldOfN = "I am being updated";
		theFieldOfN = "I am being updated again.";
		C aCGlow = new C();
		aCGlow.p();		// external reuse and downcall, tested, working, tested working 28-4
		aCGlow.returnTwo(2);	// external reuse, tested working 28-4
		this.callMeWithInt(2);
		int k = aCGlow.intFieldParent;	// external reuse - field, tested working 28-4
		aCGlow.intFieldParent = 0;		// external reuse - field, tested working 28-4
		aCGlow.intFieldParent++;	// external reuse - field, , tested working 28-4
		aCGlow.intFieldChild++;		// no external reuse
		G aGGlow = new G();
		aGGlow.p();		// external reuse and downcall, tested working 28-4
		P aP = new P();
		aP.p(); 		// NOT an external reuse
		int j = 43;
		int lmk = 32;
		int kmkml;
		kmkml = 99;
		G mySecondG = new G();
		callMeWithInt(mySecondG.returnZero()); 	// external reuse, , tested working 28-4, mySecondG.returnZero()
		G myThirdG = new G();
		j = myThirdG.returnOne() - 1 ;					// external reuse, tested working 28-4
	}
	
	
	
	
	void overrideTest() {
		G aG = new G();
		aG.methodToOverride();
	}	
	
	C getMeAC() {
		return new C();
	}
	
	void fieldTest() {
		C aC = new C();
		int i = aC.intFieldParent;		// external reuse field, tested working 28-4
		i = aC.intFieldParent;			// external reuse field, , tested working 28-4
	}
	
	
	
	void arrayTest () {
		C[] cArray = new C[3];
		cArray[0].returnArrayZero();			// external reuse on array, tested working 28-4
		
		HashSet <C> aSet = new HashSet <C>();
		aSet.add(new C());
		Iterator <C> anIterator = aSet.iterator();
		while (anIterator.hasNext()) {
			anIterator.next().returnCollectionZero();		// external reuse, tested working 28-4
															// on collection, method chaining...
		}
		
		
	}
	
		
	int callMeWithInt(int intParameter) {
		return intParameter++; 
	}
}
