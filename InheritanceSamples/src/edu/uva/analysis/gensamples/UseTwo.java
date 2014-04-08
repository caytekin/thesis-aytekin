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
		UseTwo<String, Integer> twos;
		twos = new UseTwo<String, Integer> ("foo", 42);
		String theT = twos.getT();
		int theX = twos.getX();
		
		UseTwo<Shape, Shape> anotherTwo;
		anotherTwo = new UseTwo<Shape, Shape> (new Triangle(), new Triangle());
		
		GenSample1 <Shape> genSample1 = new GenSample1<Shape> (new Circle());
		genSample1.acceptT(new Circle());

		
//		GenSample1 <Circle> anotherSample = new GenSample1<Circle> (new Circle());
//		Shape anotherShape = anotherSample.getT();
	}

}
