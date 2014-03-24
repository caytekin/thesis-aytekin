package edu.uva.analysis.samples;

public class ThisChangingTypeParent {
	
	
	public class MyInner {
		MyInner() {
			
		}
		
		MyInner (String myStr) {
			
		}
		
		MyInner (String myStr, Class classDef) {
			
		}
	}
	
	
	protected String aString = "I AM THE PARENT";
	protected A anA = new A(this);
	
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
	
	
	void aMethod() {
		ThisChangingTypeParent anotherParentXxxxxxxx = this; // OK tested, caught as this changing type
		ThisChangingTypeParent aParent;
		
		aParent = this;			// OK tested, caught as this changing type
		anA.iTakeArgThis(this);	// OK tested, caught as this changing type
		anotherMethod();
		new A(this);			// OK tested, caught as this changing type
		new A(this.aString);
	}
	
	
	void ternaryMethod() {
		P aP = (0<=1) ? new C() : new G();
		P aSecondP = new C();
	}
	
	void subtypeViaConstructorCall() {
		Class myClass = this.getClass();
		ThisChangingTypeChild aChild = new ThisChangingTypeChild(); 
		A myA = new A(aChild);
		P myP = new P();
		this.new MyInner();
		this.new MyInner("This is another string...", myClass );		
		ThisChangingTypeParent aParent = new ThisChangingTypeParent();
		aParent.new MyInner("This is a string...");
		new MyInner("This is the third string", myClass);
		aParent.new MyInner("This is another string...", myClass );
		
	}
	
	void anotherMethod () {
		anA.iTakeArgThis(this);		// OK tested, caught as this changing type
		myArgIsString(this.aString);
		String myStr = this.aString;
		String myStr2;
		myStr2 = this.aString;
	}
	
	
	void thirdMethod() {
		ThisChangingTypeChild aChild = new ThisChangingTypeChild();
		aChild.aMethod();
	}
}
