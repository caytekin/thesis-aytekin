package edu.uva.analysis.gensamples.ir;

import edu.uva.analysis.samples.ir.*;

public class GenSample1Child <T> extends GenSample1<T> {
	
	public GenSample1Child () {
		
	}
	
	
	public GenSample1Child  (T aT) {
		super(aT);
	}
	
	public void genSample1ChildMethod() {
		T aT = getT();		// internal reuse, , tested, OK
		acceptT(aT);		// internal reuse, tested, OK
		genSample1String = "hello";		// internal reuse, tested, OK
	}
	
	void genSample1ChildRunner() {
		GenSample1Child <P> aChild = new GenSample1Child <P> ();
		aChild.genSample1Method();       // internal reuse, , tested, OK
	}

}
