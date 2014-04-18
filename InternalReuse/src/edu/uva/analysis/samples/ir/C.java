package edu.uva.analysis.samples.ir;

import java.util.*;

public class C extends P {
	
	int intFieldChild = 1;
	double dblFieldChild= 0.0;
	
	

	
	void castAsIntReuse() {
		Parent anotherParent = new Parent();
		anotherParent = (Parent)parentsChild;				// internal reuse, testedOK 
	}
	
	void getAStringParam(String aStr) {
		
	}
	
	void methodToOverride() {}
	
	void aChildMethod() {
		returnSB(returnString(returnOne()));		// internal reuse, tested OK
													// internal reuse, tested OK
													// internal reuse, tested OK
	}
	
	void intReuseAsMethodParam() {
		getAStringParam(strFieldParent);			// internal reuse, tested OK
		getAStringParam(returnString(2));			// internal reuse , tested OK
	}
	
	int intReuseAsReturn () {
		return returnOne();							// internal reuse , tested OK
	}
	
	String intReuseAsReturnStr () {
		return strFieldParent;						// internal reuse, tested OK
	}
	
	
	void q() {
	
	}
	
	void c() {
		q();		
	}
	
	void e() {
		intFieldParent ++;		// internal reuse, tested OK
		dblFieldChild ++;
		p11();					// internal reuse, tested OK
		this.p22();				// internal reuse, tested OK
		c();
		C ac = new C();
		ac.q();					
		C[] cArray = new C[3];
		cArray[0].returnOne();          // internal reuse, tested OK
		cArray[0].c(); 
		
		
		HashSet <C> aSet = new HashSet <C>();
		aSet.add(ac);
		Iterator <C> anIterator = aSet.iterator();
		while (anIterator.hasNext()) {
			anIterator.next().returnZero();		// internal reuse, tested OK
		}
	}

}
