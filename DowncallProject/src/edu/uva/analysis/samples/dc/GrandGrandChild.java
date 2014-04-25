package edu.uva.analysis.samples.dc;

public class GrandGrandChild extends GrandChild implements ConstantInterface {
	
	public GrandGrandChild () {
		super();		// tested, working, identified as super
	}
	
	public GrandGrandChild(int i) {
		super(i);		// tested, working, identified as super
	}
	
	public GrandGrandChild(double d) {
		super((int)d);			// tested, working, identified as super
		super.justANormalMethod();
	}

}
