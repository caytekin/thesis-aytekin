package edu.uva.analysis.samples;

import java.util.ArrayList;
import java.util.ResourceBundle;
import javax.accessibility.AccessibleResourceBundle;

import edu.uva.analysis.gensamples.MyArrayList;

public class SubtypeRunner {
	
	ByteSample myParameter;
	
	
	void interfaceRunner() {
		  // Test case 8, Test the assignment with a interface definition, 
		  I anI; 
		  anI = new ImplementInterface();
		
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
		 
		 // Test case 5, Test the assignment with a method call on the right side, it works
		  SubtypeParent anSP33;
		  anSP33 = getMeAChild();

		  // Test case 8, Test the assignment with a interface definition, 
		  I anI; 
		  anI = new ImplementInterface();

		 
	}
	
	
	void anotherSubtypeViaAssignment() {
		 SubtypeParent anSP1111, anSP3333 = new SubtypeChild();

		 SubtypeParent anSP2222, anSP7777 = getMeAChild();
		
		 SubtypeChild [] childArray = new SubtypeChild[3];

		 SubtypeChild [][] childArrayTwoD = new SubtypeChild[3][3];
		 
		 
		 SubtypeParent anSP9999 = childArrayTwoD[0][0];
		 
		 SubtypeParent var1, var2 = new SubtypeChild();
		 
		 SubtypeChild aChild = new SubtypeChild();
		 SubtypeChild aChild222, aChild333 = new SubtypeChild();
		 
		 // Test case 6, Test the assignment in a definition statement, like
		  SubtypeParent anSP2 = aChild;
		  
		  // Test case 7, Test the assignment in a definition statement with new.
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
		  
		  SubtypeParent anSP12345 = sRunner.getMeAChild();
		  
		  ResourceBundle myBundle = new ResourceBundleChild();
		  
		  ResourceBundle generalBundle = new AccessibleResourceBundle();
		  
		  
	}
	
	
	SubtypeChild getMeAChild() {
		return new SubtypeChild();
	}
	
	
	SubtypeParent subtypeViaReturnType() {
		SubtypeChild childToReturn = new SubtypeChild();
		return childToReturn;
	}

	
	void subtypeViaCasting() {
		SubtypeChild aChild = new SubtypeChild();
		SubtypeParent aParent = (SubtypeParent)aChild;
	}
	
	void iExpectAParent(SubtypeParent aParent) {
		// do parent's things
	}
	
	void subtypeViaParameterPassing() {
		SubtypeChild aChild = new SubtypeChild();
		iExpectAParent(aChild);
		iExpectAParent(new SubtypeChild());
	}
	
	
}
