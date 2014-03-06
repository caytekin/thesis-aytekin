package edu.uva.analysis.samples;

public class GrandGrandChild extends GrandChild implements ConstantInterface {
	
	public GrandGrandChild () {
		super();
	}
	
	public GrandGrandChild(int i) {
		super(i);
	}
	
	public GrandGrandChild(double d) {
		super((int)d);
		super.justANormalMethod();
	}

}
