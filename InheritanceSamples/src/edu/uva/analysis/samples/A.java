package edu.uva.analysis.samples;

public class A {
	
	{
		System.out.println("This is the initializer of class A");
	}
	
	
	A(ThisChangingTypeParent theParent) {
		System.out.println("this is " + theParent);
	}
	
	public static void main(String[] args) {
//		ThisChangingTypeParent 	aParent = new ThisChangingTypeParent();
		ThisChangingTypeChild 	aChild 	= new ThisChangingTypeChild();	
		
//		aParent.aMethod();
//		aChild.aMethod();
	}
}
