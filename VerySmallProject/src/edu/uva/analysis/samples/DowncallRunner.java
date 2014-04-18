package edu.uva.analysis.samples;

import edu.uva.analysis.gensamples.*;


public class DowncallRunner {
	void runDowncall() {
	}
	
	void runWithThis() {
//		DowncallChild dChild = new DowncallChild();
//		dChild.p();		// downcall, tested, working
	}
	
	public static void main (String[] args) {
		DowncallChild <Shape> dChild = new DowncallChild<Shape> ();
//		dChild.p(new Triangle());				// downcall, tested, working.
	}
}
