package edu.uva.analysis.samples;

public class NonConstantClass {
	
	
	
	private static final transient int constant1 = 1;	// final, static, tested, works OK
	public static final String constant2 = "I am a static string constant"; // final, static, tested, works OK
	static final boolean iAmNotTrue = true;		// final, static, tested, works OK
	static final double constant22 = 2.2;		// final, static, tested, works OK
	static final float constant33 = 3.3f;		// final, static, tested, works OK
	static final byte constant5 = 5;			// final, static, tested, works OK

	
}
