package edu.uva.analysis.samples.ir;

public class GrandGrandChild extends GrandChild  {
	
	public GrandGrandChild () {
		super();		// tested, working, identified as super
	}
	
	public GrandGrandChild(int i) {
		super(i);		// tested, working, identified as super
	}
	
	public GrandGrandChild(double d) {
		super((int)d);			// tested, working, identified as super
		super.justANormalMethod();		// internal reuse, tested OK
	}
	
	void anotherMethod() {
		parentMethod();		// internal reuse, tested OK
		childMethod();		// internal reuse, tested OK
		grandChildMethod();		// internal reuse, tested OK
	}

}
