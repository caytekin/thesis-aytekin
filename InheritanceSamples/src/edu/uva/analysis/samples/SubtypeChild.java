package edu.uva.analysis.samples;

public class SubtypeChild extends SubtypeParent {
	
	SubtypeChild iReturnAChild() {
		return new SubtypeChild();
	}

}
