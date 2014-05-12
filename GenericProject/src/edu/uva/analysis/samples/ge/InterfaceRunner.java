package edu.uva.analysis.samples.ge;

import java.util.ArrayList;
import java.util.List;
import java.util.Vector;


public abstract class InterfaceRunner {

	
	void castOfInterface() {
		Object anO = new Object();
		I anI = (I)anO;
		
		List aList = new Vector();
		T aT = new R();
		aList.add(aT);
		S anS = (S)aList.get(0);
	}
	
}
