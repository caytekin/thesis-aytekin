package edu.uva.analysis.gensamples;

public class GenSample3 <T extends Comparable> {	// After type erasure T becomes Comparable
	
	T anInstance3;
	
	T getT() {
		return anInstance3;
	}

}
