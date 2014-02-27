package edu.uva.analysis.samples;

import java.util.*;

public class C extends P {
	
	int intFieldChild = 1;
	double dblFieldChild= 0.0;
	
	void methodToOverride() {}
	
	void q() {
	
	}
	
	void c() {
		q();		 // internal reuse
	}
	
	void e() {
		intFieldParent ++;		// internal reuse
		dblFieldChild ++;
		p11();					// internal reuse
		this.p22();				// internal reuse
		c();
		C ac = new C();
		ac.q();					// internal reuse
		C[] cArray = new C[3];
		cArray[0].returnOne();          // internal reuse
		cArray[0].c(); 
		
		
		HashSet <C> aSet = new HashSet <C>();
		aSet.add(ac);
		Iterator <C> anIterator = aSet.iterator();
		while (anIterator.hasNext()) {
			anIterator.next().returnZero();
		}
	}

}
