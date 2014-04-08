package edu.uva.analysis.gensamples;

public class FieldRunner {

	void runMe() {
		FieldChild aChild = new FieldChild();
		System.out.println("Age of child: " + aChild.ageOfSomeone);
		
		FieldParent aParent = new FieldParent();
		System.out.println("Age of parent: " + aParent.ageOfSomeone);
		
		FieldParent anotherOne = new FieldChild();
		System.out.println("Age of anotherOne: " + anotherOne.ageOfSomeone);		
		
	}
	
	public static void main(String[] args) {
		FieldRunner aRunner = new FieldRunner();
		aRunner.runMe();
	}
	
}
