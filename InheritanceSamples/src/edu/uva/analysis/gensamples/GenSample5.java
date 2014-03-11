package edu.uva.analysis.gensamples;

public class GenSample5 <T> {
// <T extends Object & Comparable <T>> {	// After type erasure T becomes Object
	
	T anInstance5;
	
	T getT() {
		return anInstance5;
	}

}
