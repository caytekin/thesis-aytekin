package edu.uva.analysis.gensamples;

public class GenSample1Child <T> extends GenSample1<T> {
	
	public GenSample1Child () {
		
	}
	
	
	public GenSample1Child  (T aT) {
		super(aT);
	}
	
	public void doThings() {
		T aT = getT();
		acceptT(aT);
		genSample1String = "hello";
	}

}
