package edu.uva.analysis.samples.ir;

public class StatChild2 extends StatParent {
	
	void justAFieldAccess(){
		statParentsInt += 10;	// internal reuse, tested OK
	}
	
	public static void main(String[] args) {
		aStaticParentMethod();		// internal reuse, tested OK
	}

}
