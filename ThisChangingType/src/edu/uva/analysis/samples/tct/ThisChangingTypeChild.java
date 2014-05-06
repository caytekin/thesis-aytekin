package edu.uva.analysis.samples.tct;

public class ThisChangingTypeChild extends ThisChangingTypeParent {
		
		protected String aString = "I AM THE CHILD";
		{
			System.out.println("The initializer of the child...");
		}	
		
		void writeYourName (ThisChangingTypeChild aChild) {
			System.out.println(aChild.aString);
		}
		
}
