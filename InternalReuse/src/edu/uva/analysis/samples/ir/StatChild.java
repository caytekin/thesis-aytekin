package edu.uva.analysis.samples.ir;

public class StatChild extends StatParent  {
	
	double statChildDbl = 0.0;
	
	static {
		aStaticParentMethod();						// internal reuse, tested OK
		staticParentString = "I am accessed!";		// internal reuse, tested OK
	}
	
	
	{
		nonStaticParentMethod();				// internal reuse, tested OK
		statChildDbl ++;
		statParentsInt --;						// internal reuse, tested OK
	}
	
	

}
