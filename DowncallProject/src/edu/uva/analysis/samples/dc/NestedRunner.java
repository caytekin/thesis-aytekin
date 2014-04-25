package edu.uva.analysis.samples.dc;

public class NestedRunner {
	void runIt() {
		NestedChild nc = new NestedChild();
		nc.a();		// actually a double downcall,             
					// I expect two candidate downcalls
					// NestedGrandParent#a(), 
					// NetsedParent#b() and NestedChild#c()
					// are executed 
	}
}