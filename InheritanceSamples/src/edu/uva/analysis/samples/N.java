package edu.uva.analysis.samples;

import java.util.HashSet;
import java.util.ArrayList;
import java.util.LinkedList;
import edu.uva.analysis.gensamples.*;
import java.util.Iterator;


public class N {
	
	String theFieldOfN = "I am a field of N"; 
	
	public N() {
		StatChild sChild = new StatChild();
		sChild.nonStaticParentMethod();
	}
	
	
	void genericSample() {
		MyArrayList <Shape> aList = new MyArrayList <Shape> ();
		// MyArrayList <Shape> aSecList = new MyArrayList <Triangle> ();  // not allowed		

		aList.add(new Triangle());
		aList.add(new Rectangle());		
		
		Shape s2 = aList.get(0);
		
		
		    LinkedList <Shape> numberList = new LinkedList <Shape> (); 
		    numberList .add(new Triangle());  
		    numberList .add(new Rectangle());  
		    Shape s1  = numberList.get(0);
		
		// The following is OUT_OF_SCOPE   !!!!!!!!!!!!!!!!!!!
		// I did not implement this ???? 
		// ArrayList <GrandChild> anotherList = new MyArrayList <Triangle> ();		

		MyArrayList <Shape> axList = new MySubArrayList <Triangle> ();
		
		
	
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
		int k = aCGlow.intFieldParent;	// external reuse - field
		aCGlow.intFieldParent = 0;
//		aCGlow.intFieldParent++;	// external reuse - field
//		aCGlow.intFieldChild++;		// no external reuse
	}
	
	
	
	
	
	
	void extReuse() {
		this.theFieldOfN = "I am being updated";
		theFieldOfN = "I am being updated again.";
		C aCGlow = new C();
		aCGlow.p();		// external reuse and downcall, tested, working
		aCGlow.returnTwo(2);	// external reuse
		this.callMeWithInt(2);
		int k = aCGlow.intFieldParent;	// external reuse - field
		aCGlow.intFieldParent = 0;
		aCGlow.intFieldParent++;	// external reuse - field
		aCGlow.intFieldChild++;		// no external reuse
		G aGGlow = new G();
		aGGlow.p();		// external reuse and downcall, tested, working
//		P aP = new P();
//		aP.p(); 		// NOT an external reuse
		int j = 43;
		int lmk = 32;
		int kmkml;
		kmkml = 99;
		G mySecondG = new G();
		callMeWithInt(mySecondG.returnZero()); 	// external reuse, mySecondG.returnZero()
		G myThirdG = new G();
		j = myThirdG.returnOne() - 1 ;					// external reuse
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
		int i = aC.intFieldParent;
		i = aC.intFieldParent;
	}
	
	
	
	void arrayTest () {
		C[] cArray = new C[3];
		cArray[0].returnArrayZero();			// external reuse on array
		
		HashSet <C> aSet = new HashSet <C>();
		aSet.add(new C());
		Iterator <C> anIterator = aSet.iterator();
		while (anIterator.hasNext()) {
			anIterator.next().returnCollectionZero();		// external reuse on collection, method chaining...
		}
		
		
	}
	
	
		
	int callMeWithInt(int intParameter) {
		return intParameter++; 
	}
	
	void useSubtype() {
		M aM = new M();
		C aC = new C();
		aM.m(aC);				// subtype, M# expects type P, we pass type C
		D aD = new D();
		aD.p();					// downcall when executing D#p, tested, working
	}
}
