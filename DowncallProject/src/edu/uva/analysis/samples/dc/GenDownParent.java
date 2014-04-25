package edu.uva.analysis.samples.dc;

public class GenDownParent <T> {

	void p(T aT) {
		q(aT);
	}
	
	 void q(T aT) {
		
	}
	
	String downString() {
		return ""; 
	}
	 
	 String returnString() {
		 downString();
		 return "";
	 }
}
