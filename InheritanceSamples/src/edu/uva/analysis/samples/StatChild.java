package edu.uva.analysis.samples;

public class StatChild extends StatParent {
	
	double statChildDbl = 0.0;
	
	static {
		aStaticParentMethod();						// internal reuse
		staticParentString = "I am accessed!";		// internal reuse
	}
	
	
	{
		nonStaticParentMethod();				// internal reuse
		statChildDbl ++;
		statParentsInt --;						// internal reuse
	}
	
	

}
