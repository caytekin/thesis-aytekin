package edu.uva.analysis.gensamples;

public class GenSample1 <T> {	// after type erasure T becomes Object.
	public String genSample1String = "";
	public GenSample1() {
		
	}
	
	public GenSample1 (T aT) {
		
	}
	
	T anInstance;
	
	T getT() {
		return anInstance;
	}

	void acceptT(T aT) {
		
	}
	
	GenSample1 <GenSample1 <T>> returnAGenSample() {
		return new GenSample1Child<GenSample1 <T>> ();
	}
	
}
