package edu.uva.analysis.samples.tct;

public class TCTRunner {

	public static void main(String[] args) {
		TCTChild aChild = new TCTChild  (); // this changing type occurrence , case 444,tested, working, 6-5-2014
		aChild.aMethod(); // this changing type occurrence , case 443, tested, working, 6-5-2014
		
		TCTGrandGrandChild aGGChild = new TCTGrandGrandChild (); // this changing type occurrence , case 442, tested, working, 6-5-2014
		aGGChild.aMethod();		// this changing type occurrence , case 410, tested, working, 6-5-2014
		
		Y aY = new Y();			// this changing type occurrence , case 411, tested, working, 6-5-2014
		
		TCTParent tctParent = new TCTParent();		// NOT a this changing type occurrence , case 412, tested, working, 6-5-2014
	}
	
	void runIt() {
		TCTGenericChild <X> anXChild = new TCTGenericChild <X> (); // this changing type occurrence , case 441, tested, working, 6-5-2014
		anXChild.aMethod();	// this changing type occurrence , case 413, tested, working, 6-5-2014
	}
	
}
