package edu.uva.analysis.samples;

public class ThisChangingTypeChild extends ThisChangingTypeParent {
		protected String aString = "I AM THE CHILD";
		
		{
			System.out.println("The initializer of the child...");
		}
}
