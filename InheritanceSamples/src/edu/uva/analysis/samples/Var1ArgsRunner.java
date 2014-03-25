package edu.uva.analysis.samples;

public class Var1ArgsRunner {
	
	void takeSimpleParam(Var1ArgsParent p ) {
		System.out.println("Content single is : " + p);								
	}

	void printMyVar1Args(Var1ArgsParent... parents) {
		for (Var1ArgsParent p: parents) {
			System.out.println("Content Var1Args is : " + p);						
		}
	}
	
	public static void main(String[] args) {
		Var1ArgsRunner runner = new Var1ArgsRunner();
		runner.takeSimpleParam(new Var1ArgsChild());
		runner.printMyVar1Args(new Var1ArgsParent(), new Var1ArgsChild());
		runner.printMyVar1Args();
		runner.printMyVar1Args(new Var1ArgsChild(), new Var1ArgsChild(), new Var1ArgsChild(), new Var1ArgsChild(), new Var1ArgsChild());
		runner.printMyVar1Args(new Var1ArgsParent());
		runner.printMyVar1Args(new Var1ArgsChild());		
	}
}
