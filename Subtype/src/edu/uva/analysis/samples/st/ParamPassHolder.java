package edu.uva.analysis.samples.st;

import edu.uva.analysis.gensamples.st.ArrayListChild;
import edu.uva.analysis.gensamples.st.ArrayListParent;

public class ParamPassHolder {
	
	
	ParamPassHolder() {
		
	}
	
	ParamPassHolder(P aP) {
		
	}
	
	ParamPassHolder (C aC) {
		
	}
	
	ParamPassHolder(CastParent cParent) {
		
	}

	ParamPassHolder (ArrayListParent<CastChild> aParam) {
		
	}
	
	ParamPassHolder (ArrayListChild <NestedChild <P>> aNestedParam) {
		
	}

	ParamPassHolder (NestedChild <P> aParam) {
		
	}
	
	ParamPassHolder (NestedParent aParam) {
		
	}
	
	ParamPassHolder (P aP, CastParent aCP, ArrayListParent <NestedChild <P>> anNP) {
		
	}
	
	
	
	
	void acceptP(P pParam) {
		
	}
	
	void acceptPArray(P[] anArray) {
		
	}


}
