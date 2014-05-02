package edu.uva.analysis.samples.st;

public class OuterInnerRunner {
	
	OuterClass outer = new OuterClass();

	void runIt() {
		outer.new InnerClass();
	}
}
