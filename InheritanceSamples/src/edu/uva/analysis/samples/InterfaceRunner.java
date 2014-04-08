package edu.uva.analysis.samples;

import java.util.ArrayList;
import java.util.List;
import java.util.Vector;

import edu.uva.analysis.gensamples.*;


public abstract class InterfaceRunner {
	abstract Object getObject() throws Exception;

	final Object getApiObject() throws Exception{
		Object obj = getObject();
		if(obj instanceof MyMutable){
			return ((MyMutable)obj).getImmutableObject();
		}
		return obj;
	}
	
	void secondEnhancedForSample() {
		Canvas aCanvas = new Canvas();
		List<Triangle> triangleList = new ArrayList<Triangle>();
		triangleList.add(new Triangle());
		triangleList.add(new RightTriangle());
		for (Shape aShape : triangleList) {
			aShape.draw(aCanvas);
		}		
	}
	
	void enhancedForSample() {
		Canvas aCanvas = new Canvas();
		Triangle [] triangleArray = {new Triangle(), new RightTriangle()};
		for (Shape aShape : triangleArray) {
			aShape.draw(aCanvas);
		}
	}
	
	
	void tryWithAPackage() {
		edu.uva.analysis.gensamples.Rectangle myRectangle = new edu.uva.analysis.gensamples.Rectangle();
	}
	
	void interfaceSubtype() {
		I anI;
		I2 anI2 = new ImplI2();
		anI = anI2;
	}

	void invokeAMethod() {
		I2 anI2= new ImplI2();
		anI2.i2();
	}
	
	void castOfInterface() {
		Object anO = new Object();
		I anI = (I)anO;
		
		List aList = new Vector();
		T aT = new R();
		aList.add(aT);
		S anS = (S)aList.get(0);
	}
	
}
