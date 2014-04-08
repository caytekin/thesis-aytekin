package edu.uva.analysis.samples;

public class ThrowableRunner {
	
	void runThrowable() {
		IAmAThrowable aThrowable = new IAmAChildOfThrowable(); // subtyping
		
		IAmAChildOfThrowable aChild = new IAmAChildOfThrowable(); 
		aChild.i2(); // External reuse
	}

}
