package edu.uva.analysis.samples;

import java.util.ArrayList;

public class ExtReuseRunner {

	void runIt() {
		ExtReuseChild aChild = new ExtReuseChild();
		aChild.parentMethod();
	}
	
	void anInnerMethod() {
		
		class anInnerClass {
			
		}
		
		
	}
	
	void enhancedForRunner() {
		BugSetCopy aCollection = new BugSetCopy(new ArrayList());
		for (BugLeafNode bln : aCollection) {
			
		}
	}
	
	
}
