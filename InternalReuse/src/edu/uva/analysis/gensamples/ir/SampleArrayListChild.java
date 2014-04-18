package edu.uva.analysis.gensamples.ir;

public class SampleArrayListChild <T> extends SampleArrayList <T> {
	
	int myInt = sampleArrayListInt; // internal reuse, tested OK
	T childT = getParentT();		// internal reuse, tested OK
	
	void arrayListChildMethod() {
		sampleArrayListMethod();     // internal reuse, tested, OK
		childT = getParentT(); 		// internal reuse, tested, OK
	}

}
