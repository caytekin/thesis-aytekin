package edu.uva.analysis.samples.ge;

import java.util.ArrayList;
import java.util.List;
import java.util.Vector;


public abstract class InterfaceRunner {
	
	public ParentInterface api;
	public ChildInterface aci;
	
	void genericII() {
		Object o = new Object();
		api = (ParentInterface)o;
	}

	
	void castOfInterface() {
		Object anO = new Object();
		I anI = (I)anO;
		
		List aList = new Vector();
		T aT = new R();
		aList.add(aT);
		S anS = (S)aList.get(0);
	}
	
}
