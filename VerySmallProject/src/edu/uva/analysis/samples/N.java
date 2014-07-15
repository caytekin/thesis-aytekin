package edu.uva.analysis.samples;

import javax.swing.ScrollPaneLayout;
import java.awt.Component;
import java.awt.Canvas;



public class N {
	
	AnInterface anInterface;

	void nRunner() {
		G aG = new G();
		aG.toString();		// External reuse
		
		aG = (G)(new Object());
	}
	
	
	
	
	void externalMethodCall() {
		ScrollPaneLayout aLayout = new ScrollPaneLayout();
		aLayout.addLayoutComponent(new String(), new Canvas());
	}
	
	void complexMethodCall1() {
		GChild <P> aChild = new GChild<P> ();
	}
	
	void complexMethodCall2() {
		GChild <P> aChild = new GChild<P> ();
		P[] aPArray = new P[2];
		aChild.aMethod1("xyz", 3);
		aChild.aMethod2("xyz", aPArray);
		aChild.aMethod3("abc", new P());
		aChild.aMethod4("x", new Object(), new P(), new C());
		aChild.aMethod5(new Object(),  anInterface);
		aChild.aMethod6("String1", "String2");
	}
	
}
