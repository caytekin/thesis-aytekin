package edu.uva.analysis.samples;

public class Sub1 extends Super1 {

	Sub1() {
		super();
		xx();		// internal reuse
	}
	
	Sub1(int i) {
		super(i);
	}
	
}
