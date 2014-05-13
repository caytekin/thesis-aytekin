package edu.uva.analysis.samples.ge;

import java.util.List;
import java.util.ArrayList;
import java.util.Map;


public class GenericRunner {

	
	
	public void anIIGenericSample() {
//		Parent1GenericInterface p1 = new Parent1GenericImplementor(); 
//		List aList = new ArrayList ();
//		aList.add(p1);
//		Parent1GenericInterface anotehrP1 = (Parent1GenericInterface)aList.get(0);
		
	}
	
	public void getCircleListAsParam(List<?> listParam) {
		
	}
	
	NonGenericParent anotherMethod() {
		Object o = new Object();
		return (NonGenericParent)o; 
	}
	
	
	void genericTestMethod() {
		Object o = new Object();
		GrandParentImplementor <Shape, Triangle> impl = (GrandParentImplementor <Shape, Triangle>)o; 

	}
	
	void thirdMethod() {
		AnotherInterface anotherInt = (AnotherInterface)(new Object());
	}
	
}
