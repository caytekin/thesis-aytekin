package edu.uva.analysis.gensamples;

public class GenSample1 <T> {	// after type erasure T becomes Object.

	GenSample1 (T aT) {
		
	}
	
	T anInstance;
	
	T getT() {
		return anInstance;
	}

	void acceptT(T aT) {
		
	}
}
