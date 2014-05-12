package edu.uva.analysis.samples.ca;

public class CategoryRunner {

	void runCategory() {
		CategoryParent <Shape>  aParent = new CategorySibling <Shape> ();
	}
	
	void anotherMethod() {
		AParent aParent = new AChild();
		AParent anotherParent = new AnotherChild();
	}
	
	void thirdMethod() {
		// X anX = new Y();
	}
	
	
	X returnAnX() {
		return new Y();
	}
	
}

