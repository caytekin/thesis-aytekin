package edu.uva.analysis.gensamples;

public class GenSample1 <T> {	// after type erasure T becomes Object.

	T anInstance;
	
	T getT() {
		return anInstance;
	}
}
