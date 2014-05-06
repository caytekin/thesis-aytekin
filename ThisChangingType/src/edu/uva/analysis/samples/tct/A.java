package edu.uva.analysis.samples.tct;

public class A {
	
	{
		System.out.println("This is the initializer of class A");
	}
	
	
	A (String aString) {
		
	}
	
	A (ThisChangingTypeParent theParent) {
		System.out.println("Constructor of A is called. With object: " + theParent);
	}
	
	A (TCTParent theParent) {
		System.out.println("Constructor of A is called. With object: " + theParent);
	}
	
	A (X anX) {
		System.out.println("Constructor of A is called. With object: " + anX);		
	}
	
	A (TCTGenericParent <X> genericParent) {
		
	}
	
	
	void iTakeArgThis(ThisChangingTypeParent aParent) {
		
	}

	void iAlsoTakeArgThis(TCTParent aParent) {
		
	}
	
	
	
	public static void main(String[] args) {
//		ThisChangingTypeParent 	aParent = new ThisChangingTypeParent();
		ThisChangingTypeChild 	aChild 	= new ThisChangingTypeChild();	// this changing type occurrence , case 460,
		
//		aParent.aMethod();
//		aChild.aMethod();
	}
}
