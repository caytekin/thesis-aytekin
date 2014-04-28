package edu.uva.analysis.samples.er;

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
		aC.q();		// no reuse
		aC.p();     // an actual reuse, but not counted 
					// because it does not fall under the definition of external reuse
					// or internal reuse.
	}
	
	void xxx() {
		p();		// downcall, tested, working
	}
	
}
