package edu.uva.analysis.samples;

public class P {
	
	public int intFieldParent = 0;
	String strFieldParent = "";
	
	void methodToOverride() {}
	
	int returnCollectionZero() { return 0;} 
	
	int returnArrayZero() {return 0;}
	
	int returnOne() {
		return 1;
	}
	
	int returnTwo(int paramTwo) {
		return 2;
	}
	
	
	void p() {
		q();
	}
	
	void q() {}
	
	void p11() {}
	
	void p22() {}
	
	void p33() {}
	
	int returnZero() {
		return 0;
	}
	
}
