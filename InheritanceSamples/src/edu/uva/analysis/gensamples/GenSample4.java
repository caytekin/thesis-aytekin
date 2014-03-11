package edu.uva.analysis.gensamples;

public class GenSample4 <T> {
// <T extends Cloneable & Comparable <T>> {	// after type erasure T becomes Cloneable
	
	T anInstance4;
	
	T getT() {
		return anInstance4;
	}

}
