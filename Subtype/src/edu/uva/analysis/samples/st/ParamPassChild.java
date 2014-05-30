package edu.uva.analysis.samples.st;

public class ParamPassChild extends ParamPassHolder {
	
	static CastChild aChild = new CastChild();
	
	static class AnInnerClass extends P {
		
	}
	
	ParamPassChild() {
		this(new C());		// subtype case 231,		tested, working OK, 30-5-2014
	}
	
	
	ParamPassChild (P aP) {
		super(aChild);		// subtype case 230, 		tested, working OK, 30-5-2014
	}

}
