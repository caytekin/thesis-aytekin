package edu.uva.analysis.gensamples;

import java.util.*;

public class DrawRunner {
	public static void main(String[] args) {
		Canvas c = new Canvas();
		c.aListSample();
		
		Shape aShape; 
		aShape = new Triangle(); 
		
		Triangle aTriangle = new Triangle();
		
		DrawRunner dRunner = new DrawRunner(); 
		dRunner.iExpectAShape(aTriangle);
	}
	
	
	public void iExpectAShape(Shape shapePar) {
		
	}
}
