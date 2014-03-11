package edu.uva.analysis.gensamples;

public class UseTwo <T, X> {	// after type erasure UseTwo
	
	T one;
	X two;
	
	UseTwo(T one, X two) {
		this.one = one;
		this.two = two;
	}
	
	T getT() { return one; }
	X getX() { return two; }
	
	void runIt() {
		UseTwo<String, Integer> twos = new UseTwo<String, Integer> ("foo", 42);
		String theT = twos.getT();
		int theX = twos.getX();
	}

}
