package edu.uva.analysis.gensamples;

public class UseTwo <T, X> {	// after type erasure UseTwo
	
	T one;
	X two;
	Shape myShape = new Rectangle();
	Shape anotherShape = myShape;
	
	UseTwo () {
		
	}
	
	UseTwo(T one, X two) {
		this.one = one;
		this.two = two;
	}
	
	T getT() { return one; }
	X getX() { return two; }
	
	void doSomething(T one, X two) {
		
	}
	
	void doOneThing(UseTwo <T, X> aParam) {
		
	}
	
	
	void runNewObject() {
//		new UseTwo<Shape, Shape> (new Rectangle(), new Rectangle());		
	}
	
		UseTwo <GenSample6 <BlueRectangle>, RightTriangle> getParameterInParameter() {
		return new UseTwo <GenSample6 <BlueRectangle>, RightTriangle> ();
	}
	
	
	void nestedParamExample() {
		UseTwo <GenSample1 <Rectangle>, Triangle> aUseTwoObject = new UseTwo <GenSample1 <Rectangle>, Triangle> ();
		aUseTwoObject.doSomething(new GenSample1Child <Rectangle> (), new RightTriangle());
//		aUseTwoObject.doOneThing(parameterInParameter);
	}
	
	
	void runIt() {
		
//		UseTwo<String, Integer> twos;
//		twos = new UseTwo<String, Integer> ("foo", 42);
//		twos.doSomething(new String(), new Integer(6));
//		String theT = twos.getT();
//		int theX = twos.getX();
		
//		GenSample6 <Shape> aGenSample6 = new GenSample6 <Shape> ();
//		
//		
//		
//		UseTwo<Shape, Triangle> anotherTwo;
//		anotherTwo = new UseTwo<Shape, Triangle> ();
//		anotherTwo.doSomething(new Circle(), new RightTriangle());
//		
//		GenSample6 <Rectangle> myGenSample = new GenSample6 <Rectangle> ();
//		
//		UseTwo <GenSample6 <Rectangle>, Triangle> parameterInParameter;
//		parameterInParameter = new UseTwo <GenSample6 <Rectangle>, Triangle> (new GenSample6 <Rectangle> (), new Triangle());
//		parameterInParameter.doSomething(new GenSample6 <Rectangle> (new BlueRectangle()), new RightTriangle());
		
//		new UseTwo<Shape, Shape> (new Rectangle(), new Rectangle());
//		
//		GenSample1 <Shape> genSample1 = new GenSample1<Shape> (new Circle());
//		genSample1.acceptT(new Circle());
//
//		
//		GenSample1 <Circle> anotherSample = new GenSample1<Circle> (new Circle());
//		Shape anotherShape = anotherSample.getT();
	}

}
