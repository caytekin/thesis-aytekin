package edu.uva.analysis.samples.ge;

import java.util.List;
import java.util.Vector;

public class GenericSample {

	void runGenericSample() {
		List aList = new Vector();
		T aT = new R();
		aList.add(aT);
		S anS = (S)aList.get(0);
	}
	
	void runAnotherGenSample() {
		List aList = new Vector();
		R anR = new R();
		aList.add(anR);
		S anS = (S)aList.get(0);		
	}
	
}
