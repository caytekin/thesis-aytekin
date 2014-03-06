package edu.uva.analysis.gensamples;

public class Rectangle extends Shape implements MyRotatable {
	private int x, y, width, height;
    
	public void draw(Canvas c) {
        System.out.println("I am drawing a rectangle...");
    }
}
