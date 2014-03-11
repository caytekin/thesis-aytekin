package edu.uva.analysis.gensamples;

public class GenSample2 <T extends Number> {	
	// After type erasure T becomes Number
	
	T anInstance2;
	
	T getT() {
		return anInstance2;
	}

}
