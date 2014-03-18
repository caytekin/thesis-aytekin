package edu.uva.analysis.samples;

public class ThisChangingTypeParent {
	protected String aString = "I AM THE PARENT";
	protected A anA = new A(this);
	
	{
		System.out.println("The initializer of the parent");
	}
	
	
	void aMethod() {
		ThisChangingTypeParent aParent;
		aParent = this;
		new A(this);
	}
}
