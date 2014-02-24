package edu.uva.analysis.samples;

import java.util.ArrayList;
import java.util.ResourceBundle;

import javax.accessibility.AccessibleResourceBundle;

import edu.uva.analysis.gensamples.MyArrayList;

public class SubtypeRunner {
	
	ByteSample myParameter;
	SubtypeChild aChildToReturn;
	
	SubtypeParent[] anArrayReturn() {
		// This test case works, it is reported as subtype via return type.
		SubtypeChild [] childArray = new SubtypeChild[3];
		return childArray;
	}
	
	SubtypeParent aSubtypeViaReturnType() {
		SubtypeChild childToReturn = new SubtypeChild();
//		return childToReturn;
		H myH = new H();
//		return myH.iAlsoReturnAChild().iReturnAChild();
//		return this.aChildToReturn;
		SubtypeChild [] childArray = new SubtypeChild[3];
		return childArray[0];
		
	}
	
	
	
	
	SubtypeRunner returnASubtypeRunner() {
		return this;
	}
	
	
	
	
	void interfaceRunner() {
		  // Test case 12, Test the declaration with a interface definition, it works
		  I anI = new ImplementInterface();
	}
	
	void aNullExample() {
		C thisIsAC = null;
		C thisIsAnotherC; 
		thisIsAnotherC = null;
	}
	
	void thisexample() {
		SubtypeRunner sRunner;
		sRunner = this;
	}
	
	
	void subtypeViaAssignment() {
		SubtypeParent anotherParent = new SubtypeParent();
		SubtypeParent aParent;
		SubtypeChild aChild = new SubtypeChild();
		
		// Test case 1, this works:
		aParent = aChild;
		
		// Test case 2, this is not counted as subtype, so this also works
		aParent = anotherParent;
		
		// Test case 3, it works
		aParent = new SubtypeChild();
		
		 MyArrayList myList = new MyArrayList();
		 ArrayList aList;

		// Test case 4, this is not counted as subtype because ArrayList is not system type, it works
		 aList = myList;
		 
		 // Test case 5, Tested the assignment with a method call on the right side, it works
		  SubtypeParent anSP33;
		  anSP33 = getMeAChild();

		  // Test case 8, Tested the assignment with a interface definition, it works.
		  I anI; 
		  anI = new ImplementInterface();

		 
	}
	
	
	void anotherSubtypeViaAssignment() {
		 SubtypeParent anSP1111, anSP3333 = new SubtypeChild();

		 SubtypeParent anSP2222, anSP7777 = getMeAChild();
		
		 SubtypeChild [] childArray = new SubtypeChild[3];

		 SubtypeChild [][] childArrayTwoD = new SubtypeChild[3][3];
		 
		 // Tested, it works, counted as subtype.
		 SubtypeParent anSP9999 = childArrayTwoD[0][0];
		 
		 SubtypeParent var1, var2 = new SubtypeChild();
		 
		 SubtypeChild aChild = new SubtypeChild();
		 SubtypeChild aChild222, aChild333 = new SubtypeChild();
		 
		 // Test case 6, Test the assignment in a definition statement, like
		 // Tested, it works, it is counted as subtype
		  SubtypeParent anSP2 = aChild;
		  
		  // Test case 7, Test the assignment in a definition statement with new.
		  // Tested, it works, it's counted as subtype.
		  SubtypeParent anSP444 = new SubtypeChild();
		  
		  SubtypeRunner sRunner = new SubtypeRunner();

		  int i,j,k = 0;
		  
		  
		  int[] intArray = new int[4];
		  
		  
		  try {
			  byte[] bytes = myParameter.getBytes();
		  }
		  catch (Exception e) {
			  System.out.println("An exception is thrown!" + e);
		  }
		  
		  // This is also reported as subtype, it works.
		  SubtypeParent anSP12345 = sRunner.getMeAChild();
		  
		  ResourceBundle myBundle = new ResourceBundleChild();
		  
		  ResourceBundle generalBundle = new AccessibleResourceBundle();
		  
		  
	}
	
	
	SubtypeChild getMeAChild() {
		return new SubtypeChild();
	}
	
	
	void sidewaysDemo(SidewaysA sa) {
		// Tested, it works, counted as subtype
		SidewaysB sb = (SidewaysB)sa;
	}
	
	
	void subtypeViaCasting() {
		SubtypeChild aChild = new SubtypeChild();
		SubtypeParent aParent = (SubtypeParent)aChild;
		int i = 49;
		byte myByte = (byte)i;
		aParent = (SubtypeParent)getMeAChild();
	}
	
	void iExpectAParent(SubtypeParent aParent) {
		// do parent's things
	}
	
	void subtypeViaParameterPassing() {
		SubtypeChild aChild = new SubtypeChild();
		iExpectAParent(aChild);
//		iExpectAParent(new SubtypeChild());
	}
	
	
}
