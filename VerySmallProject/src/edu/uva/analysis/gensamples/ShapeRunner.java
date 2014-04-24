package edu.uva.analysis.gensamples;

public class ShapeRunner {

	void downcastingSample() {
		Rectangle aRectangle = new Rectangle();
		BlueRectangle blueR = new BlueRectangle ();
		blueR = (BlueRectangle)aRectangle; 
	}
	
	void upcastingSample() {
		Triangle t = (Triangle) (new RightTriangle());
	}
	
}
