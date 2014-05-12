package edu.uva.analysis.samples.ca;

public class ARunner {

	SiblingInterface ansi;
	
	public ARunner() {
		
	}
	
	void acceptParent(ParentInterface api) {
		
	}
	
	void callIt() {
		acceptParent(ansi);
	}

}
