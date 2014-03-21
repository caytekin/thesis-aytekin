package edu.uva.analysis.samples;

public class ThisChangingTypeChild extends ThisChangingTypeParent {
		protected String aString = "I AM THE CHILD";
		
		{
			System.out.println("The initializer of the child...");
		}
		
		void fragmentsTest() {
			int i = 2 * 3;
			P p1, p2, p3 = (i >5) ? new C() : new P();
			
			P p4, p5;
			p4 = (i == 3) ? new C() : new G();
		}
}
