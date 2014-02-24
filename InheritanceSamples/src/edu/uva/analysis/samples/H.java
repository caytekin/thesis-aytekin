package edu.uva.analysis.samples;

public class H {
	void h() {
		P aP;
		C aC= new C();
		aP = aC;
		k(aC);
	}
	
	void j() {
		P[] pArray = new P[1];
		C[] cArray = new C[1];
		cArray[0] = new C();
		pArray[0] = cArray[0];
	}
	
	void k(P pPar) {
		P aP;
		aP = pPar;
	} 
	
	P returnP() {
		C aC = new C();
		M anM = new M();
		return aC;
	}
	
	void castToP() {
		C myC = new C();
		P myP = (P)myC;
	}
	
	SubtypeChild iAlsoReturnAChild() {
		return new SubtypeChild();
	}
}
