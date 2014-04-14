package edu.uva.analysis.gensamples;

public class GenSample1Child <T> extends GenSample1<T> {
	
	public GenSample1Child () {
		
	}
	
	
	public GenSample1Child  (T aT) {
		super(aT);
	}
	
	public void doThings() {
//		T aT = getT();
//		acceptT(aT);
		GenSample1Child <Shape> aChild = new GenSample1Child <Shape> (new Triangle()); 
		aChild.acceptT(new Circle());
		aChild.getT();
		genSample1String = "hello";
	}
	
	public void acceptT(T aT) {
		
	}

	public void threeParamMethodCall() {
		GenSample1Child <Shape> aChild = new GenSample1Child <Shape> ();
	}
}
