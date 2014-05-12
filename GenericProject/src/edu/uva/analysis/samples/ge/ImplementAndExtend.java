package edu.uva.analysis.samples.ge;

public class ImplementAndExtend extends P implements I, ConstantInterface {

	@Override
	public void i1() {
		System.out.println("This is the implementation of i1 in implement and extend."); 
	}

	@Override
	public void i2() {
		System.out.println("This is the implementation of i2 in implement and extend."); 
	}
	
	void p() {
		System.out.println("Another taste of p."); 		
		q();			
	}
	
	void q() {
		System.out.println("Another taste of q."); 		
	}

}
