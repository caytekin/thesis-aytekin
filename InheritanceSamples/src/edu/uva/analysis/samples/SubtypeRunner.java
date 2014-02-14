package edu.uva.analysis.samples;

import java.util.ArrayList;

import edu.uva.analysis.gensamples.MyArrayList;

public class SubtypeRunner {
	
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
		  
		 
	}
	
	
	void anotherSubtypeViaAssignment() {
		 SubtypeParent anSP = new SubtypeChild();
		
		 SubtypeChild aChild = new SubtypeChild();
		 SubtypeChild aChild222, aChild333 = new SubtypeChild();
		 
		 // Test case 6, Test the assignment in a definition statement, like
		  SubtypeParent anSP2 = aChild;
		  
		  // Test case 7, Test the assignment in a definition statement with new.
		  SubtypeParent anSP444 = new SubtypeChild();
//		  
		
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
