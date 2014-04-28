package edu.uva.analysis.samples.er;

import java.util.*;

public class C extends P {
	
	int intFieldChild = intFieldParent;		// external reuse
	double dblFieldChild= 0.0;
	
	void methodToOverride() {}
	
	void canIReachA() {
		
	}
	
	
	void q() {
	
	}
	
	void c() {
		q();		 // internal reuse
	}
	
	void e() {
		C ac = new C();

		HashSet <C> aSet = new HashSet <C>();
		aSet.add(ac);
		Iterator <C> anIterator = aSet.iterator();
		while (anIterator.hasNext()) {
			anIterator.next().returnZero();	
		}
	}

}
