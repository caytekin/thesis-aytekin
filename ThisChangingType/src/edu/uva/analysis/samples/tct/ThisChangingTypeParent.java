package edu.uva.analysis.samples.tct;

public class ThisChangingTypeParent {
	

	
	protected String aString = "I AM THE PARENT";
	
	protected A anA = new A(this);		// this changing type reference , case 449,
	
	{
		System.out.println("The initializer of the parent");
	}
	
	ThisChangingTypeParent() {
		
	}
	
	
	ThisChangingTypeParent (ThisChangingTypeParent p) {
		p.aString = "Constructor call";
	}
	
	void myArgIsString(String strArg) {
		
	}
	
	void writeThings() {
		System.out.println(this.aString);
	}
	
	
	void aMethod() {
		ThisChangingTypeParent anotherParentXxxxxxxx = this; // this changing type candidate , case 421, tested, working, 6-5-2014
		ThisChangingTypeParent aParent;
		
		aParent = this;			// this changing type candidate , case 422,tested, working, 6-5-2014
		anA.iTakeArgThis(this);	// this changing type candidate , case 423,tested, working, 6-5-2014
		anotherMethod();
		new A(this);			// this changing type candidate , case 424,tested, working, 6-5-2014
		new A(this.aString);
	}
	
	
	void anotherMethod () {
		anA.iTakeArgThis(this);		// this changing type candidate , case 425,tested, working, 6-5-2014
		myArgIsString(this.aString);
		String myStr = this.aString;
		String myStr2;
		myStr2 = this.aString;
	}
	
	
	void thirdMethod() {
		ThisChangingTypeChild aChild = new ThisChangingTypeChild();	// this changing type occurrence , case 427,
		aChild.aMethod();		// this changing type occurrence , case 426, tested, working, 6-5-2014
	}
}
