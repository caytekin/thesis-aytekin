package edu.uva.analysis.gensamples;

import java.util.ArrayList;
import java.util.List;
import edu.uva.analysis.samples.*;

public class Canvas {
	public void draw(Shape s) {
        s.draw(this);
   }
	
	public void drawAll(List<? extends Shape> shapes) {
		for (Shape s: shapes) {
	        s.draw(this);
	   }	
	}
	
	public void aListSample() {
//		List <Shape> myListXxxx = new ArrayList<Shape> ();
//		myListXxxx.add(new Circle());
		Shape s, myShape;
//		myShape = myListXxxx.get(0);
		
		Circle aCircle = new Circle();
		// Tested, this is counted as subtype
		s = aCircle;
	}	
	
	public void aCircleSample() {
//		List <Circle> myCircleList = new ArrayList<Circle> ();
//		drawAll(myCircleList);		
	}
	
	public void whatsMyType() {
		P myNameIsP = new C();	
		
		// Tested, it works, counted as subtype
		Shape iAmAShape = new Rectangle();
	
	}
	
	
}
