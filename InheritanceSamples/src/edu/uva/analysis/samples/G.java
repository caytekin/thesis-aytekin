package edu.uva.analysis.samples;

// a grandchild class of P
public class G extends C {
	
	void methodToOverride() {}
	
	void q() {}
	
	void c() {
		System.out.println("G implemnts c()...");
	}
	
	void e() {
		System.out.println("G implemnts e()...");
		C aC = new C();	
		aC.q();		// internal reuse or external reuse?
	}
	
	void xxx() {
		p();		// downcall.
	}
	
}
