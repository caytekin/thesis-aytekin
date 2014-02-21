package edu.uva.analysis.gensamples;

import java.util.*;

public class DrawRunner {
	public static void main(String[] args) {
		Canvas c = new Canvas();
		c.aListSample();
		
		Shape aShape; 
		// Tested, it works, it is counted as subtype
		aShape = new Triangle(); 
		
		// Tested, it works, is not counted as subtype.
		Triangle aTriangle = new Triangle();
		
		// Tested, it works, it is counted as subtype
  		aTriangle = (Triangle)aShape;
		
  		aShape = (Shape)aTriangle;
		
		DrawRunner dRunner = new DrawRunner(); 
		dRunner.iExpectAShape(aTriangle);
	}
	
	
	public void iExpectAShape(Shape shapePar) {
		
	}
}
