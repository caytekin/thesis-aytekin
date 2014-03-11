package edu.uva.analysis.gensamples;

import java.util.List;
import java.util.ArrayList;
import java.util.Map;

public class GenericRunner {

//	public Shape returnShape() {
//		return new Rectangle();
//	}
//	
	public MyArrayList<Circle> getCircleList() {
		MySubArrayList<Circle> circles = new MySubArrayList<Circle> ();
//		circles.add(new Circle());
		return circles;
	}
	
	public void getCircleListAsParam(MyArrayList<?> listParam) {
		GenSample6<Shape> shapeSample6 = new GenSample6<Shape> ();
		Circle myCircle222 = new Circle();
		shapeSample6.getTAsParam(myCircle222);
	}
	

	
	
	void runShortGenerics() {
		MyArrayList<? extends Shape> myCircleListShort  = new MySubArrayList<Circle> ();		
		MyArrayList<? super Rectangle> myShapeListShort = new MySubArrayList<Shape> (); 	
	}
	
	// after type erasure List and ArrayList		
	// after type erasure List and ArrayList		
	
	
	
	
	
	
	
	
	
	
	
	void runGenerics() {
//		List <String> myList = new ArrayList<String> (); // after type erasure List and ArrayList
//		Map.Entry<String, Long> myMapEntry;				// after type erasure Map.Entry
//		List<? super Rectangle> myShapeList = new ArrayList<Shape> (); // after type erasure List and ArrayList
//		List<?> myGeneralList = new ArrayList<Rectangle>();		// after type erasure List and ArrayList
//		List<? extends Shape> myCircleList = new ArrayList<Circle> ();		// after type erasure List and ArrayList
//		myShapeList.size();
//		myList.size();
//		myCircleList.size();
//		myGeneralList.size();
//		getCircleListAsParam(new ArrayList<Rectangle>());
	}
	
	void tryCircles() {
//		Circle aCircle = getCircleList().get(0);
//		// the Rascal types of the lhs and rhs of the assignment statement are:
//		// both are Circle
//		// Does my program catch the following? Yes, it does...
//		Shape actuallyACircle = getCircleList().get(0);
	}
	
	void iHaveACircleParam(Circle circleParam) {
		
	}
	
	void tryGenSample1() {
////		GenSample1<Object> objectSample1 = new GenSample1<Object> ();
////		GenSample1<Integer> integerSample1 = new GenSample1<Integer> ();
//		Integer myInt = integerSample1.getT();
//		Number myNum = integerSample1.getT();	
//
//		GenSample6<Circle> circleSample = new GenSample6<Circle> ();
//		Shape myCircleShape = circleSample.getT();
//		myCircleShape.draw(new Canvas());
//		// return type of circleSample.getT() is already bounded in the compile time
//		// and it is Circle
//
//		Shape myShape222 = new Circle();
//		Circle myCircle222 = new Circle();
//		GenSample6<Shape> shapeSample6 = new GenSample6<Shape> ();
//		shapeSample6.getTAsParam(myCircle222);
	}
	
}
